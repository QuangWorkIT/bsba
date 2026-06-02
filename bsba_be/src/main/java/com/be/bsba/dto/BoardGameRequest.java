package com.be.bsba.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BoardGameRequest {
    @NotBlank(message = "Name is required")
    private String name;

    private String description;

    @Min(value = 1, message = "Min players must be at least 1")
    private Integer minPlayers;

    private Integer maxPlayers;

    private Integer playTimeMinutes;

    private Integer ageRequirement;

    @Min(value = 1, message = "Difficulty level must be between 1 and 5")
    @Max(value = 5, message = "Difficulty level must be between 1 and 5")
    private Integer difficultyLevel;

    private String imageUrl;
}
