package com.be.bsba.serviceImpl;

import com.be.bsba.config.ZaloPayProperties;
import com.be.bsba.constant.BookingStatus;
import com.be.bsba.constant.PaymentStatus;
import com.be.bsba.dto.request.ZaloPayCallbackRequest;
import com.be.bsba.entity.Booking;
import com.be.bsba.entity.Payment;
import com.be.bsba.repository.BookingRepository;
import com.be.bsba.repository.PaymentRepository;
import com.be.bsba.repository.UserRepository;
import com.be.bsba.util.HmacUtil;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.web.client.RestClient;

import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertAll;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ZaloPayServiceImplTests {

    private static final String KEY2 = "callback-key";
    private static final UUID BOOKING_ID = UUID.fromString("11111111-1111-1111-1111-111111111111");

    private final ZaloPayProperties properties = new ZaloPayProperties();
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Mock
    private RestClient zaloPayRestClient;

    @Mock
    private BookingRepository bookingRepository;

    @Mock
    private PaymentRepository paymentRepository;

    @Mock
    private UserRepository userRepository;

    private ZaloPayServiceImpl service;

    @BeforeEach
    void setUp() {
        properties.setAppId("2553");
        properties.setKey1("key-1");
        properties.setKey2(KEY2);
        properties.setCreateOrderUrl("https://example.test/v2/create");
        properties.setQueryOrderUrl("https://example.test/v2/query");
        properties.setCallbackUrl("https://example.test/callback");

        service = new ZaloPayServiceImpl(
                properties,
                objectMapper,
                zaloPayRestClient,
                bookingRepository,
                paymentRepository,
                userRepository
        );
    }

    @Test
    void callbackMarksPaymentAndBookingSuccessful() throws Exception {
        Payment payment = pendingPayment();
        String data = callbackData("10000");
        when(paymentRepository.findByAppTransIdForUpdate("260612_order"))
                .thenReturn(Optional.of(payment));

        Map<String, Object> response = service.handleCallback(callbackRequest(data), "{raw-callback}");

        assertAll(
                () -> assertEquals(1, response.get("return_code")),
                () -> assertEquals(PaymentStatus.SUCCESS, payment.getStatus()),
                () -> assertEquals(BookingStatus.CONFIRMED, payment.getBooking().getStatus()),
                () -> assertEquals("260612000000001", payment.getZpTransId()),
                () -> assertEquals("{raw-callback}", payment.getCallbackRawData()),
                () -> assertNotNull(payment.getCallbackReceivedAt())
        );
        verify(paymentRepository).save(payment);
    }

    @Test
    void callbackRetryIsIdempotentForSuccessfulPayment() throws Exception {
        Payment payment = pendingPayment();
        payment.setStatus(PaymentStatus.SUCCESS);
        String data = callbackData("10000");
        when(paymentRepository.findByAppTransIdForUpdate("260612_order"))
                .thenReturn(Optional.of(payment));

        Map<String, Object> response = service.handleCallback(callbackRequest(data), "{retry}");

        assertEquals(1, response.get("return_code"));
        verify(paymentRepository, never()).save(payment);
    }

    @Test
    void callbackRejectsAmountMismatch() throws Exception {
        Payment payment = pendingPayment();
        String data = callbackData("9999");
        when(paymentRepository.findByAppTransIdForUpdate("260612_order"))
                .thenReturn(Optional.of(payment));

        Map<String, Object> response = service.handleCallback(callbackRequest(data), "{raw-callback}");

        assertAll(
                () -> assertEquals(2, response.get("return_code")),
                () -> assertEquals(PaymentStatus.PENDING, payment.getStatus()),
                () -> assertEquals(BookingStatus.PENDING, payment.getBooking().getStatus())
        );
        verify(paymentRepository, never()).save(payment);
    }

    private Payment pendingPayment() {
        return Payment.builder()
                .appTransId("260612_order")
                .amount(new BigDecimal("10000.00"))
                .status(PaymentStatus.PENDING)
                .booking(Booking.builder()
                        .id(BOOKING_ID)
                        .status(BookingStatus.PENDING)
                        .build())
                .build();
    }

    private String callbackData(String amount) throws Exception {
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("app_id", 2553);
        data.put("app_trans_id", "260612_order");
        data.put("zp_trans_id", 260612000000001L);
        data.put("amount", new BigDecimal(amount));
        data.put("server_time", 1781236800000L);
        return objectMapper.writeValueAsString(data);
    }

    private ZaloPayCallbackRequest callbackRequest(String data) {
        return ZaloPayCallbackRequest.builder()
                .data(data)
                .mac(HmacUtil.hmacSha256(data, KEY2))
                .type(1)
                .build();
    }
}
