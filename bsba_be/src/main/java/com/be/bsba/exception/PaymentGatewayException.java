package com.be.bsba.exception;

import org.springframework.http.HttpStatus;

public class PaymentGatewayException extends AppException {
    public PaymentGatewayException(String message) {
        super(message, HttpStatus.BAD_GATEWAY);
    }
}
