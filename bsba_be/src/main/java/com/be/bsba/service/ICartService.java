package com.be.bsba.service;

import com.be.bsba.dto.request.CreateCartRequest;
import com.be.bsba.dto.request.AddItemCartRequest;
import com.be.bsba.dto.request.DeleteItemCartRequest;
import com.be.bsba.dto.request.UpdateItemCartQuantityRequest;
import com.be.bsba.dto.response.CartDetailResponse;
import com.be.bsba.dto.response.CartItemResponse;
import com.be.bsba.dto.response.CartResponse;
import com.be.bsba.dto.response.ModifyCartItemResponse;

public interface ICartService {
    CartResponse createCart(CreateCartRequest request);

    CartItemResponse addItemToCart(AddItemCartRequest request);

    ModifyCartItemResponse deleteItemFromCart(DeleteItemCartRequest request);

    ModifyCartItemResponse updateItemQuantityInCart(UpdateItemCartQuantityRequest request);

    CartDetailResponse getCartDetailByBookingId(String bookingId);
}
