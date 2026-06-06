package com.be.bsba.repository;

import com.be.bsba.entity.Store;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface StoreRepository extends JpaRepository<Store, UUID> {
    Optional<Store> findByIdAndIsActiveTrue(UUID id);
}
