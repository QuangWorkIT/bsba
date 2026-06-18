package com.be.bsba.controller;

import com.be.bsba.dto.request.BoardGameRequest;
import com.be.bsba.dto.response.ApiResponse;
import com.be.bsba.dto.response.BoardGameResponse;
import com.be.bsba.service.BoardGameService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/board-games")
@RequiredArgsConstructor
public class BoardGameController {

    private final BoardGameService boardGameService;
    private final com.be.bsba.repository.UserRepository userRepository;
    private final com.be.bsba.repository.StoreStaffRepository storeStaffRepository;

    @GetMapping
    public ApiResponse<Page<BoardGameResponse>> getAllBoardGames(Pageable pageable) {
        Page<BoardGameResponse> games = boardGameService.getAllBoardGames(pageable);
        return ApiResponse.success(games, "Board games retrieved successfully");
    }

    @GetMapping("/{id}")
    public ApiResponse<BoardGameResponse> getBoardGameById(@PathVariable UUID id) {
        BoardGameResponse game = boardGameService.getBoardGameById(id);
        return ApiResponse.success(game, "Board game retrieved successfully");
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<BoardGameResponse> createBoardGame(@Valid @RequestBody BoardGameRequest request) {
        if (request.getStoreId() == null) {
            String email = (String) org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication().getPrincipal();
            com.be.bsba.entity.User user = userRepository.findByEmail(email)
                    .orElseThrow(() -> new com.be.bsba.exception.BadRequestException("User not found"));
            java.util.List<UUID> storeIds = storeStaffRepository.findStoreIdsByStaffId(user.getId());
            if (!storeIds.isEmpty()) {
                request.setStoreId(storeIds.get(0));
            } else {
                throw new com.be.bsba.exception.BadRequestException("Staff user is not associated with any store");
            }
        }
        BoardGameResponse game = boardGameService.createBoardGame(request);
        return ApiResponse.success(game, "Board game created successfully");
    }

    @PutMapping("/{id}")
    public ApiResponse<BoardGameResponse> updateBoardGame(@PathVariable UUID id, @Valid @RequestBody BoardGameRequest request) {
        BoardGameResponse game = boardGameService.updateBoardGame(id, request);
        return ApiResponse.success(game, "Board game updated successfully");
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public ApiResponse<Void> deleteBoardGame(@PathVariable UUID id) {
        boardGameService.deleteBoardGame(id);
        return ApiResponse.success(null, "Board game deleted successfully");
    }
}
