package com.be.bsba.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(
        name = "booking_cart_games",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uq_cart_game",
                        columnNames = {
                                "cart_id",
                                "board_game_id"
                        }
                )
        }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BookingCartGame {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "cart_id",
            nullable = false
    )
    private BookingCart cart;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "board_game_id",
            nullable = false
    )
    private BoardGame boardGame;

    @Column(nullable = false)
    private Integer quantity = 1;
}