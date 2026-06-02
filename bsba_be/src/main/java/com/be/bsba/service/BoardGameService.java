package com.be.bsba.service;

import com.be.bsba.dto.BoardGameRequest;
import com.be.bsba.dto.BoardGameResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.UUID;

public interface BoardGameService {
    Page<BoardGameResponse> getAllBoardGames(Pageable pageable);
    BoardGameResponse getBoardGameById(UUID id);
    BoardGameResponse createBoardGame(BoardGameRequest request);
    BoardGameResponse updateBoardGame(UUID id, BoardGameRequest request);
    void deleteBoardGame(UUID id);
}
