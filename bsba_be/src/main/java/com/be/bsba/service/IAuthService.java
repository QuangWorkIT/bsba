package com.be.bsba.service;

import com.be.bsba.dto.AuthResponse;
import com.be.bsba.dto.GoogleLoginRequest;
import com.be.bsba.dto.LoginRequest;

public interface IAuthService {
    AuthResponse login(LoginRequest request);
    AuthResponse loginWithGoogle(GoogleLoginRequest request);
    void logout(String token);
}
