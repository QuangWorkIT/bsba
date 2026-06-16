package com.be.bsba.dto.request;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CartItemRequest {
    @NotNull(message = "Board game ID is required")
    private UUID boardGameId;

    @Min(value = 1, message = "Quantity must be at least 1")
    private Integer quantity = 1;

    // Optional store ID if we want to set it during first add
    private UUID storeId;

    // Optional slot ID for booking time context
    private UUID slotId;
}
