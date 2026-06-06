package com.be.bsba.repository;

import com.be.bsba.entity.StoreBoardGame;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;
import java.util.UUID;

@Repository
public interface StoreBoardGameRepository extends JpaRepository<StoreBoardGame, Long> {

    List<StoreBoardGame> findByStoreId(UUID storeId);

    // Batch-fetch the games of several stores at once (JOIN FETCH avoids N+1).
    @Query("SELECT sbg FROM StoreBoardGame sbg JOIN FETCH sbg.boardGame " +
            "WHERE sbg.store.id IN :storeIds")
    List<StoreBoardGame> findByStoreIdInFetchGame(@Param("storeIds") Collection<UUID> storeIds);
}
