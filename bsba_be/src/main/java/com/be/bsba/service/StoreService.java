package com.be.bsba.service;

import com.be.bsba.dto.request.UpdateStoreRequest;
import com.be.bsba.dto.response.EditStoreResponse;
import com.be.bsba.dto.response.StoreDetailResponse;

import java.util.UUID;

public interface StoreService {

    /**
     * Returns the full detail of a board-games space (store), including:
     * - Store info (name, description, address, location, capacity, rating)
     * - Gallery images
     * - Available board games with quantities
     * - Upcoming time slots
     * - Reviews with reviewer info
     * - Whether the current user has favorited this store
     *
     * @param storeId       the store UUID
     * @param currentUserId (optional) the current user's UUID
     * @return the store detail response
     */
    StoreDetailResponse getStoreDetail(UUID storeId, UUID currentUserId);
    EditStoreResponse getStoreDetailByStaffId(UUID staffId);
    EditStoreResponse updateStoreByStaff(UpdateStoreRequest request);
}
