package com.be.bsba.service;

import com.be.bsba.dto.momo.MomoIpnRequest;
import com.be.bsba.dto.momo.MomoPaymentResponse;

public interface MomoService {
    MomoPaymentResponse createPayment(String orderId, Long amount, String orderInfo);
    void handleIpn(MomoIpnRequest req);
}
