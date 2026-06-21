package com.be.bsba.service;

import com.be.bsba.dto.request.CreateCartRequest;
import com.be.bsba.dto.response.CartResponse;

public interface ICartService {
    CartResponse createCart(CreateCartRequest request);
}
