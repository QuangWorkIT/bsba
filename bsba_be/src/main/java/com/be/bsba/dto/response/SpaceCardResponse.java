package com.be.bsba.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SpaceCardResponse {
    private UUID id;
    private String name;
    private String coverImageUrl;
    private BigDecimal ratingAvg;
    private Double distanceMiles;       // null when the caller sends no location
    private String description;
    private List<String> featuredGames;
    private List<SpaceSlotResponse> availableSlotsToday;
}
