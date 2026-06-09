package com.be.bsba.serviceImpl;

import com.be.bsba.dto.*;
import com.be.bsba.entity.Role;
import com.be.bsba.entity.User;
import com.be.bsba.exception.AppException;
import com.be.bsba.repository.RoleRepository;
import com.be.bsba.repository.UserRepository;
import com.be.bsba.security.JwtService;
import com.be.bsba.security.TokenBlacklistService;
import com.be.bsba.service.IAuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

@Service
@RequiredArgsConstructor
public class AuthService implements IAuthService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final TokenBlacklistService tokenBlacklistService;

    @Value("${google.client.id}")
    private String googleClientId;

    @Override
    @Transactional(readOnly = true)
    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByEmailOrPhone(request.getEmailOrPhone(), request.getEmailOrPhone())
                .orElseThrow(() -> new AppException("Invalid email/phone or password", HttpStatus.UNAUTHORIZED));

        if (user.getPasswordHash() == null || !passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new AppException("Invalid email/phone or password", HttpStatus.UNAUTHORIZED);
        }

        if (user.getIsActive() != null && !user.getIsActive()) {
            throw new AppException("User account is inactive", HttpStatus.FORBIDDEN);
        }

        String roleName = user.getRole() != null ? user.getRole().getName() : "USER";
        String token = jwtService.generateToken(user.getEmail(), roleName);

        return AuthResponse.builder()
                .token(token)
                .user(mapToUserDto(user))
                .build();
    }

    @Override
    @SuppressWarnings("unchecked")
    @Transactional
    public AuthResponse loginWithGoogle(GoogleLoginRequest request) {
        RestTemplate restTemplate = new RestTemplate();
        String googleUrl = "https://oauth2.googleapis.com/tokeninfo?id_token=" + request.getIdToken();
        System.out.println("Google ID Token: " + request.getIdToken());
        System.out.println("Google ID Token env: " + googleClientId);
        Map<String, Object> response;

        try {
            response = restTemplate.getForObject(googleUrl, Map.class);
        } catch (Exception e) {
            throw new AppException("Invalid Google ID token or connection failed", HttpStatus.UNAUTHORIZED);
        }

        if (response == null || response.containsKey("error_description")) {
            String errorMsg = response != null ? (String) response.get("error_description") : "Token validation failed";
            throw new AppException("Google authentication failed: " + errorMsg, HttpStatus.UNAUTHORIZED);
        }

        String audience = (String) response.get("aud");
        if (audience == null || !audience.equals(googleClientId)) {
            throw new AppException("Invalid Google ID token audience", HttpStatus.UNAUTHORIZED);
        }

        String email = (String) response.get("email");
        if (email == null) {
            throw new AppException("Email not found in Google ID token", HttpStatus.UNAUTHORIZED);
        }

        String fullName = (String) response.get("name");
        String picture = (String) response.get("picture");

        User user = userRepository.findByEmail(email).orElseGet(() -> {
            Role userRole = roleRepository.findByName("USER")
                    .orElseGet(() -> roleRepository.save(Role.builder().name("USER").build()));

            return userRepository.save(User.builder()
                    .email(email)
                    .fullName(fullName)
                    .avatarUrl(picture)
                    .authProvider("google")
                    .isActive(true)
                    .role(userRole)
                    .build());
        });

        // If user already exists but signed in with local before, update provider or support login
        if (!"google".equalsIgnoreCase(user.getAuthProvider())) {
            user.setAuthProvider("google");
            userRepository.save(user);
        }

        // Update avatar or name if empty
        boolean needsUpdate = false;
        if (user.getAvatarUrl() == null && picture != null) {
            user.setAvatarUrl(picture);
            needsUpdate = true;
        }
        if (user.getFullName() == null && fullName != null) {
            user.setFullName(fullName);
            needsUpdate = true;
        }
        if (needsUpdate) {
            userRepository.save(user);
        }

        if (user.getIsActive() != null && !user.getIsActive()) {
            throw new AppException("User account is inactive", HttpStatus.FORBIDDEN);
        }

        String roleName = user.getRole() != null ? user.getRole().getName() : "USER";
        String token = jwtService.generateToken(user.getEmail(), roleName);

        return AuthResponse.builder()
                .token(token)
                .user(mapToUserDto(user))
                .build();
    }

    @Override
    @Transactional
    public AuthResponse register(RegisterRequest request) {
        System.out.println("AuthService: Registering user with email=" + request.getEmail() + ", phone=" + request.getPhone());
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            System.out.println("AuthService: Registration failed - Email already exists: " + request.getEmail());
            throw new AppException("Email is already registered", HttpStatus.BAD_REQUEST);
        }
        if (userRepository.findByEmailOrPhone(request.getEmail(), request.getPhone()).isPresent()) {
            System.out.println("AuthService: Registration failed - Phone number or email already exists");
            throw new AppException("Phone number or email is already registered", HttpStatus.BAD_REQUEST);
        }

        System.out.println("AuthService: Fetching or creating USER role...");
        Role userRole = roleRepository.findByName("USER")
                .orElseGet(() -> {
                    System.out.println("AuthService: USER role not found, creating new one...");
                    return roleRepository.save(Role.builder().name("USER").build());
                });

        User user = User.builder()
                .email(request.getEmail())
                .phone(request.getPhone())
                .fullName(request.getFullName())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .authProvider("local")
                .isActive(true)
                .role(userRole)
                .build();

        System.out.println("AuthService: Saving user to database...");
        User savedUser = userRepository.save(user);
        System.out.println("AuthService: User saved successfully, ID: " + savedUser.getId());

        String roleName = savedUser.getRole() != null ? savedUser.getRole().getName() : "USER";
        System.out.println("AuthService: Generating token for " + savedUser.getEmail() + " with role: " + roleName);
        String token = jwtService.generateToken(savedUser.getEmail(), roleName);

        return AuthResponse.builder()
                .token(token)
                .user(mapToUserDto(savedUser))
                .build();
    }

    private UserDto mapToUserDto(User user) {
        return UserDto.builder()
                .id(user.getId())
                .email(user.getEmail())
                .fullName(user.getFullName())
                .phone(user.getPhone())
                .avatarUrl(user.getAvatarUrl())
                .authProvider(user.getAuthProvider())
                .role(user.getRole() != null ? user.getRole().getName() : null)
                .build();
    }

    @Override
    public void logout(String token) {
        long expiration = jwtService.getExpirationFromToken(token);
        tokenBlacklistService.blacklist(token, expiration);
    }
}
