package com.be.bsba.repository;

import com.be.bsba.entity.StoreTimeSlot;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.Collection;
import java.util.List;
import java.util.UUID;

@Repository
public interface StoreTimeSlotRepository extends JpaRepository<StoreTimeSlot, UUID> {

    /**
     * Today's AVAILABLE slots for several stores, case-insensitive on status.
     *
     * Native + projection on purpose: the seed stores `status` in lowercase
     * ('available'), which would blow up the {@code @Enumerated} mapping if read
     * as an entity. Selecting only the columns we need (as text) sidesteps that
     * and lets UPPER(status) ignore the casing.
     *
     * Each row: [0]=slot id (text), [1]=store id (text), [2]=start time "HH:mm".
     */
    @Query(value = """
            SELECT CAST(id AS text)        AS slot_id,
                   CAST(store_id AS text)  AS store_id,
                   to_char(start_time, 'HH24:MI') AS start_label
            FROM store_time_slots
            WHERE store_id IN (:storeIds)
              AND slot_date = :slotDate
              AND UPPER(status) = 'AVAILABLE'
            ORDER BY start_time
            """, nativeQuery = true)
    List<Object[]> findAvailableSlots(@Param("storeIds") Collection<UUID> storeIds,
                                      @Param("slotDate") LocalDate slotDate);
}
