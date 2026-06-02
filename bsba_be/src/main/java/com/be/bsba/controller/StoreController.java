package com.be.bsba.controller;

import com.be.bsba.dto.response.ApiResponse;
import com.be.bsba.dto.response.StoreDetailResponse;
import com.be.bsba.service.StoreService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/stores")
@RequiredArgsConstructor
public class StoreController {

    private final StoreService storeService;

    /**
     * GET /api/stores/{id}
     *
     * Returns the full detail of a board-games space (store), including:
     * - Store info (name, description, address, location, capacity, rating)
     * - Gallery images
     * - Available board games with quantities
     * - Upcoming time slots
     * - Reviews with reviewer info
     * - Whether the current user has favorited this store
     *
     * @param id         the store UUID
     * @param userId     (optional) the current user's UUID, passed as a request header
     */
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<StoreDetailResponse>> getStoreDetail(
            @PathVariable UUID id,
            @RequestHeader(value = "X-User-Id", required = false) UUID userId
    ) {
        StoreDetailResponse detail = storeService.getStoreDetail(id, userId);
        return ResponseEntity.ok(ApiResponse.success(detail));
    }
}
