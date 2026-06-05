package com.be.bsba.dto.momo;

import lombok.Data;

@Data
public class MomoPaymentResponse {
    private String partnerCode;
    private String orderId;
    private String requestId;
    private Long amount;
    private Long responseTime;
    private String message;
    private Integer resultCode;
    private String payUrl;
    private String shortLink;
    private String deeplink;
    private String qrCodeUrl;
}
