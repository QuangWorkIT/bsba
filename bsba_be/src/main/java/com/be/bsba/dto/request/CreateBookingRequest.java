package com.be.bsba.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class CreateBookingRequest {
    private Integer participantCount;
    private BigDecimal totalPrice;
    private String note;
    @NotNull(message = "User ID cannot be null")
    private String userId;
    @NotNull(message = "Store ID cannot be null")
    private String storeId;
    @NotNull(message = "Slot ID cannot be null")
    private String slotId;
}
