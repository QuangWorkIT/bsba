package com.be.bsba.repository;

import com.be.bsba.entity.BoardGame;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface BoardGameRepository extends JpaRepository<BoardGame, UUID> {
}
