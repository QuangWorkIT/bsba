package com.be.bsba.controller;

import com.be.bsba.dto.request.CartItemQuantityRequest;
import com.be.bsba.dto.request.CartItemRequest;
import com.be.bsba.dto.response.ApiResponse;
import com.be.bsba.dto.response.CartResponse;
import com.be.bsba.service.CartService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/carts")
@RequiredArgsConstructor
public class CartController {

    private final CartService cartService;

    // TODO: In a real app, userId would be extracted from the SecurityContext
    @PostMapping("/items")
    public ApiResponse<CartResponse> addItemToCart(
            @RequestHeader(value = "X-User-Id", required = false) String userIdStr,
            @Valid @RequestBody CartItemRequest request) {
        
        // Default testing user if header is missing
        UUID userId = (userIdStr != null) ? UUID.fromString(userIdStr) : UUID.fromString("00000000-0000-0000-0000-000000000001");
        
        CartResponse cart = cartService.addItemToCart(userId, request);
        return ApiResponse.success(cart, "Item added to cart successfully");
    }

    @PatchMapping("/items/{boardGameId}")
    public ApiResponse<CartResponse> updateItemQuantity(
            @RequestHeader(value = "X-User-Id", required = false) String userIdStr,
            @PathVariable UUID boardGameId,
            @Valid @RequestBody CartItemQuantityRequest request) {

        UUID userId = (userIdStr != null) ? UUID.fromString(userIdStr) : UUID.fromString("00000000-0000-0000-0000-000000000001");

        CartResponse cart = cartService.setItemQuantity(userId, boardGameId, request);
        return ApiResponse.success(cart, "Cart item quantity updated successfully");
    }

    @GetMapping
    public ApiResponse<CartResponse> getCart(
            @RequestHeader(value = "X-User-Id", required = false) String userIdStr) {
        
        UUID userId = (userIdStr != null) ? UUID.fromString(userIdStr) : UUID.fromString("00000000-0000-0000-0000-000000000001");
        
        CartResponse cart = cartService.getCartByUserId(userId);
        return ApiResponse.success(cart, "Cart retrieved successfully");
    }

    @DeleteMapping("/items/{boardGameId}")
    public ApiResponse<CartResponse> removeItemFromCart(
            @RequestHeader(value = "X-User-Id", required = false) String userIdStr,
            @PathVariable UUID boardGameId) {
        
        UUID userId = (userIdStr != null) ? UUID.fromString(userIdStr) : UUID.fromString("00000000-0000-0000-0000-000000000001");
        
        CartResponse cart = cartService.removeItemFromCart(userId, boardGameId);
        return ApiResponse.success(cart, "Item removed from cart successfully");
    }
}
