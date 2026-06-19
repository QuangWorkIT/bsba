package com.be.bsba.serviceImpl;

import com.be.bsba.constant.BookingStatus;
import com.be.bsba.entity.*;
import com.be.bsba.repository.*;
import com.be.bsba.service.AvailabilityService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AvailabilityServiceImpl implements AvailabilityService {

    private final StoreBoardGameRepository storeBoardGameRepository;
    private final BookingRepository bookingRepository;
    private final BookingCartRepository bookingCartRepository;

    @Override
    @Transactional(readOnly = true)
    public int getAvailableQuantity(UUID storeId, UUID boardGameId, UUID slotId) {
        // 1. Get total stock at the store
        int totalStock = storeBoardGameRepository.findByStoreId(storeId).stream()
                .filter(sbg -> sbg.getBoardGame().getId().equals(boardGameId))
                .findFirst()
                .map(StoreBoardGame::getQuantity)
                .orElse(0);

        if (totalStock == 0) return 0;

        // 2. Count quantities from confirmed/pending bookings for this slot
        // Note: In a real system, we'd use a more efficient JPQL/Native query
        int bookedQuantity = 0;
        List<Booking> bookings = bookingRepository.findAll().stream()
                .filter(b -> b.getStore().getId().equals(storeId))
                .filter(b -> b.getSlot() != null && b.getSlot().getId().equals(slotId))
                .filter(b -> b.getStatus() == BookingStatus.CONFIRMED || b.getStatus() == BookingStatus.PENDING)
                .toList();
        
        for (Booking b : bookings) {
            if (b.getGames() != null) {
                bookedQuantity += b.getGames().stream()
                        .filter(bg -> bg.getBoardGame().getId().equals(boardGameId))
                        .mapToInt(BookingGame::getQuantity)
                        .sum();
            }
        }

        // 3. Count quantities from active carts (temporary hold - e.g., 15 minutes)
        // Active carts are those updated within the last 15 minutes
        OffsetDateTime threshold = OffsetDateTime.now().minusMinutes(15);
        int reservedInCarts = 0;
        List<BookingCart> activeCarts = bookingCartRepository.findAll().stream()
                .filter(c -> c.getStoreId().equals(storeId))
                .filter(c -> c.getSlotId() != null && c.getSlotId().equals(slotId))
                .filter(c -> c.getUpdatedAt().isAfter(threshold))
                .toList();

        for (BookingCart cart : activeCarts) {
            if (cart.getItems() != null) {
                reservedInCarts += cart.getItems().stream()
                        .filter(item -> item.getBoardGame().getId().equals(boardGameId))
                        .mapToInt(BookingCartGame::getQuantity)
                        .sum();
            }
        }

        int available = totalStock - bookedQuantity - reservedInCarts;
        return Math.max(0, available);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isAvailable(UUID storeId, UUID boardGameId, UUID slotId, int requestedQuantity) {
        if (slotId == null) return true; // Global browse - assume available for now
        int available = getAvailableQuantity(storeId, boardGameId, slotId);
        return available >= requestedQuantity;
    }
}
