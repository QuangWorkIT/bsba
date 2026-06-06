package com.be.bsba.controller;

import com.be.bsba.dto.momo.MomoPaymentResponse;
import com.be.bsba.service.MomoService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/payment")
@RequiredArgsConstructor
public class PaymentController {

    private final MomoService momoService;

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
}
