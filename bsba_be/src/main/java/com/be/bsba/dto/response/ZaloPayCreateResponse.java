package com.be.bsba.dto.response;

import com.be.bsba.constant.PaymentStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ZaloPayCreateResponse {
    private UUID paymentId;
    private UUID bookingId;
    private String orderUrl;
    private String appTransId;
    private String zpTransToken;
    private BigDecimal amount;
    private PaymentStatus status;
}
