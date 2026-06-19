package com.be.bsba.repository;

import com.be.bsba.entity.BoardGame;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface BoardGameRepository extends JpaRepository<BoardGame, UUID> {
    @Query("SELECT sbg.boardGame FROM StoreBoardGame sbg WHERE sbg.store.id = :storeId")
    Page<BoardGame> findByStoreId(@Param("storeId") UUID storeId, Pageable pageable);

    java.util.Optional<BoardGame> findByNameIgnoreCase(String name);
}
