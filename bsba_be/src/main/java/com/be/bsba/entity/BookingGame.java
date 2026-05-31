package com.be.bsba.entity;

import jakarta.persistence.*;
import lombok.*;


@Entity
@Table(name = "booking_games")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BookingGame {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "booking_id",
            nullable = false
    )
    private Booking booking;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "board_game_id",
            nullable = false
    )
    private BoardGame boardGame;

    @Column(nullable = false)
    private Integer quantity = 1;
}