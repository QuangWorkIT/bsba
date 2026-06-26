package com.be.bsba.config;

import com.be.bsba.constant.TimeSlotStatus;
import com.be.bsba.entity.*;
import com.be.bsba.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Configuration;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Configuration
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private static final String BOARD_GAME_KING = "Board Game King";

    private final StoreRepository storeRepository;
    private final BoardGameRepository boardGameRepository;
    private final StoreBoardGameRepository storeBoardGameRepository;
    private final StoreTimeSlotRepository storeTimeSlotRepository;

    @Override
    @Transactional
    public void run(String... args) {
        if (storeRepository.count() == 0) {
            storeRepository.save(Store.builder()
                    .name("Main Board Game Oasis")
                    .description("The best place to play and enjoy board games with friends.")
                    .address("123 Game St, Boardville")
                    .latitude(new BigDecimal("10.762622"))
                    .longitude(new BigDecimal("106.660172"))
                    .phone("0123456789")
                    .email("contact@bgoasis.com")
                    .coverImageUrl("https://images.unsplash.com/photo-1611532736597-de2d4265fba3?w=900&q=80")
                    .openTime(LocalTime.of(9, 0))
                    .closeTime(LocalTime.of(22, 0))
                    .totalCapacity(50)
                    .ratingAvg(new BigDecimal("4.8"))
                    .isActive(true)
                    .build());
            System.out.println("✅ Store created: Main Board Game Oasis");
        }

        List<BoardGame> catalog = ensureGameCatalog();
        System.out.println("✅ Game catalog ready: " + catalog.size() + " titles");

        storeRepository.findAll().forEach(store -> linkCatalogToStore(store, catalog));

        Optional<Store> boardGameKing = storeRepository.findAll().stream()
                .filter(s -> BOARD_GAME_KING.equalsIgnoreCase(s.getName()))
                .findFirst();
        if (boardGameKing.isPresent()) {
            int linked = storeBoardGameRepository.findByStoreId(boardGameKing.get().getId()).size();
            System.out.println("✅ " + BOARD_GAME_KING + " has " + linked + " games linked");
        }

        seedTimeSlotsIfEmpty();
        System.out.println("✅ Data initialization completed successfully!");
    }

    private List<BoardGame> ensureGameCatalog() {
        List<BoardGameSeed> seeds = List.of(
                new BoardGameSeed("Gloomhaven",
                        "A game of tactical combat in a persistent world of shifting motives.",
                        1, 4, 120, 4, "RPG", "5000",
                        "https://cf.geekdo-images.com/sZYp_3BTjGisob9Z3p-miA__imagepage/img/vgeYv9iZ1B_p_O8P8Y3BTjGisob9Z3p-miA/fit-in/900x600/filters:no_upscale():strip_icc()/pic2437871.jpg"),
                new BoardGameSeed("Terraforming Mars",
                        "In the 2400s, mankind begins to terraform the planet Mars.",
                        1, 5, 120, 3, "Strategy", "4500",
                        "https://cf.geekdo-images.com/wg9oOLcsKvDesSUd_z_3Zg__imagepage/img/93mFAnXqfG3A0YfXz7Z0E9H3Z0E=/fit-in/900x600/filters:no_upscale():strip_icc()/pic3536616.jpg"),
                new BoardGameSeed("Catan",
                        "Build settlements, cities, and roads to dominate the island of Catan.",
                        3, 4, 60, 2, "Family", "3000",
                        "https://cf.geekdo-images.com/W3Bs9p6NOn6-N7Z8N-_imagepage/img/U8N-_N/fit-in/900x600/filters:no_upscale():strip_icc()/pic2419339.jpg"),
                new BoardGameSeed("Wingspan",
                        "A relaxing, award-winning engine-building game about birds.",
                        1, 5, 70, 2, "Strategy", "4000",
                        "https://cf.geekdo-images.com/daGVjsGkHHoHy0hymkcH4w__imagepage/img/HoHy0hymkcH4w/fit-in/900x600/filters:no_upscale():strip_icc()/pic4458123.jpg"),
                new BoardGameSeed("Azul",
                        "Draft beautifully patterned tiles to decorate the royal palace.",
                        2, 4, 45, 2, "Family", "3500",
                        "https://cf.geekdo-images.com/PwRpqzJtzaq7D0nB6Wf4gw__imagepage/img/qzJtzaq7D0nB6Wf4gw/fit-in/900x600/filters:no_upscale():strip_icc()/pic6973671.jpg"),
                new BoardGameSeed("Ticket to Ride",
                        "Claim railway routes and connect cities across the map.",
                        2, 5, 60, 2, "Family", "3500",
                        "https://cf.geekdo-images.com/8bQ_THISwPRYKGyEQ1h_Pw__imagepage/img/KGyEQ1h_Pw/fit-in/900x600/filters:no_upscale():strip_icc()/pic3867016.jpg")
        );

        List<BoardGame> catalog = new ArrayList<>();
        for (BoardGameSeed seed : seeds) {
            BoardGame game = boardGameRepository.findByNameIgnoreCase(seed.name())
                    .orElseGet(() -> boardGameRepository.save(seed.toEntity()));
            catalog.add(game);
        }
        return catalog;
    }

    private void linkCatalogToStore(Store store, List<BoardGame> catalog) {
        Set<UUID> linkedIds = storeBoardGameRepository.findByStoreId(store.getId()).stream()
                .map(sbg -> sbg.getBoardGame().getId())
                .collect(Collectors.toSet());

        List<StoreBoardGame> toLink = new ArrayList<>();
        for (BoardGame game : catalog) {
            if (!linkedIds.contains(game.getId())) {
                toLink.add(StoreBoardGame.builder()
                        .store(store)
                        .boardGame(game)
                        .quantity(defaultQuantity(game.getName()))
                        .status("AVAILABLE")
                        .rentalPrice(game.getRentalPrice())
                        .build());
            }
        }

        if (!toLink.isEmpty()) {
            storeBoardGameRepository.saveAll(toLink);
            System.out.println("✅ Linked " + toLink.size() + " games to " + store.getName());
        }
    }

    private static int defaultQuantity(String gameName) {
        return switch (gameName) {
            case "Catan", "Azul" -> 5;
            case "Terraforming Mars", "Wingspan" -> 3;
            default -> 2;
        };
    }

    private void seedTimeSlotsIfEmpty() {
        if (storeTimeSlotRepository.count() > 0) {
            return;
        }

        Store store = storeRepository.findAll().getFirst();
        try {
            LocalDate today = LocalDate.now();
            LocalDate tomorrow = today.plusDays(1);

            for (LocalDate date : List.of(today, tomorrow)) {
                for (int hour = 9; hour < 21; hour += 2) {
                    storeTimeSlotRepository.save(StoreTimeSlot.builder()
                            .store(store)
                            .slotDate(date)
                            .startTime(LocalTime.of(hour, 0))
                            .endTime(LocalTime.of(hour + 2, 0))
                            .status(TimeSlotStatus.AVAILABLE)
                            .build());
                }
            }
            System.out.println("✅ Time slots created");
        } catch (Exception e) {
            System.err.println("⚠️ Time slot seed skipped (DB status constraint mismatch): " + e.getMessage());
        }
    }

    private record BoardGameSeed(
            String name,
            String description,
            int minPlayers,
            int maxPlayers,
            int playTimeMinutes,
            int difficultyLevel,
            String category,
            String rentalPrice,
            String imageUrl
    ) {
        BoardGame toEntity() {
            return BoardGame.builder()
                    .name(name)
                    .description(description)
                    .minPlayers(minPlayers)
                    .maxPlayers(maxPlayers)
                    .playTimeMinutes(playTimeMinutes)
                    .difficultyLevel(difficultyLevel)
                    .category(category)
                    .rentalPrice(new BigDecimal(rentalPrice))
                    .imageUrl(imageUrl)
                    .build();
        }
    }
}
