package com.be.bsba.config;

import com.be.bsba.service.PresenceService;
import lombok.RequiredArgsConstructor;
import org.springframework.context.event.EventListener;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;

/**
 * Bridges STOMP connection lifecycle into {@link PresenceService}: when a
 * WebSocket session disconnects we flip the matching user offline (once their
 * last session is gone). Coming online is handled by the client's /app/presence
 * announce, which carries the userId.
 */
@Component
@RequiredArgsConstructor
public class WebSocketEventListener {

    private final PresenceService presenceService;

    @EventListener
    public void onDisconnect(SessionDisconnectEvent event) {
        StompHeaderAccessor accessor = StompHeaderAccessor.wrap(event.getMessage());
        presenceService.markOffline(accessor.getSessionId());
    }
}
