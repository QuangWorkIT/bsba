package com.be.bsba.security;

import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import com.be.bsba.constant.UserRole;
import com.be.bsba.entity.Role;
import com.be.bsba.entity.User;
import com.be.bsba.exception.AppException;
import com.be.bsba.exception.ResourceNotFoundException;
import com.be.bsba.repository.UserRepository;

import lombok.RequiredArgsConstructor;

/**
 * Resolves the authenticated caller from the security context (populated by
 * {@link JwtAuthenticationFilter} from the JWT). The token carries the user's
 * email + role; we look the user up to get their id. Controllers use this
 * instead of trusting a userId/role passed in the request.
 */
@Component
@RequiredArgsConstructor
public class CurrentUserProvider {

    private final UserRepository userRepository;

    /** Id + role of the caller. Throws if the request isn't authenticated. */
    public AuthUser requireCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || auth.getName() == null
                || "anonymousUser".equals(auth.getName())) {
            throw new ResourceNotFoundException("No authenticated user");
        }

        String email = auth.getName();
        User user = userRepository.findByEmailWithRole(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + email));

        // The JWT is only checked for isActive at login (24h TTL); re-verify here so a
        // user deactivated mid-session loses access immediately instead of lingering.
        if (user.getIsActive() != null && !user.getIsActive()) {
            throw new AppException("User account is inactive", HttpStatus.FORBIDDEN);
        }

        return new AuthUser(user.getId(), toUserRole(user.getRole()));
    }

    private UserRole toUserRole(Role role) {
        if (role == null || role.getName() == null) {
            return UserRole.CUSTOMER;
        }
        String name = role.getName().trim().toUpperCase();
        if (name.startsWith("ROLE_")) {
            name = name.substring(5);
        }
        try {
            return UserRole.valueOf(name);
        } catch (IllegalArgumentException ex) {
            return UserRole.CUSTOMER;
        }
    }

    /** The authenticated caller's id and role. */
    public record AuthUser(UUID id, UserRole role) {
    }
}
