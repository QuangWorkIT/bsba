package com.be.bsba.dto.request;

import com.fasterxml.jackson.annotation.JsonAlias;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class DeleteItemCartRequest {
    @NotNull(message = "Cart ID is required")
    private UUID cartId;

    @JsonAlias("boardgameId")
    @NotNull(message = "Board game ID is required")
    private UUID boardGameId;
}
