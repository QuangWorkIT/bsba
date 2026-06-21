package com.be.bsba.controller;

import com.be.bsba.dto.request.CreateCartRequest;
import com.be.bsba.dto.response.ApiResponse;
import com.be.bsba.dto.response.CartResponse;
import com.be.bsba.service.ICartService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
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
    public ApiResponse<CartResponse> createCard(@Valid @RequestBody CreateCartRequest request) {
        CartResponse card = cartService.createCart(request);
        return ApiResponse.success(card, "Card created successfully");
    }
}
