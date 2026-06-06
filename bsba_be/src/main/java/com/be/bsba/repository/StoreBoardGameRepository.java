package com.be.bsba.repository;

import com.be.bsba.entity.StoreBoardGame;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface StoreBoardGameRepository extends JpaRepository<StoreBoardGame, Long> {

    List<StoreBoardGame> findByStoreId(UUID storeId);
}
