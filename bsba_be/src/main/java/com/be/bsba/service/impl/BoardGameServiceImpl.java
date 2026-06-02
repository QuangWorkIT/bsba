package com.be.bsba.service.impl;

import com.be.bsba.dto.BoardGameRequest;
import com.be.bsba.dto.BoardGameResponse;
import com.be.bsba.entity.BoardGame;
import com.be.bsba.repository.BoardGameRepository;
import com.be.bsba.service.BoardGameService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class BoardGameServiceImpl implements BoardGameService {

    private final BoardGameRepository boardGameRepository;

    @Override
    @Transactional(readOnly = true)
    public Page<BoardGameResponse> getAllBoardGames(Pageable pageable) {
        return boardGameRepository.findAll(pageable)
                .map(this::mapToResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public BoardGameResponse getBoardGameById(UUID id) {
        BoardGame boardGame = boardGameRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Board game not found with id: " + id));
        return mapToResponse(boardGame);
    }

    @Override
    @Transactional
    public BoardGameResponse createBoardGame(BoardGameRequest request) {
        BoardGame boardGame = BoardGame.builder()
                .name(request.getName())
                .description(request.getDescription())
                .minPlayers(request.getMinPlayers())
                .maxPlayers(request.getMaxPlayers())
                .playTimeMinutes(request.getPlayTimeMinutes())
                .ageRequirement(request.getAgeRequirement())
                .difficultyLevel(request.getDifficultyLevel())
                .imageUrl(request.getImageUrl())
                .build();
        
        BoardGame savedGame = boardGameRepository.save(boardGame);
        return mapToResponse(savedGame);
    }

    @Override
    @Transactional
    public BoardGameResponse updateBoardGame(UUID id, BoardGameRequest request) {
        BoardGame boardGame = boardGameRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Board game not found with id: " + id));

        boardGame.setName(request.getName());
        boardGame.setDescription(request.getDescription());
        boardGame.setMinPlayers(request.getMinPlayers());
        boardGame.setMaxPlayers(request.getMaxPlayers());
        boardGame.setPlayTimeMinutes(request.getPlayTimeMinutes());
        boardGame.setAgeRequirement(request.getAgeRequirement());
        boardGame.setDifficultyLevel(request.getDifficultyLevel());
        boardGame.setImageUrl(request.getImageUrl());

        BoardGame updatedGame = boardGameRepository.save(boardGame);
        return mapToResponse(updatedGame);
    }

    @Override
    @Transactional
    public void deleteBoardGame(UUID id) {
        if (!boardGameRepository.existsById(id)) {
            throw new RuntimeException("Board game not found with id: " + id);
        }
        boardGameRepository.deleteById(id);
    }

    private BoardGameResponse mapToResponse(BoardGame boardGame) {
        return BoardGameResponse.builder()
                .id(boardGame.getId())
                .name(boardGame.getName())
                .description(boardGame.getDescription())
                .minPlayers(boardGame.getMinPlayers())
                .maxPlayers(boardGame.getMaxPlayers())
                .playTimeMinutes(boardGame.getPlayTimeMinutes())
                .ageRequirement(boardGame.getAgeRequirement())
                .difficultyLevel(boardGame.getDifficultyLevel())
                .imageUrl(boardGame.getImageUrl())
                .createdAt(boardGame.getCreatedAt())
                .build();
    }
}
