package com.be.bsba.serviceImpl;

import com.be.bsba.dto.request.BoardGameRequest;
import com.be.bsba.dto.response.BoardGameResponse;
import com.be.bsba.entity.BoardGame;
import com.be.bsba.entity.Store;
import com.be.bsba.entity.StoreBoardGame;
import com.be.bsba.repository.BoardGameRepository;
import com.be.bsba.repository.StoreBoardGameRepository;
import com.be.bsba.repository.StoreRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class BoardGameServiceImplTests {

    @Mock
    private BoardGameRepository boardGameRepository;

    @Mock
    private StoreRepository storeRepository;

    @Mock
    private StoreBoardGameRepository storeBoardGameRepository;

    @InjectMocks
    private BoardGameServiceImpl boardGameService;

    @Test
    void createBoardGame_WithStoreId_SavesGameAndLinksToStore() {
        UUID storeId = UUID.randomUUID();
        BoardGameRequest request = BoardGameRequest.builder()
                .name("Catan")
                .description("A strategy board game")
                .minPlayers(3)
                .maxPlayers(4)
                .playTimeMinutes(60)
                .ageRequirement(10)
                .quantity(3)
                .category("Strategy")
                .imageUrl("https://example.com/catan.jpg")
                .storeId(storeId)
                .difficultyLevel(3)
                .rentalPrice(BigDecimal.TEN)
                .build();

        UUID gameId = UUID.randomUUID();
        BoardGame savedGame = BoardGame.builder()
                .id(gameId)
                .name(request.getName())
                .description(request.getDescription())
                .minPlayers(request.getMinPlayers())
                .maxPlayers(request.getMaxPlayers())
                .playTimeMinutes(request.getPlayTimeMinutes())
                .ageRequirement(request.getAgeRequirement())
                .difficultyLevel(request.getDifficultyLevel())
                .imageUrl(request.getImageUrl())
                .category(request.getCategory())
                .rentalPrice(request.getRentalPrice())
                .build();

        Store store = Store.builder()
                .id(storeId)
                .name("Store A")
                .description("Store A description")
                .build();

        when(boardGameRepository.save(any(BoardGame.class))).thenReturn(savedGame);
        when(storeRepository.findById(storeId)).thenReturn(Optional.of(store));
        when(storeBoardGameRepository.save(any(StoreBoardGame.class))).thenReturn(new StoreBoardGame());

        BoardGameResponse response = boardGameService.createBoardGame(request);

        assertNotNull(response);
        assertEquals(gameId, response.getId());
        assertEquals("Catan", response.getName());

        verify(boardGameRepository, times(1)).save(any(BoardGame.class));
        verify(storeRepository, times(1)).findById(storeId);
        verify(storeBoardGameRepository, times(1)).save(any(StoreBoardGame.class));
    }
}
