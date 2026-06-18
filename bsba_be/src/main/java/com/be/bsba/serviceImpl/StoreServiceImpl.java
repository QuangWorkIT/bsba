package com.be.bsba.serviceImpl;

import com.be.bsba.dto.request.UpdateStoreRequest;
import com.be.bsba.dto.response.*;
import com.be.bsba.entity.*;
import com.be.bsba.exception.ResourceNotFoundException;
import com.be.bsba.repository.*;
import com.be.bsba.service.StoreService;
import com.be.bsba.dto.projection.NearbyStoreProjection;
import com.be.bsba.repository.StoreRepository;
import com.be.bsba.service.IStoreService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class StoreServiceImpl implements StoreService, IStoreService {

    private final StoreRepository storeRepository;
    private final StoreImageRepository storeImageRepository;
    private final StoreBoardGameRepository storeBoardGameRepository;
    private final StoreTimeSlotRepository storeTimeSlotRepository;
    private final ReviewRepository reviewRepository;
    private final FavoriteStoreRepository favoriteStoreRepository;
    private final StoreStaffRepository storeStaffRepository;

    @Override
    @Transactional(readOnly = true)
    public StoreDetailResponse getStoreDetail(UUID storeId, UUID currentUserId) {

        // 1. Fetch the store (must be active)
        Store store = storeRepository.findByIdAndIsActiveTrue(storeId)
                .orElseThrow(() -> new ResourceNotFoundException("Store not found with id: " + storeId));

        // 2. Fetch store images
        List<StoreImageDto> images = storeImageRepository
                .findByStoreIdOrderByDisplayOrderAsc(storeId)
                .stream()
                .map(this::toStoreImageDto)
                .filter(java.util.Objects::nonNull)
                .toList();

        // 3. Fetch board games available at this store
        List<BoardGameDto> boardGames = storeBoardGameRepository
                .findByStoreId(storeId)
                .stream()
                .map(this::toBoardGameDto)
                .filter(java.util.Objects::nonNull)
                .toList();

        // 4. Fetch upcoming time slots (from today onwards)
        List<TimeSlotDto> timeSlots = storeTimeSlotRepository
                .findByStoreIdAndSlotDateGreaterThanEqualOrderBySlotDateAscStartTimeAsc(
                        storeId, LocalDate.now())
                .stream()
                .map(this::toTimeSlotDto)
                .filter(java.util.Objects::nonNull)
                .toList();

        // 5. Fetch reviews
        List<ReviewDto> reviews = reviewRepository
                .findByStoreIdOrderByCreatedAtDesc(storeId)
                .stream()
                .map(this::toReviewDto)
                .filter(java.util.Objects::nonNull)
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

    @Override
    @Transactional(readOnly = true)
    public EditStoreResponse getStoreDetailByStaffId(UUID staffId) {
        EditStoreResponse storeDetail = storeRepository.getStoreDetailByStaffId(staffId);
        if (storeDetail == null) {
            throw new ResourceNotFoundException("Staff is not assigned to any active store: " + staffId);
        }
        return storeDetail;
    }

    @Override
    @Transactional
    public EditStoreResponse updateStoreByStaff(UpdateStoreRequest request) {
        UUID staffId = UUID.fromString(request.getStaffId());
        UUID storeId = UUID.fromString(request.getStoreId());

        boolean staffBelongsToStore = storeRepository.existsActiveStoreByStaffIdAndStoreId(staffId, storeId);
        if (!staffBelongsToStore) {
            throw new ResourceNotFoundException("Staff is not assigned to this active store: " + staffId);
        }

        int updatedRows = storeRepository.updateStoreByStaff(
                storeId,
                request.getStoreName(),
                request.getDescription(),
                request.getAddress(),
                request.getCoverLetterUrl(),
                request.getPhone(),
                request.getEmail(),
                request.getOpenTime(),
                request.getCloseTime(),
                request.getTotalCapacity(),
                request.getChargeFee()
        );

        if (updatedRows == 0) {
            throw new ResourceNotFoundException("Store not found with id: " + storeId);
        }

        return storeRepository.getStoreDetailByStaffId(staffId);
    }

    // ── Mapping helpers ──────────────────────────────────────────────

    private StoreImageDto toStoreImageDto(StoreImage image) {
        if (image == null) return null;
        try {
            return StoreImageDto.builder()
                    .id(image.getId())
                    .imageUrl(image.getImageUrl())
                    .displayOrder(image.getDisplayOrder())
                    .build();
        } catch (Exception e) {
            return null;
        }
    }

    private BoardGameDto toBoardGameDto(StoreBoardGame sbg) {
        if (sbg == null) return null;
        try {
            BoardGame game = sbg.getBoardGame();
            if (game == null) return null;
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
        } catch (Exception e) {
            return null;
        }
    }

    private TimeSlotDto toTimeSlotDto(StoreTimeSlot slot) {
        if (slot == null) return null;
        try {
            return TimeSlotDto.builder()
                    .id(slot.getId())
                    .slotDate(slot.getSlotDate())
                    .startTime(slot.getStartTime())
                    .endTime(slot.getEndTime())
                    .status(slot.getStatus() != null ? slot.getStatus().name().toLowerCase() : null)
                    .build();
        } catch (Exception e) {
            return null;
        }
    }

    private ReviewDto toReviewDto(Review review) {
        if (review == null) return null;
        String fullName = null;
        String avatarUrl = null;
        try {
            User user = review.getUser();
            if (user != null) {
                fullName = user.getFullName();
                avatarUrl = user.getAvatarUrl();
            }
        } catch (Exception e) {
            // Ignore if user proxy throws EntityNotFoundException
        }
        try {
            return ReviewDto.builder()
                    .id(review.getId())
                    .rating(review.getRating())
                    .comment(review.getComment())
                    .userFullName(fullName)
                    .userAvatarUrl(avatarUrl)
                    .createdAt(review.getCreatedAt())
                    .build();
        } catch (Exception e) {
            return null;
        }
    }

    @Override
    @Transactional(readOnly = true)
    public List<BoardGameDto> getGamesForStaffStore(UUID staffId) {
        List<UUID> storeIds = storeStaffRepository.findStoreIdsByStaffId(staffId);
        if (storeIds.isEmpty()) {
            throw new ResourceNotFoundException("No store found for staff id: " + staffId);
        }
        UUID storeId = storeIds.get(0); // Assuming one store per staff
        return storeBoardGameRepository.findByStoreId(storeId).stream()
                .map(this::toBoardGameDto)
                .filter(java.util.Objects::nonNull)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<NearbyStoreProjection> findNearbyStores(double lat, double lng, double radiusKm) {
        return storeRepository.findNearbyStores(lat, lng, radiusKm);
    }

    @Override
    @Transactional(readOnly = true)
    public List<NearbyStoreProjection> searchStores(String name, String description, String address) {
        return storeRepository.searchStores(
                normalizeSearchParam(name),
                normalizeSearchParam(description),
                normalizeSearchParam(address)
        );
    }
    private String normalizeSearchParam(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }

}
