package com.be.bsba.dto.response;

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
public class BoardGameResponse {
    private UUID id;
    private String name;
    private String description;
    private Integer minPlayers;
    private Integer maxPlayers;
    private Integer playTimeMinutes;
    private Integer ageRequirement;
    private Integer difficultyLevel;
    private String imageUrl;
    private String category;
    private BigDecimal rentalPrice;
    private String storeName;
    private String storeDescription;
    private OffsetDateTime createdAt;
}
