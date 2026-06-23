package com.be.bsba.controller;

import com.be.bsba.dto.momo.MomoPaymentResponse;
import com.be.bsba.dto.request.ZaloPayCallbackRequest;
import com.be.bsba.dto.request.ZaloPayCreateRequest;
import com.be.bsba.dto.response.ApiResponse;
import com.be.bsba.dto.response.ZaloPayCreateResponse;
import com.be.bsba.dto.response.ZaloPayStatusResponse;
import com.be.bsba.service.MomoService;
import com.be.bsba.service.ZaloPayService;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Slf4j
@RestController
@RequestMapping({"/api/v1/payments", "/api/v1/payment"})
@RequiredArgsConstructor
public class PaymentController {

    private final MomoService momoService;
    private final ZaloPayService zaloPayService;
    private final ObjectMapper objectMapper;

    @PostMapping("/momo/create")
    public ResponseEntity<?> createMomoPayment(
            @RequestParam String orderId,
            @RequestParam Long amount,
            @RequestParam String orderInfo) {

        MomoPaymentResponse response = momoService.createPayment(orderId, amount, orderInfo);

        if (response.getResultCode() == 0 && response.getPayUrl() != null) {
            return ResponseEntity.ok(Map.of(
                    "payUrl", response.getPayUrl(),
                    "orderId", orderId,
                    "message", "Payment link created successfully"
            ));
        }

        return ResponseEntity.badRequest().body(Map.of(
                "error", "Could not create payment link",
                "resultCode", response.getResultCode(),
                "message", response.getMessage()
        ));
    }

    @PostMapping("/zalopay/create")
    public ResponseEntity<ApiResponse<ZaloPayCreateResponse>> createZaloPayPayment(
            @Valid @RequestBody ZaloPayCreateRequest request,
            @AuthenticationPrincipal String authenticatedEmail) {
        ZaloPayCreateResponse response = zaloPayService.createPayment(request, authenticatedEmail);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(response, "ZaloPay payment created successfully"));
    }

    @PostMapping(
            value = "/zalopay/callback",
            consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public ResponseEntity<Map<String, Object>> handleZaloPayCallback(@RequestBody String rawBody) {
        try {
            log.info("[ZaloPay] Received callback: {}", rawBody);
            ZaloPayCallbackRequest request = objectMapper.readValue(rawBody, ZaloPayCallbackRequest.class);
            return ResponseEntity.ok(zaloPayService.handleCallback(request, rawBody));
        } catch (JsonProcessingException e) {
            log.warn("[ZaloPay] Invalid callback JSON", e);
            return ResponseEntity.ok(Map.of(
                    "return_code", 2,
                    "return_message", "invalid callback JSON"
            ));
        }
    }

    @GetMapping("/zalopay/status/{appTransId}")
    public ResponseEntity<ApiResponse<ZaloPayStatusResponse>> getZaloPayStatus(
            @PathVariable String appTransId,
            @AuthenticationPrincipal String authenticatedEmail) {
        ZaloPayStatusResponse response = zaloPayService.getPaymentStatus(appTransId, authenticatedEmail);
        return ResponseEntity.ok(ApiResponse.success(response, "Payment status retrieved successfully"));
    }
}
