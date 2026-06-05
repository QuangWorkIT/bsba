package com.be.bsba.repository;

import com.be.bsba.entity.BookingCart;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.UUID;

public interface BookingCartRepository extends JpaRepository<BookingCart, UUID> {
    Optional<BookingCart> findByUserId(UUID userId);
}
