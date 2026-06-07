package com.be.bsba.security;

import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * In-memory token blacklist for invalidating JWT tokens on logout.
 * Tokens are stored with their expiration time and cleaned up automatically.
 */
@Service
public class TokenBlacklistService {

    // Map of token -> expiration timestamp (millis)
    private final Map<String, Long> blacklistedTokens = new ConcurrentHashMap<>();

    /**
     * Add a token to the blacklist.
     *
     * @param token          the JWT token string
     * @param expirationMs   the token's expiration time in epoch milliseconds
     */
    public void blacklist(String token, long expirationMs) {
        blacklistedTokens.put(token, expirationMs);
        cleanup();
    }

    /**
     * Check if a token has been blacklisted (i.e. the user logged out).
     */
    public boolean isBlacklisted(String token) {
        return blacklistedTokens.containsKey(token);
    }

    /**
     * Remove expired tokens from the blacklist to prevent memory leaks.
     */
    private void cleanup() {
        long now = System.currentTimeMillis();
        blacklistedTokens.entrySet().removeIf(entry -> entry.getValue() < now);
    }
}
