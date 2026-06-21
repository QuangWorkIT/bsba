package com.be.bsba.serviceImpl;

import com.be.bsba.service.PresenceService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
@RequiredArgsConstructor
public class PresenceServiceImpl implements PresenceService {

    private final SimpMessagingTemplate messagingTemplate;

    // Which user each live WebSocket session belongs to.
    private final Map<String, UUID> sessionToUser = new ConcurrentHashMap<>();
    // How many sessions each user has open; the user is online while this is > 0.
    private final Map<UUID, Integer> sessionCount = new ConcurrentHashMap<>();

    @Override
    public void markOnline(String sessionId, UUID userId) {
        if (sessionId == null || userId == null) {
            return;
        }
        // Ignore a duplicate announce from the same session.
        if (userId.equals(sessionToUser.put(sessionId, userId))) {
            return;
        }
        boolean cameOnline = sessionCount.merge(userId, 1, Integer::sum) == 1;
        if (cameOnline) {
            broadcast(userId, true);
        }
    }

    @Override
    public void markOffline(String sessionId) {
        if (sessionId == null) {
            return;
        }
        UUID userId = sessionToUser.remove(sessionId);
        if (userId == null) {
            return;
        }
        // Drop the count; remove the user entirely (and broadcast) on the last session.
        Integer remaining = sessionCount.computeIfPresent(userId, (id, count) -> count <= 1 ? null : count - 1);
        if (remaining == null) {
            broadcast(userId, false);
        }
    }

    @Override
    public List<UUID> getOnlineUserIds() {
        return new ArrayList<>(sessionCount.keySet());
    }

    private void broadcast(UUID userId, boolean online) {
        messagingTemplate.convertAndSend(
                "/topic/presence",
                (Object) Map.of("userId", userId.toString(), "online", online));
    }
}
