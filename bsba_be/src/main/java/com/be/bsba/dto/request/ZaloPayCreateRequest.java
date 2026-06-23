package com.be.bsba.dto.request;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
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
public class ZaloPayCreateRequest {

    @NotNull(message = "bookingId is required")
    private UUID bookingId;

    @NotNull(message = "totalPrice is required")
    @Positive
    private BigDecimal totalPrice;
}

