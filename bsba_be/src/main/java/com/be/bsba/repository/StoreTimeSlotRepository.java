package com.be.bsba.repository;

import com.be.bsba.entity.StoreTimeSlot;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Repository
public interface StoreTimeSlotRepository extends JpaRepository<StoreTimeSlot, UUID> {

    List<StoreTimeSlot> findByStoreIdAndSlotDateGreaterThanEqualOrderBySlotDateAscStartTimeAsc(
            UUID storeId, LocalDate fromDate);
}
