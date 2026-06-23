package com.be.bsba.repository;

import com.be.bsba.constant.BookingStatus;
import com.be.bsba.entity.Booking;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface BookingRepository extends JpaRepository<Booking, UUID> {

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT b FROM Booking b JOIN FETCH b.user WHERE b.id = :id")
    Optional<Booking> findByIdForUpdate(@Param("id") UUID id);

    java.util.List<Booking> findAllByUserIdOrderByCreatedAtDesc(UUID userId);

    Optional<Booking> findFirstByUserIdAndStoreIdAndStatusOrderByCreatedAtDesc(
            UUID userId,
            UUID storeId,
            BookingStatus status);

    boolean existsByUserIdAndSlotId(UUID userId, UUID slotId);
}
