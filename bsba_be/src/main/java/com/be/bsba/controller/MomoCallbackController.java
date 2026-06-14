package com.be.bsba.controller;

import com.be.bsba.dto.momo.MomoIpnRequest;
import com.be.bsba.dto.momo.MomoIpnResponse;
import com.be.bsba.service.MomoService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.view.RedirectView;

@Slf4j
@RestController
@RequestMapping("/api/v1/momo")
@RequiredArgsConstructor
public class MomoCallbackController {

    private final MomoService momoService;

    @PostMapping("/ipn")
    public ResponseEntity<MomoIpnResponse> handleIpn(@RequestBody MomoIpnRequest ipnRequest) {
        log.debug("[MoMo] IPN received: {}", ipnRequest);
        momoService.handleIpn(ipnRequest);
        return ResponseEntity.ok(new MomoIpnResponse(0, "Success"));
    }

    @GetMapping("/redirect")
    public RedirectView handleRedirect(
            @RequestParam String orderId,
            @RequestParam Integer resultCode,
            @RequestParam(required = false) String message) {

        log.info("[MoMo] User redirect: orderId={}, resultCode={}", orderId, resultCode);

        // TODO: Update these URLs with the actual FE production/sandbox URLs
        if (resultCode == 0) {
            return new RedirectView("bsba://payment-success?orderId=" + orderId);
        }
        return new RedirectView("bsba://payment-fail?orderId=" + orderId + "&reason=" + message);
    }
}
