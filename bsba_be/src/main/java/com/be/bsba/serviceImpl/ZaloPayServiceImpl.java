package com.be.bsba.serviceImpl;

import com.be.bsba.config.ZaloPayProperties;
import com.be.bsba.constant.BookingStatus;
import com.be.bsba.constant.PaymentProvider;
import com.be.bsba.constant.PaymentStatus;
import com.be.bsba.dto.request.ZaloPayCallbackRequest;
import com.be.bsba.dto.request.ZaloPayCreateRequest;
import com.be.bsba.dto.response.ZaloPayCreateResponse;
import com.be.bsba.dto.response.ZaloPayStatusResponse;
import com.be.bsba.entity.Booking;
import com.be.bsba.entity.Payment;
import com.be.bsba.entity.User;
import com.be.bsba.exception.AppException;
import com.be.bsba.exception.PaymentGatewayException;
import com.be.bsba.exception.ResourceNotFoundException;
import com.be.bsba.repository.BookingRepository;
import com.be.bsba.repository.PaymentRepository;
import com.be.bsba.repository.UserRepository;
import com.be.bsba.service.INotificationService;
import com.be.bsba.service.ZaloPayService;
import com.be.bsba.util.HmacUtil;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestClientResponseException;

import java.math.BigDecimal;
import java.security.SecureRandom;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.HexFormat;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class ZaloPayServiceImpl implements ZaloPayService {
    private static final int APP_TRANS_ID_ATTEMPTS = 5;
    private static final DateTimeFormatter APP_TRANS_DATE_FORMAT = DateTimeFormatter.ofPattern("yyMMdd");
    private static final ZoneId VIETNAM_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");
    private static final TypeReference<Map<String, Object>> MAP_TYPE = new TypeReference<>() {
    };
    private static final ParameterizedTypeReference<Map<String, Object>> MAP_RESPONSE_TYPE =
            new ParameterizedTypeReference<>() {
            };

    private final ZaloPayProperties properties;
    private final ObjectMapper objectMapper;
    private final RestClient zaloPayRestClient;
    private final BookingRepository bookingRepository;
    private final PaymentRepository paymentRepository;
    private final UserRepository userRepository;
    private final INotificationService notificationService;
    private final SecureRandom secureRandom = new SecureRandom();

    @Override
    @Transactional(noRollbackFor = PaymentGatewayException.class)
    public ZaloPayCreateResponse createPayment(ZaloPayCreateRequest request, String authenticatedEmail) {
        User user = requireAuthenticatedUser(authenticatedEmail);
        Booking booking = bookingRepository.findByIdForUpdate(request.getBookingId())
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found"));

        validateBookingForPayment(booking, user);

        BigDecimal paymentAmount = request.getTotalPrice();
        long zaloPayAmount = toZaloPayAmount(paymentAmount);
        String amount = Long.toString(zaloPayAmount);
        String appTransId = generateUniqueAppTransId();

        Payment payment = Payment.builder()
                .booking(booking)
                .user(user)
                .provider(PaymentProvider.ZALOPAY)
                .appTransId(appTransId)
                .amount(paymentAmount)
                .status(PaymentStatus.PENDING)
                .build();
        paymentRepository.saveAndFlush(payment);

        long appTime = System.currentTimeMillis();
        String appUser = user.getId().toString();
        String embedData = toJson(Map.of(
                "booking_id", booking.getId().toString(),
                "user_id", user.getId().toString()
        ));
        String item = toJson(List.of(Map.of(
                "itemid", booking.getId().toString(),
                "itemname", "BoardNest booking",
                "itemprice", zaloPayAmount,
                "itemquantity", 1
        )));

        // ZaloPay requires this exact field order for create-order authentication.
        String macData = String.join("|",
                properties.getAppId(),
                appTransId,
                appUser,
                amount,
                Long.toString(appTime),
                embedData,
                item
        );

        MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
        form.add("app_id", properties.getAppId());
        form.add("app_trans_id", appTransId);
        form.add("app_user", appUser);
        form.add("app_time", Long.toString(appTime));
        form.add("amount", amount);
        form.add("item", item);
        form.add("embed_data", embedData);
        form.add("callback_url", properties.getCallbackUrl().trim());
        form.add("description", "BoardNest - Payment for booking #" + booking.getId());
        form.add("bank_code", "");
        form.add("mac", HmacUtil.hmacSha256(macData, properties.getKey1()));

        Map<String, Object> response;
        try {
            response = zaloPayRestClient.post()
                    .uri(properties.getCreateOrderUrl())
                    .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                    .body(form)
                    .retrieve()
                    .body(MAP_RESPONSE_TYPE);
        } catch (RestClientResponseException exception) {
            payment.setStatus(PaymentStatus.FAILED);
            paymentRepository.save(payment);
            log.error("[ZaloPay] Create-order HTTP error: appTransId={}, status={}, response={}",
                    appTransId, exception.getStatusCode(), exception.getResponseBodyAsString(), exception);
            throw new PaymentGatewayException("ZaloPay is temporarily unavailable");
        } catch (RestClientException exception) {
            payment.setStatus(PaymentStatus.FAILED);
            paymentRepository.save(payment);
            log.error("[ZaloPay] Create-order request failed: appTransId={}", appTransId, exception);
            throw new PaymentGatewayException("ZaloPay is temporarily unavailable");
        }

        log.info("[ZaloPay] Create-order response: appTransId={}, response={}", appTransId, response);
        if (response == null) {
            failCreatePayment(payment, "ZaloPay returned an empty create-order response");
        }

        int returnCode = asInt(response.get("return_code"));
        if (returnCode != 1) {
            int subReturnCode = asInt(response.get("sub_return_code"));
            if (subReturnCode == -68) {
                failCreatePayment(payment, "ZaloPay rejected a duplicate transaction identifier; retry payment creation");
            }
            failCreatePayment(payment, "ZaloPay could not create the payment order");
        }

        String zpTransToken = asString(response.get("zp_trans_token"));
        if (zpTransToken == null || zpTransToken.isBlank()) {
            failCreatePayment(payment, "ZaloPay did not return a payment token");
        }

        payment.setZpTransToken(zpTransToken);
        payment.setOrderUrl(asString(response.get("order_url")));
        paymentRepository.saveAndFlush(payment);

        return ZaloPayCreateResponse.builder()
                .paymentId(payment.getId())
                .bookingId(booking.getId())
                .appTransId(appTransId)
                .zpTransToken(payment.getZpTransToken())
                .orderUrl(payment.getOrderUrl())
                .amount(payment.getAmount())
                .status(payment.getStatus())
                .build();
    }

    @Override
    @Transactional
    public Map<String, Object> handleCallback(ZaloPayCallbackRequest request, String rawBody) {
        if (request == null
                || !HmacUtil.verifyHmacSha256(request.getData(), properties.getKey2(), request.getMac())) {
            log.warn("[ZaloPay] Callback MAC verification failed");
            return Map.of("return_code", -1, "return_message", "mac not equal");
        }

        final Map<String, Object> callbackData;
        try {
            callbackData = objectMapper.readValue(request.getData(), MAP_TYPE);
        } catch (JsonProcessingException exception) {
            log.warn("[ZaloPay] Callback data is invalid JSON", exception);
            return callbackFailure("invalid callback data");
        }

        try {
            String callbackAppId = requiredString(callbackData, "app_id");
            String appTransId = requiredString(callbackData, "app_trans_id");
            String zpTransId = requiredString(callbackData, "zp_trans_id");
            BigDecimal callbackAmount = requiredDecimal(callbackData, "amount");
            String serverTime = optionalString(callbackData, "server_time");

            if (!properties.getAppId().equals(callbackAppId)) {
                log.warn("[ZaloPay] Callback app_id mismatch: appTransId={}", appTransId);
                return callbackFailure("app_id not equal");
            }

            Payment payment = paymentRepository.findByAppTransIdForUpdate(appTransId).orElse(null);
            if (payment == null) {
                log.warn("[ZaloPay] Callback payment not found: appTransId={}", appTransId);
                return callbackFailure("payment not found");
            }

            if (payment.getStatus() == PaymentStatus.SUCCESS) {
                return callbackSuccess();
            }

            if (payment.getAmount().compareTo(callbackAmount) != 0) {
                log.warn("[ZaloPay] Callback amount mismatch: appTransId={}, expected={}, actual={}",
                        appTransId, payment.getAmount(), callbackAmount);
                return callbackFailure("amount not equal");
            }

            payment.setStatus(PaymentStatus.SUCCESS);
            payment.setZpTransId(zpTransId);
            payment.setCallbackRawData(rawBody);
            payment.setCallbackReceivedAt(OffsetDateTime.now());
            payment.getBooking().setStatus(BookingStatus.CONFIRMED);
            paymentRepository.save(payment);
            notificationService.notifyBookingConfirmed(payment.getBooking());

            log.info("[ZaloPay] Callback applied: appTransId={}, zpTransId={}, serverTime={}, bookingId={}",
                    appTransId, zpTransId, serverTime, payment.getBooking().getId().toString());
            return callbackSuccess();
        } catch (IllegalArgumentException exception) {
            log.warn("[ZaloPay] Invalid callback fields: {}", exception.getMessage());
            return callbackFailure(exception.getMessage());
        }
    }

    @Override
    @Transactional
    public ZaloPayStatusResponse getPaymentStatus(String appTransId, String authenticatedEmail) {
        User user = requireAuthenticatedUser(authenticatedEmail);
        Payment payment = paymentRepository.findByAppTransIdForUpdate(appTransId)
                .orElseThrow(() -> new ResourceNotFoundException("Payment not found"));

        if (!payment.getUser().getId().equals(user.getId())) {
            throw new AppException("Payment does not belong to the authenticated user", HttpStatus.FORBIDDEN);
        }

        if (payment.getStatus() != PaymentStatus.SUCCESS
                && properties.getQueryOrderUrl() != null
                && !properties.getQueryOrderUrl().isBlank()) {
            reconcileWithZaloPay(payment);
        }

        return mapStatusResponse(payment);
    }

    private void reconcileWithZaloPay(Payment payment) {
        String macData = properties.getAppId() + "|" + payment.getAppTransId() + "|" + properties.getKey1();
        MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
        form.add("app_id", properties.getAppId());
        form.add("app_trans_id", payment.getAppTransId());
        form.add("mac", HmacUtil.hmacSha256(macData, properties.getKey1()));

        final Map<String, Object> response;
        try {
            response = zaloPayRestClient.post()
                    .uri(properties.getQueryOrderUrl())
                    .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                    .body(form)
                    .retrieve()
                    .body(MAP_RESPONSE_TYPE);
        } catch (RestClientResponseException exception) {
            log.error("[ZaloPay] Query-order HTTP error: appTransId={}, status={}, response={}",
                    payment.getAppTransId(), exception.getStatusCode(), exception.getResponseBodyAsString(), exception);
            return;
        } catch (RestClientException exception) {
            log.error("[ZaloPay] Query-order request failed: appTransId={}", payment.getAppTransId(), exception);
            return;
        }

        log.info("[ZaloPay] Query-order response: appTransId={}, response={}", payment.getAppTransId(), response);
        if (response == null) {
            return;
        }

        int returnCode = asInt(response.get("return_code"));
        if (returnCode == 1) {
            BigDecimal queriedAmount;
            try {
                queriedAmount = requiredDecimal(response, "amount");
            } catch (IllegalArgumentException exception) {
                log.warn("[ZaloPay] Successful query response has invalid amount: appTransId={}",
                        payment.getAppTransId());
                return;
            }

            if (payment.getAmount().compareTo(queriedAmount) != 0) {
                log.error("[ZaloPay] Query amount mismatch: appTransId={}, expected={}, actual={}",
                        payment.getAppTransId(), payment.getAmount(), queriedAmount);
                return;
            }

            payment.setStatus(PaymentStatus.SUCCESS);
            payment.setZpTransId(asString(response.get("zp_trans_id")));
            payment.getBooking().setStatus(BookingStatus.CONFIRMED);
            paymentRepository.saveAndFlush(payment);
            notificationService.notifyBookingConfirmed(payment.getBooking());
        } else if (returnCode == 2) {
            payment.setStatus(PaymentStatus.FAILED);
            paymentRepository.saveAndFlush(payment);
        }
    }

    private User requireAuthenticatedUser(String authenticatedEmail) {
        if (authenticatedEmail == null || authenticatedEmail.isBlank()) {
            throw new AppException("Authentication is required", HttpStatus.UNAUTHORIZED);
        }
        return userRepository.findByEmail(authenticatedEmail)
                .orElseThrow(() -> new AppException("Authenticated user not found", HttpStatus.UNAUTHORIZED));
    }

    private void validateBookingForPayment(Booking booking, User user) {
        if (booking.getUser() == null || !booking.getUser().getId().equals(user.getId())) {
            throw new AppException("Booking does not belong to the authenticated user", HttpStatus.FORBIDDEN);
        }
        if (paymentRepository.existsByBookingIdAndStatus(booking.getId(), PaymentStatus.SUCCESS)) {
            throw new AppException("Booking is already paid", HttpStatus.CONFLICT);
        }
        if (booking.getStatus() != BookingStatus.PENDING) {
            throw new AppException("Booking status does not allow payment", HttpStatus.CONFLICT);
        }
    }

    private long toZaloPayAmount(BigDecimal totalPrice) {
        try {
            return totalPrice.longValueExact();
        } catch (ArithmeticException exception) {
            throw new AppException("Booking total price must be a whole VND amount", HttpStatus.BAD_REQUEST);
        }
    }

    private String generateUniqueAppTransId() {
        for (int attempt = 0; attempt < APP_TRANS_ID_ATTEMPTS; attempt++) {
            byte[] randomBytes = new byte[8];
            secureRandom.nextBytes(randomBytes);
            String candidate = LocalDate.now(VIETNAM_ZONE).format(APP_TRANS_DATE_FORMAT)
                    + "_" + HexFormat.of().formatHex(randomBytes);
            if (!paymentRepository.existsByAppTransId(candidate)) {
                return candidate;
            }
        }
        throw new AppException("Could not generate a unique payment transaction id", HttpStatus.CONFLICT);
    }

    private void failCreatePayment(Payment payment, String safeMessage) {
        payment.setStatus(PaymentStatus.FAILED);
        paymentRepository.save(payment);
        throw new PaymentGatewayException(safeMessage);
    }

    private String toJson(Object value) {
        try {
            return objectMapper.writeValueAsString(value);
        } catch (JsonProcessingException exception) {
            throw new IllegalStateException("Failed to serialize ZaloPay payload", exception);
        }
    }

    private ZaloPayStatusResponse mapStatusResponse(Payment payment) {
        return ZaloPayStatusResponse.builder()
                .paymentId(payment.getId())
                .bookingId(payment.getBooking().getId())
                .appTransId(payment.getAppTransId())
                .zpTransId(payment.getZpTransId())
                .amount(payment.getAmount())
                .status(payment.getStatus())
                .bookingStatus(payment.getBooking().getStatus())
                .updatedAt(payment.getUpdatedAt())
                .build();
    }

    private Map<String, Object> callbackSuccess() {
        return Map.of("return_code", 1, "return_message", "success");
    }

    private Map<String, Object> callbackFailure(String message) {
        return Map.of("return_code", 2, "return_message", message);
    }

    private String requiredString(Map<String, Object> values, String field) {
        String value = asString(values.get(field));
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException(field + " is required");
        }
        return value;
    }

    private String optionalString(Map<String, Object> values, String field) {
        return asString(values.get(field));
    }

    private BigDecimal requiredDecimal(Map<String, Object> values, String field) {
        String value = requiredString(values, field);
        try {
            return new BigDecimal(value);
        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException(field + " is invalid");
        }
    }

    private int asInt(Object value) {
        if (value instanceof Number number) {
            return number.intValue();
        }
        if (value instanceof String string && !string.isBlank()) {
            try {
                return Integer.parseInt(string);
            } catch (NumberFormatException ignored) {
                return 0;
            }
        }
        return 0;
    }

    private String asString(Object value) {
        return value == null ? null : String.valueOf(value);
    }
}
