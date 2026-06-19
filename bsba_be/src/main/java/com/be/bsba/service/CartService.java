package com.be.bsba.service;

import com.be.bsba.dto.request.CartItemQuantityRequest;
import com.be.bsba.dto.request.CartItemRequest;
import com.be.bsba.dto.response.CartResponse;
import java.util.UUID;

public interface CartService {
    CartResponse addItemToCart(UUID userId, CartItemRequest request);
    CartResponse setItemQuantity(UUID userId, UUID boardGameId, CartItemQuantityRequest request);
    CartResponse getCartByUserId(UUID userId);
    CartResponse removeItemFromCart(UUID userId, UUID boardGameId);
}
