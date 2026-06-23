package com.be.bsba.dto.request;

import com.fasterxml.jackson.annotation.JsonAlias;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class UpdateItemCartQuantityRequest {
    @NotNull(message = "Cart ID is required")
    private UUID cartId;

    @JsonAlias("boardgameId")
    @NotNull(message = "Board game ID is required")
    private UUID boardGameId;

    @NotNull(message = "Quantity is required")
    @Min(value = 0, message = "Quantity must be greater than or equal to 0")
    private Integer quantity;
}
