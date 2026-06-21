package com.be.bsba.serviceImpl;

import com.be.bsba.dto.request.BoardGameRequest;
import com.be.bsba.dto.response.BoardGameResponse;
import com.be.bsba.entity.BoardGame;
import com.be.bsba.entity.Store;
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
    private final com.be.bsba.repository.StoreRepository storeRepository;
    private final com.be.bsba.repository.StoreBoardGameRepository storeBoardGameRepository;

    @Override
    @Transactional(readOnly = true)
    public Page<BoardGameResponse> getAllBoardGames(UUID storeId, Pageable pageable) {
        if (storeId != null) {
            return boardGameRepository.findByStoreId(storeId, pageable)
                    .map(this::mapToResponse);
        }
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
                .difficultyLevel(request.getDifficultyLevel() != null ? request.getDifficultyLevel() : 3)
                .imageUrl(request.getImageUrl())
                .category(request.getCategory() != null ? request.getCategory() : "General")
                .rentalPrice(request.getRentalPrice() != null ? request.getRentalPrice() : java.math.BigDecimal.ZERO)
                .build();
        
        BoardGame savedGame = boardGameRepository.save(boardGame);

        if (request.getStoreId() != null) {
            com.be.bsba.entity.Store store = storeRepository.findById(request.getStoreId())
                    .orElseThrow(() -> new RuntimeException("Store not found with id: " + request.getStoreId()));
            com.be.bsba.entity.StoreBoardGame storeBoardGame = com.be.bsba.entity.StoreBoardGame.builder()
                    .store(store)
                    .boardGame(savedGame)
                    .quantity(request.getQuantity() != null ? request.getQuantity() : 1)
                    .build();
            storeBoardGameRepository.save(storeBoardGame);
        }

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
        boardGame.setCategory(request.getCategory());
        boardGame.setRentalPrice(request.getRentalPrice());

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
        BoardGameResponse.BoardGameResponseBuilder builder = BoardGameResponse.builder()
                .id(boardGame.getId())
                .name(boardGame.getName())
                .description(boardGame.getDescription())
                .minPlayers(boardGame.getMinPlayers())
                .maxPlayers(boardGame.getMaxPlayers())
                .playTimeMinutes(boardGame.getPlayTimeMinutes())
                .ageRequirement(boardGame.getAgeRequirement())
                .difficultyLevel(boardGame.getDifficultyLevel())
                .imageUrl(boardGame.getImageUrl())
                .category(boardGame.getCategory())
                .rentalPrice(boardGame.getRentalPrice())
                .createdAt(boardGame.getCreatedAt());

        if (boardGame.getStoreBoardGames() != null && !boardGame.getStoreBoardGames().isEmpty()) {
            Store primaryStore = boardGame.getStoreBoardGames().get(0).getStore();
            if (primaryStore != null) {
                builder.storeName(primaryStore.getName());
                builder.storeDescription(primaryStore.getDescription());
            }
        }

        return builder.build();
    }
}
