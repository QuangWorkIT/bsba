package com.be.bsba.controller;

import com.be.bsba.dto.AuthResponse;
import com.be.bsba.dto.response.ApiResponse;
import com.be.bsba.dto.GoogleLoginRequest;
import com.be.bsba.dto.LoginRequest;
import com.be.bsba.dto.RegisterRequest;
import com.be.bsba.dto.SendOtpRequest;
import com.be.bsba.service.IAuthService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final IAuthService authService;

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody LoginRequest request) {
        AuthResponse authResponse = authService.login(request);
        return ResponseEntity.ok(
                ApiResponse.success(
                        authResponse,
                        "Login successful")
        );
    }

    @PostMapping("/register/send-otp")
    public ResponseEntity<ApiResponse<Void>> sendRegistrationOtp(@Valid @RequestBody SendOtpRequest request) {
        authService.sendRegistrationOtp(request);
        return ResponseEntity.ok(
                ApiResponse.success(null, "OTP sent successfully")
        );
    }

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AuthResponse>> register(@Valid @RequestBody RegisterRequest request) {
        System.out.println("AuthController: received registration request for email: " + request.getEmail() + ", phone: " + request.getPhone());
        AuthResponse authResponse = authService.register(request);
        System.out.println("AuthController: registration successful for email: " + request.getEmail());
        return ResponseEntity.ok(
                ApiResponse.success(
                        authResponse,
                        "Registration successful")
        );
    }

    @PostMapping("/google")
    public ResponseEntity<ApiResponse<AuthResponse>> googleLogin(@Valid @RequestBody GoogleLoginRequest request) {
        AuthResponse authResponse = authService.loginWithGoogle(request);
        return ResponseEntity.ok(
                ApiResponse.success(
                        authResponse,
                        "Google login successful")
        );
    }

    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Void>> logout(HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            authService.logout(token);
        }
        return ResponseEntity.ok(
                ApiResponse.success(null, "Logout successful")
        );
    }
}
