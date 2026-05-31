package com.be.bsba.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "store_board_games")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StoreBoardGame {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "store_id",
            nullable = false
    )
    private Store store;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "board_game_id",
            nullable = false
    )
    private BoardGame boardGame;

    @Column(nullable = false)
    private Integer quantity;
}