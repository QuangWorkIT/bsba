package com.be.bsba.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "board_games")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BoardGame {

    @Id
    @GeneratedValue
    private UUID id;

    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;

    private Integer minPlayers;

    private Integer maxPlayers;

    private Integer playTimeMinutes;

    private Integer ageRequirement;

    private Integer difficultyLevel;

    private String imageUrl;

    @CreationTimestamp
    private OffsetDateTime createdAt;

    @OneToMany(mappedBy = "boardGame")
    private List<StoreBoardGame> storeBoardGames;
}