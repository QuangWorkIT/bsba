package com.be.bsba.service;

import java.util.UUID;

public interface AvailabilityService {
    /**
     * Calculates the net available quantity of a board game at a specific store
     * for a given time slot, accounting for confirmed bookings and active cart holds.
     */
    int getAvailableQuantity(UUID storeId, UUID boardGameId, UUID slotId);

    /**
     * Checks if a specific quantity of a board game is available.
     */
    boolean isAvailable(UUID storeId, UUID boardGameId, UUID slotId, int requestedQuantity);
}
