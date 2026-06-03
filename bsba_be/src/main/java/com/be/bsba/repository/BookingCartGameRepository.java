package com.be.bsba.repository;

import com.be.bsba.entity.BookingCartGame;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.UUID;

public interface BookingCartGameRepository extends JpaRepository<BookingCartGame, Long> {
    Optional<BookingCartGame> findByCartIdAndBoardGameId(UUID cartId, UUID boardGameId);
}
