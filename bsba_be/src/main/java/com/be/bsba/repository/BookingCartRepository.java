package com.be.bsba.repository;

import com.be.bsba.entity.BookingCart;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.UUID;

public interface BookingCartRepository extends JpaRepository<BookingCart, UUID> {
    @EntityGraph(attributePaths = {"booking", "booking.user", "booking.store", "booking.slot"})
    Optional<BookingCart> findByBookingUserId(UUID userId);

    @EntityGraph(attributePaths = {"booking", "booking.user", "booking.store", "booking.slot"})
    Optional<BookingCart> findByBookingId(UUID bookingId);

    boolean existsByBookingId(UUID bookingId);
}
