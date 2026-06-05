package com.be.bsba.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.be.bsba.entity.Store;

@Repository
public interface StoreRepository extends JpaRepository<Store, UUID> {

    List<Store> findByIsActiveTrue();

    // Active stores matching a free-text query on name or description.
    @Query("SELECT s FROM Store s WHERE s.isActive = true AND (" +
            "LOWER(s.name) LIKE LOWER(CONCAT('%', :q, '%')) OR " +
            "LOWER(s.description) LIKE LOWER(CONCAT('%', :q, '%')))")
    List<Store> searchActive(@Param("q") String q);
    
    Optional<Store> findByIdAndIsActiveTrue(UUID id);
}
