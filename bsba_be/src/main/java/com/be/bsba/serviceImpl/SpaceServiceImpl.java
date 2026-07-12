package com.be.bsba.serviceImpl;

import com.be.bsba.constant.SpaceSort;
import com.be.bsba.dto.response.SpaceCardResponse;
import com.be.bsba.dto.response.SpaceSlotResponse;
import com.be.bsba.entity.Store;
import com.be.bsba.repository.StoreBoardGameRepository;
import com.be.bsba.repository.StoreRepository;
import com.be.bsba.repository.StoreTimeSlotRepository;
import com.be.bsba.service.SpaceService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SpaceServiceImpl implements SpaceService {

    private static final int MAX_FEATURED_GAMES = 3;
    private static final double EARTH_RADIUS_MILES = 3958.8;

    private final StoreRepository storeRepository;
    private final StoreBoardGameRepository storeBoardGameRepository;
    private final StoreTimeSlotRepository storeTimeSlotRepository;

    @Override
    @Transactional(readOnly = true)
    public Page<SpaceCardResponse> getSpaces(Double lat, Double lng, SpaceSort sortBy, String q, Pageable pageable) {
        // 1) Active stores (optionally filtered by search text).
        List<Store> stores = (q == null || q.isBlank())
                ? storeRepository.findByIsActiveTrue()
                : storeRepository.searchActive(q.trim());

        // 2) Distance per store (only when the caller sent a location).
        boolean hasLocation = lat != null && lng != null;
        Map<UUID, Double> distanceByStore = new HashMap<>();
        if (hasLocation) {
            for (Store s : stores) {
                if (s.getLatitude() != null && s.getLongitude() != null) {
                    double miles = haversineMiles(
                            lat, lng, s.getLatitude().doubleValue(), s.getLongitude().doubleValue());
                    distanceByStore.put(s.getId(), round1(miles));
                }
            }
        }

        // 3) Sort.
        stores.sort(comparatorFor(sortBy, hasLocation, distanceByStore));

        // 4) Paginate the sorted list in memory.
        long total = stores.size();
        int from = (int) Math.min(pageable.getOffset(), total);
        int to = Math.min(from + pageable.getPageSize(), (int) total);
        List<Store> pageStores = stores.subList(from, to);

        if (pageStores.isEmpty()) {
            return new PageImpl<>(List.of(), pageable, total);
        }

        // 5) Batch-fetch games + today's available slots for just this page.
        List<UUID> storeIds = pageStores.stream().map(Store::getId).toList();

        Map<UUID, List<String>> gamesByStore = storeBoardGameRepository
                .findByStoreIdInFetchGame(storeIds).stream()
                .collect(Collectors.groupingBy(
                        sbg -> sbg.getStore().getId(),
                        Collectors.mapping(sbg -> sbg.getBoardGame().getName(), Collectors.toList())));

        // Native projection rows: [slotId(text), storeId(text), startLabel "HH:mm"].
        Map<String, List<SpaceSlotResponse>> slotsByStore = new HashMap<>();
        for (Object[] row : storeTimeSlotRepository.findAvailableSlots(storeIds, LocalDate.now())) {
            String storeId = (String) row[1];
            slotsByStore.computeIfAbsent(storeId, k -> new ArrayList<>())
                    .add(SpaceSlotResponse.builder()
                            .slotId(UUID.fromString((String) row[0]))
                            .startTime((String) row[2])
                            .build());
        }

        // 6) Map to response (preserving the sorted order).
        List<SpaceCardResponse> content = pageStores.stream()
                .map(s -> mapToCard(s, distanceByStore.get(s.getId()),
                        gamesByStore.getOrDefault(s.getId(), List.of()),
                        slotsByStore.getOrDefault(s.getId().toString(), List.of())))
                .toList();

        return new PageImpl<>(content, pageable, total);
    }

    private Comparator<Store> comparatorFor(SpaceSort sortBy, boolean hasLocation, Map<UUID, Double> distanceByStore) {
        Comparator<Store> byRatingDesc =
                Comparator.comparing(Store::getRatingAvg, Comparator.nullsLast(Comparator.reverseOrder()));

        return switch (sortBy) {
            case TOP_RATED -> byRatingDesc;
            case NEARBY -> hasLocation
                    ? Comparator.comparing((Store s) -> distanceByStore.get(s.getId()),
                            Comparator.nullsLast(Comparator.naturalOrder()))
                    : byRatingDesc; // no location -> fall back to rating
            case ALL -> Comparator.comparing(Store::getName,
                    Comparator.nullsLast(String.CASE_INSENSITIVE_ORDER));
        };
    }

    private SpaceCardResponse mapToCard(Store store, Double distanceMiles,
                                        List<String> games, List<SpaceSlotResponse> slots) {
        List<String> featured = games.size() > MAX_FEATURED_GAMES
                ? games.subList(0, MAX_FEATURED_GAMES)
                : games;

        return SpaceCardResponse.builder()
                .id(store.getId())
                .name(store.getName())
                .coverImageUrl(store.getCoverImageUrl())
                .ratingAvg(store.getRatingAvg())
                .distanceMiles(distanceMiles)
                .description(store.getDescription())
                .featuredGames(featured)
                .gameNames(games)
                .availableSlotsToday(slots)
                .build();
    }

    private static double haversineMiles(double lat1, double lon1, double lat2, double lon2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        return EARTH_RADIUS_MILES * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    }

    private static double round1(double value) {
        return Math.round(value * 10.0) / 10.0;
    }
}
