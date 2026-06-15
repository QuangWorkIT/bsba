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

    private final Map<String, OtpDetails> otpCache = new java.util.concurrent.ConcurrentHashMap<>();

    private static class OtpDetails {
        private final String code;
        private final long expiryTime;

        public OtpDetails(String code, long expiryTime) {
            this.code = code;
            this.expiryTime = expiryTime;
        }

        public String getCode() {
            return code;
        }

        public boolean isExpired() {
            return System.currentTimeMillis() > expiryTime;
        }
    }

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
        String email = request.getEmail().trim().toLowerCase();
        System.out.println("AuthService: Registering user with email=" + email + ", phone=" + request.getPhone());
        
        // 1. Verify OTP code
        OtpDetails cachedOtp = otpCache.get(email);
        if (cachedOtp == null) {
            System.out.println("AuthService: Registration failed - No OTP requested for email: " + email);
            throw new AppException("No OTP requested for this email", HttpStatus.BAD_REQUEST);
        }
        if (cachedOtp.isExpired()) {
            otpCache.remove(email);
            System.out.println("AuthService: Registration failed - OTP has expired for email: " + email);
            throw new AppException("OTP has expired. Please request a new one.", HttpStatus.BAD_REQUEST);
        }
        if (!cachedOtp.getCode().equals(request.getOtpCode())) {
            System.out.println("AuthService: Registration failed - Invalid OTP entered for email: " + email);
            throw new AppException("Invalid OTP code", HttpStatus.BAD_REQUEST);
        }

        // Clear verified OTP
        otpCache.remove(email);

        // 2. Perform DB checks
        if (userRepository.findByEmail(email).isPresent()) {
            System.out.println("AuthService: Registration failed - Email already exists: " + email);
            throw new AppException("Email is already registered", HttpStatus.BAD_REQUEST);
        }
        if (userRepository.findByEmailOrPhone(email, request.getPhone()).isPresent()) {
            System.out.println("AuthService: Registration failed - Phone number or email already exists");
            throw new AppException("Phone number or email is already registered", HttpStatus.BAD_REQUEST);
        }

        System.out.println("AuthService: Fetching or creating CUSTOMER role...");
        Role userRole = roleRepository.findByName("CUSTOMER")
                .orElseGet(() -> {
                    System.out.println("AuthService: CUSTOMER role not found, creating new one...");
                    return roleRepository.save(Role.builder().name("CUSTOMER").build());
                });

        User user = User.builder()
                .email(email)
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

    @Override
    public void sendRegistrationOtp(SendOtpRequest request) {
        String email = request.getEmail().trim().toLowerCase();
        System.out.println("AuthService: Requesting OTP for email: " + email);

        if (userRepository.findByEmail(email).isPresent()) {
            System.out.println("AuthService: Request OTP failed - Email already exists: " + email);
            throw new AppException("Email is already registered", HttpStatus.BAD_REQUEST);
        }

        // Generate 6-digit random code
        String otpCode = String.format("%06d", new java.util.Random().nextInt(1000000));
        long expiryTime = System.currentTimeMillis() + (5 * 60 * 1000); // 5 minutes
        
        otpCache.put(email, new OtpDetails(otpCode, expiryTime));

        System.out.println("==================================================");
        System.out.println("--- GMAIL REGISTRATION OTP FOR " + email + " ---");
        System.out.println("                 CODE: " + otpCode);
        System.out.println("==================================================");
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
