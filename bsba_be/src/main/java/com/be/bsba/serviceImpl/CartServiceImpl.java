package com.be.bsba.serviceImpl;

import com.be.bsba.dto.request.CreateCartRequest;
import com.be.bsba.dto.response.BoardGameResponse;
import com.be.bsba.dto.response.CartDetailResponse;
import com.be.bsba.dto.response.CartResponse;
import com.be.bsba.entity.BoardGame;
import com.be.bsba.entity.Booking;
import com.be.bsba.entity.BookingCart;
import com.be.bsba.entity.BookingCartGame;
import com.be.bsba.entity.Store;
import com.be.bsba.entity.StoreTimeSlot;
import com.be.bsba.exception.BadRequestException;
import com.be.bsba.exception.ResourceNotFoundException;
import com.be.bsba.repository.BookingCartRepository;
import com.be.bsba.repository.BookingCartGameRepository;
import com.be.bsba.repository.BookingRepository;
import com.be.bsba.service.ICartService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.Collections;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CartServiceImpl implements ICartService {
    private final BookingRepository bookingRepository;
    private final BookingCartRepository bookingCartRepository;
    private final BookingCartGameRepository bookingCartGameRepository;

    @Override
    @Transactional
    public CartResponse createCart(CreateCartRequest request) {
        UUID bookingId = parseBookingId(request.getBookingId());

        if (bookingCartRepository.existsByBookingId(bookingId)) {
            throw new BadRequestException("Cart already exists for booking id: " + bookingId);
        }

        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found with id: " + bookingId));

        BookingCart cart = BookingCart.builder()
                .booking(booking)
                .note(request.getNote())
                .build();

        BookingCart savedCart = bookingCartRepository.save(cart);
        return mapToResponse(savedCart);
    }

    @Override
    @Transactional(readOnly = true)
    public CartDetailResponse getCartDetailByBookingId(String bookingIdValue) {
        UUID bookingId = parseBookingId(bookingIdValue);

        BookingCart cart = bookingCartRepository.findByBookingId(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Cart not found for booking id: " + bookingId));

        return mapToDetailResponse(cart);
    }

    private UUID parseBookingId(String value) {
        try {
            return UUID.fromString(value);
        } catch (IllegalArgumentException ex) {
            throw new BadRequestException("Booking ID must be a valid UUID");
        }
    }

    private CartResponse mapToResponse(BookingCart cart) {
        Booking booking = cart.getBooking();
        Store store = booking.getStore();
        StoreTimeSlot slot = booking.getSlot();

        return CartResponse.builder()
                .id(cart.getId())
                .userId(booking.getUser() != null ? booking.getUser().getId() : null)
                .bookingId(booking.getId())
                .storeId(store != null ? store.getId() : null)
                .storeName(store != null ? store.getName() : null)
                .storeImage(store != null ? store.getCoverImageUrl() : null)
                .slotDate(slot != null && slot.getSlotDate() != null ? slot.getSlotDate().toString() : null)
                .startTime(slot != null && slot.getStartTime() != null ? slot.getStartTime().toString() : null)
                .endTime(slot != null && slot.getEndTime() != null ? slot.getEndTime().toString() : null)
                .build();
    }

    private CartDetailResponse mapToDetailResponse(BookingCart cart) {
        Booking booking = cart.getBooking();
        Store store = booking.getStore();
        StoreTimeSlot slot = booking.getSlot();

        List<BookingCartGame> cartGames = bookingCartGameRepository.findAllByCartId(cart.getId());

        List<BoardGameResponse> boardGames = cartGames.isEmpty()
                ? Collections.emptyList()
                : cartGames.stream()
                .map(BookingCartGame::getBoardGame)
                .map(this::mapToBoardGameResponse)
                .toList();

        double retailPrice = calculateRetailPrice(cartGames);
        double chargeFee = store != null ? store.getChargeFee() : 0.0;
        double totalPrice = booking.getTotalPrice() != null
                ? booking.getTotalPrice().doubleValue()
                : retailPrice + chargeFee;

        return CartDetailResponse.builder()
                .id(cart.getId())
                .bookingId(booking.getId())
                .storeId(store != null ? store.getId() : null)
                .storeName(store != null ? store.getName() : null)
                .storeImage(store != null ? store.getCoverImageUrl() : null)
                .slotDate(slot != null && slot.getSlotDate() != null ? slot.getSlotDate().toString() : null)
                .startTime(slot != null && slot.getStartTime() != null ? slot.getStartTime().toString() : null)
                .endTime(slot != null && slot.getEndTime() != null ? slot.getEndTime().toString() : null)
                .boardGames(boardGames)
                .participants(booking.getParticipantCount())
                .chargeFee(chargeFee)
                .retailPrice(retailPrice)
                .totalPrice(totalPrice)
                .build();
    }

    private double calculateRetailPrice(List<BookingCartGame> cartGames) {
        if (cartGames == null) {
            return 0.0;
        }

        return cartGames.stream()
                .mapToDouble(this::calculateBookingGamePrice)
                .sum();
    }

    private double calculateBookingGamePrice(BookingCartGame cartGame) {
        BoardGame boardGame = cartGame.getBoardGame();
        BigDecimal rentalPrice = boardGame != null ? boardGame.getRentalPrice() : null;
        int quantity = cartGame.getQuantity() != null ? cartGame.getQuantity() : 0;
        return rentalPrice != null ? rentalPrice.doubleValue() * quantity : 0.0;
    }

    private BoardGameResponse mapToBoardGameResponse(BoardGame boardGame) {
        return BoardGameResponse.builder()
                .id(boardGame.getId())
                .name(boardGame.getName())
                .description(boardGame.getDescription())
                .minPlayers(boardGame.getMinPlayers())
                .maxPlayers(boardGame.getMaxPlayers())
                .playTimeMinutes(boardGame.getPlayTimeMinutes())
                .ageRequirement(boardGame.getAgeRequirement())
                .difficultyLevel(boardGame.getDifficultyLevel())
                .imageUrl(boardGame.getImageUrl())
                .category(boardGame.getCategory())
                .rentalPrice(boardGame.getRentalPrice())
                .createdAt(boardGame.getCreatedAt())
                .build();
    }
}
