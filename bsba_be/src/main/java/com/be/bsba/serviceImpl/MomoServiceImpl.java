package com.be.bsba.serviceImpl;

import com.be.bsba.config.MomoConfig.MomoApiProperties;
import com.be.bsba.config.MomoConfig.MomoFeignClient;
import com.be.bsba.dto.momo.MomoIpnRequest;
import com.be.bsba.dto.momo.MomoPaymentRequest;
import com.be.bsba.dto.momo.MomoPaymentResponse;
import com.be.bsba.service.MomoService;
import com.be.bsba.util.MomoSignatureUtil;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class MomoServiceImpl implements MomoService {

    private final MomoApiProperties momoProps;
    private final MomoFeignClient momoFeignClient;
    private final ObjectMapper objectMapper;

    @Override
    public MomoPaymentResponse createPayment(String orderId, Long amount, String orderInfo) {
        String requestId = UUID.randomUUID().toString();
        String extraData = "";

        String signature = MomoSignatureUtil.createRequestSignature(
                momoProps.getAccessKey(),
                String.valueOf(amount),
                extraData,
                momoProps.getIpnUrl(),
                orderId,
                orderInfo,
                momoProps.getPartnerCode(),
                momoProps.getRedirectUrl(),
                requestId,
                momoProps.getRequestType(),
                momoProps.getSecretKey()
        );

        MomoPaymentRequest request = MomoPaymentRequest.builder()
                .partnerCode(momoProps.getPartnerCode())
                .requestId(requestId)
                .amount(amount)
                .orderId(orderId)
                .orderInfo(orderInfo)
                .redirectUrl(momoProps.getRedirectUrl())
                .ipnUrl(momoProps.getIpnUrl())
                .requestType(momoProps.getRequestType())
                .extraData(extraData)
                .lang(momoProps.getLang())
                .autoCapture(true)
                .signature(signature)
                .build();

        try {
            String requestJson = objectMapper.writeValueAsString(request);
            log.info("[MoMo] Request Body: {}", requestJson);
            log.info("[MoMo] Generated signature: {}", signature);
        } catch (JsonProcessingException e) {
            log.error("[MoMo] Error serializing request", e);
        }

        log.info("[MoMo] Sending request to MoMo: orderId={}, amount={}, requestId={}", orderId, amount, requestId);
        MomoPaymentResponse response = momoFeignClient.createPayment(request);
        log.info("[MoMo] Response from MoMo: resultCode={}, message={}", response.getResultCode(), response.getMessage());

        return response;
    }

    @Async
    @Override
    public void handleIpn(MomoIpnRequest req) {
        log.info("[MoMo] Received IPN: orderId={}, resultCode={}, transId={}",
                req.getOrderId(), req.getResultCode(), req.getTransId());

        boolean isValid = MomoSignatureUtil.verifyIpnSignature(
                momoProps.getAccessKey(),
                String.valueOf(req.getAmount()),
                req.getExtraData(),
                req.getMessage(),
                req.getOrderId(),
                req.getOrderInfo(),
                req.getOrderType(),
                req.getPartnerCode(),
                req.getPayType(),
                req.getRequestId(),
                String.valueOf(req.getResponseTime()),
                String.valueOf(req.getResultCode()),
                String.valueOf(req.getTransId()),
                momoProps.getSecretKey(),
                req.getSignature()
        );

        if (!isValid) {
            log.error("[MoMo] Invalid IPN signature! orderId={}", req.getOrderId());
            return;
        }

        if (req.getResultCode() == 0) {
            log.info("[MoMo] Payment successful: orderId={}, transId={}", req.getOrderId(), req.getTransId());
            // TODO: Update booking status in database
        } else {
            log.warn("[MoMo] Payment failed: orderId={}, resultCode={}, message={}",
                    req.getOrderId(), req.getResultCode(), req.getMessage());
            // TODO: Update booking status in database
        }
    }
}
