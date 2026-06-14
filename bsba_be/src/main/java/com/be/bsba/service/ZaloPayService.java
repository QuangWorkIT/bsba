package com.be.bsba.service;

import com.be.bsba.dto.request.ZaloPayCallbackRequest;
import com.be.bsba.dto.request.ZaloPayCreateRequest;
import com.be.bsba.dto.response.ZaloPayCreateResponse;
import com.be.bsba.dto.response.ZaloPayStatusResponse;

import java.util.Map;

public interface ZaloPayService {
    ZaloPayCreateResponse createPayment(ZaloPayCreateRequest request, String authenticatedEmail);

    Map<String, Object> handleCallback(ZaloPayCallbackRequest request, String rawBody);

    ZaloPayStatusResponse getPaymentStatus(String appTransId, String authenticatedEmail);
}
