package com.be.bsba.controller;

import com.be.bsba.dto.request.UpdateStoreRequest;
import com.be.bsba.dto.response.ApiResponse;
import com.be.bsba.dto.response.EditStoreResponse;
import com.be.bsba.dto.response.BoardGameDto;
import com.be.bsba.dto.response.StoreDetailResponse;
import com.be.bsba.service.StoreService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;
import org.springframework.security.core.context.SecurityContextHolder;
import com.be.bsba.repository.UserRepository;
import com.be.bsba.entity.User;
import com.be.bsba.exception.BadRequestException;

@RestController
@RequestMapping("/api/v1/stores")
@RequiredArgsConstructor
public class StoreController {

    private final StoreService storeService;
    private final UserRepository userRepository;

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<StoreDetailResponse>> getStoreDetail(
            @PathVariable UUID id,
            @RequestHeader(value = "X-User-Id", required = false) UUID userId) {
        StoreDetailResponse detail = storeService.getStoreDetail(id, userId);
        return ResponseEntity.ok(ApiResponse.success(detail, "Success"));
    }

    @GetMapping("/staff/{staffId}")
    public ResponseEntity<ApiResponse<EditStoreResponse>> getStoreDetailByStaffId(
            @PathVariable UUID staffId
    ) {
        EditStoreResponse detail = storeService.getStoreDetailByStaffId(staffId);
        return ResponseEntity.ok(ApiResponse.success(detail, "Find store by staff id success"));
    }

    @PutMapping("/staff")
    public ResponseEntity<ApiResponse<EditStoreResponse>> updateStoreByStaff(
            @Valid @RequestBody UpdateStoreRequest request
    ) {
        EditStoreResponse detail = storeService.updateStoreByStaff(request);
        return ResponseEntity.ok(ApiResponse.success(detail, "Update store by staff success"));
    }

    @GetMapping("/staff/board-games")
    public ResponseEntity<ApiResponse<List<BoardGameDto>>> getStaffBoardGames() {
        String email = (String) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new BadRequestException("User not found"));

        List<BoardGameDto> games = storeService.getGamesForStaffStore(user.getId());
        return ResponseEntity.ok(ApiResponse.success(games, "Staff board games retrieved successfully"));
    }
}
