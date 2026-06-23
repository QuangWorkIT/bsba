package com.be.bsba.controller;

import com.be.bsba.dto.request.AddItemCartRequest;
import com.be.bsba.dto.request.CreateCartRequest;
import com.be.bsba.dto.request.DeleteItemCartRequest;
import com.be.bsba.dto.request.UpdateItemCartQuantityRequest;
import com.be.bsba.dto.response.ApiResponse;
import com.be.bsba.dto.response.CartDetailResponse;
import com.be.bsba.dto.response.CartItemResponse;
import com.be.bsba.dto.response.CartResponse;
import com.be.bsba.dto.response.ModifyCartItemResponse;
import com.be.bsba.service.ICartService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/carts")
@RequiredArgsConstructor
public class CartController {
    private final ICartService cartService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<CartResponse> createEmptyCart(@Valid @RequestBody CreateCartRequest request) {
        CartResponse cart = cartService.createCart(request);
        return ApiResponse.success(cart, "Cart created successfully");
    }

    @PostMapping("/items")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<CartItemResponse> addItemToCart(@Valid @RequestBody AddItemCartRequest request) {
        CartItemResponse item = cartService.addItemToCart(request);
        return ApiResponse.success(item, "Item added to cart successfully");
    }

    @DeleteMapping("/items")
    public ApiResponse<ModifyCartItemResponse> deleteItemFromCart(@Valid @RequestBody DeleteItemCartRequest request) {
        ModifyCartItemResponse item = cartService.deleteItemFromCart(request);
        return ApiResponse.success(item, "Item deleted from cart successfully");
    }

    @PatchMapping("/items/quantity")
    public ApiResponse<ModifyCartItemResponse> updateItemQuantityInCart(
            @Valid @RequestBody UpdateItemCartQuantityRequest request) {
        ModifyCartItemResponse item = cartService.updateItemQuantityInCart(request);
        return ApiResponse.success(item, "Item quantity updated successfully");
    }

    @GetMapping("/{bookingId}")
    public ApiResponse<CartDetailResponse> getCartDetailByBookingId(@PathVariable String bookingId) {
        CartDetailResponse cart = cartService.getCartDetailByBookingId(bookingId);
        return ApiResponse.success(cart, "Cart detail retrieved successfully");
    }
}
