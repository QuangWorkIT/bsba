package com.be.bsba.repository;

import com.be.bsba.entity.FavoriteStore;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface FavoriteStoreRepository extends JpaRepository<FavoriteStore, Long> {

    boolean existsByUserIdAndStoreId(UUID userId, UUID storeId);
}
