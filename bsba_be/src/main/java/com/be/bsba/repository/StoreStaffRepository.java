package com.be.bsba.repository;

import com.be.bsba.entity.StoreStaff;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface StoreStaffRepository extends JpaRepository<StoreStaff, Long> {

    @Query("SELECT ss.store.id FROM StoreStaff ss WHERE ss.staff.id = :staffId")
    List<UUID> findStoreIdsByStaffId(@Param("staffId") UUID staffId);

    @Query("SELECT ss.staff.id FROM StoreStaff ss WHERE ss.store.id = :storeId")
    List<UUID> findStaffIdsByStoreId(@Param("storeId") UUID storeId);

    boolean existsByStoreIdAndStaffId(UUID storeId, UUID staffId);
}
