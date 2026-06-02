package com.be.bsba.dto.response;

import lombok.*;

import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BoardGameDto {

    private UUID id;
    private String name;
    private String description;
    private Integer minPlayers;
    private Integer maxPlayers;
    private Integer playTimeMinutes;
    private Integer ageRequirement;
    private Integer difficultyLevel;
    private String imageUrl;
    private Integer quantity; // quantity available at this store
}
