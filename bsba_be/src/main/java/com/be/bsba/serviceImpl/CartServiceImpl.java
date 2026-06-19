package com.be.bsba.serviceImpl;

import com.be.bsba.dto.request.CartItemQuantityRequest;
import com.be.bsba.dto.request.CartItemRequest;
import com.be.bsba.dto.response.CartItemResponse;
import com.be.bsba.dto.response.CartResponse;
import com.be.bsba.entity.BoardGame;
import com.be.bsba.entity.BookingCart;
import com.be.bsba.entity.BookingCartGame;
import com.be.bsba.repository.BoardGameRepository;
import com.be.bsba.repository.BookingCartGameRepository;
import com.be.bsba.repository.BookingCartRepository;
import com.be.bsba.repository.StoreRepository;
import com.be.bsba.repository.StoreTimeSlotRepository;
import com.be.bsba.service.CartService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CartServiceImpl implements CartService {

    private final BookingCartRepository cartRepository;
    private final BookingCartGameRepository cartGameRepository;
    private final BoardGameRepository boardGameRepository;
    private final StoreRepository storeRepository;
    private final StoreTimeSlotRepository storeTimeSlotRepository;
    private final com.be.bsba.service.AvailabilityService availabilityService;

    @Override
    @Transactional
    public CartResponse addItemToCart(UUID userId, CartItemRequest request) {
        BookingCart cart = cartRepository.findByUserId(userId)
                .orElseGet(() -> {
                    if (request.getStoreId() == null) {
                        throw new RuntimeException("Store ID is required for first-time cart creation");
                    }
                    return cartRepository.save(BookingCart.builder()
                            .userId(userId)
                            .storeId(request.getStoreId())
                            .slotId(request.getSlotId())
                            .participantCount(1)
                            .build());
                });

        if (request.getStoreId() != null && !request.getStoreId().equals(cart.getStoreId())) {
            cart.getItems().clear();
            cart.setStoreId(request.getStoreId());
        }

        if (request.getSlotId() != null && !request.getSlotId().equals(cart.getSlotId())) {
            cart.getItems().clear();
            cart.setSlotId(request.getSlotId());
        } else if (request.getSlotId() != null) {
            cart.setSlotId(request.getSlotId());
        }

        cartRepository.save(cart);

        BoardGame game = boardGameRepository.findById(request.getBoardGameId())
                .orElseThrow(() -> new RuntimeException("Board game not found"));

        int currentInCart = cart.getItems().stream()
                .filter(item -> item.getBoardGame().getId().equals(game.getId()))
                .mapToInt(BookingCartGame::getQuantity)
                .sum();
        int requestedTotal = currentInCart + request.getQuantity();

        if (!availabilityService.isAvailable(cart.getStoreId(), game.getId(), cart.getSlotId(), requestedTotal)) {
            throw new RuntimeException("Sorry, only " + availabilityService.getAvailableQuantity(cart.getStoreId(), game.getId(), cart.getSlotId()) + " units of " + game.getName() + " are available for this time slot.");
        }

        BookingCartGame cartGame = cartGameRepository.findByCartIdAndBoardGameId(cart.getId(), game.getId())
                .map(item -> {
                    item.setQuantity(item.getQuantity() + request.getQuantity());
                    return item;
                })
                .orElseGet(() -> BookingCartGame.builder()
                        .cart(cart)
                        .boardGame(game)
                        .quantity(request.getQuantity())
                        .build());

        cartGameRepository.save(cartGame);

        return getCartByUserId(userId);
    }

    @Override
    @Transactional
    public CartResponse setItemQuantity(UUID userId, UUID boardGameId, CartItemQuantityRequest request) {
        BookingCart cart = cartRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Cart not found"));

        BoardGame game = boardGameRepository.findById(boardGameId)
                .orElseThrow(() -> new RuntimeException("Board game not found"));

        if (!availabilityService.isAvailable(cart.getStoreId(), game.getId(), cart.getSlotId(), request.getQuantity())) {
            throw new RuntimeException("Sorry, only " + availabilityService.getAvailableQuantity(cart.getStoreId(), game.getId(), cart.getSlotId()) + " units of " + game.getName() + " are available for this time slot.");
        }

        BookingCartGame cartGame = cartGameRepository.findByCartIdAndBoardGameId(cart.getId(), boardGameId)
                .orElseThrow(() -> new RuntimeException("Item not found in cart"));

        cartGame.setQuantity(request.getQuantity());
        cartGameRepository.save(cartGame);

        return getCartByUserId(userId);
    }

    @Override
    @Transactional(readOnly = true)
    public CartResponse getCartByUserId(UUID userId) {
        return cartRepository.findByUserId(userId)
                .map(this::mapToCartResponse)
                .orElse(null);
    }

    private CartResponse mapToCartResponse(BookingCart cart) {
        List<CartItemResponse> items = cart.getItems().stream()
                .map(item -> CartItemResponse.builder()
                        .id(item.getId())
                        .boardGameId(item.getBoardGame().getId())
                        .boardGameName(item.getBoardGame().getName())
                        .category(item.getBoardGame().getCategory())
                        .imageUrl(item.getBoardGame().getImageUrl())
                        .rentalPrice(item.getBoardGame().getRentalPrice() != null ? item.getBoardGame().getRentalPrice().doubleValue() : 0.0)
                        .quantity(item.getQuantity())
                        .build())
                .collect(Collectors.toList());

        double totalPrice = items.stream()
                .mapToDouble(i -> i.getRentalPrice() * i.getQuantity())
                .sum();

        CartResponse.CartResponseBuilder responseBuilder = CartResponse.builder()
                .id(cart.getId())
                .userId(cart.getUserId())
                .storeId(cart.getStoreId())
                .items(items)
                .totalPrice(totalPrice);

        storeRepository.findById(cart.getStoreId()).ifPresent(store -> {
            responseBuilder.storeName(store.getName());
            responseBuilder.storeImage(store.getCoverImageUrl());
        });

        if (cart.getSlotId() != null) {
            storeTimeSlotRepository.findById(cart.getSlotId()).ifPresent(slot -> {
                responseBuilder.slotDate(slot.getSlotDate().toString());
                responseBuilder.startTime(slot.getStartTime().toString());
                responseBuilder.endTime(slot.getEndTime().toString());
            });
        }

        return responseBuilder.build();
    }

    @Override
    @Transactional
    public CartResponse removeItemFromCart(UUID userId, UUID boardGameId) {
        BookingCart cart = cartRepository.findByUserId(userId)
                .orElse(null);

        if (cart == null) return null;

        cart.getItems().removeIf(item -> item.getBoardGame().getId().equals(boardGameId));
        
        cartRepository.save(cart);
        
        return getCartByUserId(userId);
    }
}
