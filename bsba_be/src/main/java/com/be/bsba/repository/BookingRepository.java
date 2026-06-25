package com.be.bsba.repository;

import com.be.bsba.constant.BookingStatus;
import com.be.bsba.entity.Booking;
import jakarta.persistence.LockModeType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface BookingRepository extends JpaRepository<Booking, UUID> {

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT b FROM Booking b JOIN FETCH b.user WHERE b.id = :id")
    Optional<Booking> findByIdForUpdate(@Param("id") UUID id);

    List<Booking> findByUserIdAndStoreIdAndStatusOrderBySlotSlotDateAscSlotStartTimeAsc(
            UUID userId,
            UUID storeId,
            BookingStatus status);

    boolean existsByUserIdAndSlotId(UUID userId, UUID slotId);
    // Customer "My Bookings": their own, newest first.
    List<Booking> findAllByUserIdOrderByCreatedAtDesc(UUID userId);

    // Staff "Manage Bookings": paged, role-aware, with an optional status filter.
    Page<Booking> findByUserId(UUID userId, Pageable pageable);

    Page<Booking> findByUserIdAndStatus(UUID userId, BookingStatus status, Pageable pageable);

    Page<Booking> findByStoreIdIn(Collection<UUID> storeIds, Pageable pageable);

    Page<Booking> findByStoreIdInAndStatus(Collection<UUID> storeIds, BookingStatus status, Pageable pageable);

    Page<Booking> findByStatus(BookingStatus status, Pageable pageable);
}
