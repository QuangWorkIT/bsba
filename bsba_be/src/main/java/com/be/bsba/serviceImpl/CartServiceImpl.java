package com.be.bsba.serviceImpl;

import com.be.bsba.dto.request.CartItemRequest;
import com.be.bsba.dto.response.CartItemResponse;
import com.be.bsba.dto.response.CartResponse;
import com.be.bsba.entity.BoardGame;
import com.be.bsba.entity.BookingCart;
import com.be.bsba.entity.BookingCartGame;
import com.be.bsba.repository.BoardGameRepository;
import com.be.bsba.repository.BookingCartGameRepository;
import com.be.bsba.repository.BookingCartRepository;
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

    @Override
    @Transactional
    public CartResponse addItemToCart(UUID userId, CartItemRequest request) {
        BookingCart cart = cartRepository.findByUserId(userId)
                .orElseGet(() -> {
                    // For now, if no storeId provided, we might throw error or use a default.
                    // Assuming storeId is mandatory for the first creation.
                    if (request.getStoreId() == null) {
                        throw new RuntimeException("Store ID is required for first-time cart creation");
                    }
                    return cartRepository.save(BookingCart.builder()
                            .userId(userId)
                            .storeId(request.getStoreId())
                            .participantCount(1)
                            .build());
                });

        BoardGame game = boardGameRepository.findById(request.getBoardGameId())
                .orElseThrow(() -> new RuntimeException("Board game not found"));

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
        
        // Refresh items in the list if needed or just fetch again
        return getCartByUserId(userId);
    }

    @Override
    @Transactional(readOnly = true)
    public CartResponse getCartByUserId(UUID userId) {
        BookingCart cart = cartRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Cart not found for user"));

        List<CartItemResponse> items = cart.getItems().stream()
                .map(item -> CartItemResponse.builder()
                        .id(item.getId())
                        .boardGameId(item.getBoardGame().getId())
                        .boardGameName(item.getBoardGame().getName())
                        .imageUrl(item.getBoardGame().getImageUrl())
                        .rentalPrice(item.getBoardGame().getRentalPrice() != null ? item.getBoardGame().getRentalPrice().doubleValue() : 0.0)
                        .quantity(item.getQuantity())
                        .build())
                .collect(Collectors.toList());

        double totalPrice = items.stream()
                .mapToDouble(i -> i.getRentalPrice() * i.getQuantity())
                .sum();

        return CartResponse.builder()
                .id(cart.getId())
                .userId(cart.getUserId())
                .storeId(cart.getStoreId())
                .items(items)
                .totalPrice(totalPrice)
                .build();
    }
}
