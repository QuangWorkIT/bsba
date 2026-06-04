package com.be.bsba.service.impl;

import com.be.bsba.dto.response.*;
import com.be.bsba.entity.*;
import com.be.bsba.exception.ResourceNotFoundException;
import com.be.bsba.repository.*;
import com.be.bsba.service.StoreService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class StoreServiceImpl implements StoreService {

    private final StoreRepository storeRepository;
    private final StoreImageRepository storeImageRepository;
    private final StoreBoardGameRepository storeBoardGameRepository;
    private final StoreTimeSlotRepository storeTimeSlotRepository;
    private final ReviewRepository reviewRepository;
    private final FavoriteStoreRepository favoriteStoreRepository;

    @Override
    @Transactional(readOnly = true)
    public StoreDetailResponse getStoreDetail(UUID storeId, UUID currentUserId) {

        // 1. Fetch the store (must be active)
        Store store = storeRepository.findByIdAndIsActiveTrue(storeId)
                .orElseThrow(() -> new ResourceNotFoundException("Store", "id", storeId));

        // 2. Fetch store images
        List<StoreImageDto> images = storeImageRepository
                .findByStoreIdOrderByDisplayOrderAsc(storeId)
                .stream()
                .map(this::toStoreImageDto)
                .toList();

        // 3. Fetch board games available at this store
        List<BoardGameDto> boardGames = storeBoardGameRepository
                .findByStoreId(storeId)
                .stream()
                .map(this::toBoardGameDto)
                .toList();

        // 4. Fetch upcoming time slots (from today onwards)
        List<TimeSlotDto> timeSlots = storeTimeSlotRepository
                .findByStoreIdAndSlotDateGreaterThanEqualOrderBySlotDateAscStartTimeAsc(
                        storeId, LocalDate.now())
                .stream()
                .map(this::toTimeSlotDto)
                .toList();

        // 5. Fetch reviews
        List<ReviewDto> reviews = reviewRepository
                .findByStoreIdOrderByCreatedAtDesc(storeId)
                .stream()
                .map(this::toReviewDto)
                .toList();

        long reviewCount = reviewRepository.countByStoreId(storeId);

        // 6. Check if current user has favorited this store
        boolean isFavorited = false;
        if (currentUserId != null) {
            isFavorited = favoriteStoreRepository.existsByUserIdAndStoreId(currentUserId, storeId);
        }

        // 7. Build response
        return StoreDetailResponse.builder()
                .id(store.getId())
                .name(store.getName())
                .description(store.getDescription())
                .address(store.getAddress())
                .latitude(store.getLatitude())
                .longitude(store.getLongitude())
                .phone(store.getPhone())
                .email(store.getEmail())
                .coverImageUrl(store.getCoverImageUrl())
                .totalCapacity(store.getTotalCapacity())
                .ratingAvg(store.getRatingAvg())
                .reviewCount(reviewCount)
                .isFavorited(isFavorited)
                .images(images)
                .boardGames(boardGames)
                .timeSlots(timeSlots)
                .reviews(reviews)
                .build();
    }

    // ── Mapping helpers ──────────────────────────────────────────────

    private StoreImageDto toStoreImageDto(StoreImage image) {
        return StoreImageDto.builder()
                .id(image.getId())
                .imageUrl(image.getImageUrl())
                .displayOrder(image.getDisplayOrder())
                .build();
    }

    private BoardGameDto toBoardGameDto(StoreBoardGame sbg) {
        BoardGame game = sbg.getBoardGame();
        return BoardGameDto.builder()
                .id(game.getId())
                .name(game.getName())
                .description(game.getDescription())
                .minPlayers(game.getMinPlayers())
                .maxPlayers(game.getMaxPlayers())
                .playTimeMinutes(game.getPlayTimeMinutes())
                .ageRequirement(game.getAgeRequirement())
                .difficultyLevel(game.getDifficultyLevel())
                .imageUrl(game.getImageUrl())
                .quantity(sbg.getQuantity())
                .build();
    }

    private TimeSlotDto toTimeSlotDto(StoreTimeSlot slot) {
        return TimeSlotDto.builder()
                .id(slot.getId())
                .slotDate(slot.getSlotDate())
                .startTime(slot.getStartTime())
                .endTime(slot.getEndTime())
                .status(slot.getStatus().name().toLowerCase())
                .build();
    }

    private ReviewDto toReviewDto(Review review) {
        User user = review.getUser();
        return ReviewDto.builder()
                .id(review.getId())
                .rating(review.getRating())
                .comment(review.getComment())
                .userFullName(user != null ? user.getFullName() : null)
                .userAvatarUrl(user != null ? user.getAvatarUrl() : null)
                .createdAt(review.getCreatedAt())
                .build();
    }
}
