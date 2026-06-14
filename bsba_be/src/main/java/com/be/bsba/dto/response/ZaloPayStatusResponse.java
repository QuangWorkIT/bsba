package com.be.bsba.dto.response;

import com.be.bsba.constant.BookingStatus;
import com.be.bsba.constant.PaymentStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ZaloPayStatusResponse {
    private UUID paymentId;
    private UUID bookingId;
    private String appTransId;
    private String zpTransId;
    private BigDecimal amount;
    private PaymentStatus status;
    private BookingStatus bookingStatus;
    private OffsetDateTime updatedAt;
}
