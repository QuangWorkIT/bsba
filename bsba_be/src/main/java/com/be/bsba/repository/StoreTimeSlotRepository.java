package com.be.bsba.repository;

import com.be.bsba.constant.TimeSlotStatus;
import com.be.bsba.entity.StoreTimeSlot;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.Collection;
import java.util.List;
import java.util.UUID;

@Repository
public interface StoreTimeSlotRepository extends JpaRepository<StoreTimeSlot, UUID> {

    // Batch-fetch one day's slots (in a given status) for several stores at once.
    List<StoreTimeSlot> findByStoreIdInAndSlotDateAndStatusOrderByStartTimeAsc(
            Collection<UUID> storeIds, LocalDate slotDate, TimeSlotStatus status);
}
