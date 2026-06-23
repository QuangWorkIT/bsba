package com.be.bsba.dto.request;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class AddItemCartRequest {
    @NotNull(message = "Booking cart ID is required")
    private UUID bookingCartId;
    @NotNull(message = "Board game ID is required")
    private UUID boardGameId;
    @NotNull(message = "Quantity is required")
    @Positive(message = "Quantity must be a positive integer")
    private Integer quantity;
}
