//package com.be.bsba.serviceImpl;
//
//import com.be.bsba.dto.request.BoardGameRequest;
//import com.be.bsba.entity.BoardGame;
//import com.be.bsba.repository.BoardGameRepository;
//import com.be.bsba.repository.StoreBoardGameRepository;
//import com.be.bsba.repository.StoreRepository;
//import org.junit.jupiter.api.Test;
//import org.junit.jupiter.api.extension.ExtendWith;
//import org.mockito.Mock;
//import org.mockito.junit.jupiter.MockitoExtension;
//
//import java.util.UUID;
//
//@ExtendWith(MockitoExtension.class)
//public class BoardGameServiceImplTests {
//    @Mock
//    private BoardGameRepository boardGameRepository;
//
//    @Mock
//    private StoreRepository storeRepository;
//
//    @Mock
//    private StoreBoardGameRepository storeBoardGameRepository;
//
//    @Mock
//    private BoardGameServiceImpl boardGameService;
//
//    @Test
//    void createBoardGame_WithStoreId_SavesGameAndLinksToStore() {
//        UUID storeId = UUID.randomUUID();
//        BoardGameRequest request = BoardGameRequest
//                .builder()
//                .name("Catan")
//                .description("A strategy board game")
//                .minPlayers(3)
//                .maxPlayers(4)
//                .playTimeMinutes(60)
//                .ageRequirement(10)
//                .quantity(3)
//                .category("Strategy")
//                .imageUrl("https://example.com/catan.jpg")
//                .storeId(storeId)
//                .build();
//
//        BoardGame savedGame = BoardGame.builder()
//                .id()
//
//    }
//}
