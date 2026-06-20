package com.be.bsba.service;

import java.util.List;
import java.util.UUID;

/**
 * Tracks which users currently have a live WebSocket connection, so the chat
 * UI can show a real online dot. A user may be connected from several sessions
 * (tabs/devices) at once — they stay online until the last one disconnects.
 */
public interface PresenceService {

    /** Register a WebSocket session as belonging to {@code userId} (user comes online). */
    void markOnline(String sessionId, UUID userId);

    /** A WebSocket session dropped; the user goes offline once their last session closes. */
    void markOffline(String sessionId);

    /** Snapshot of every user that is online right now. */
    List<UUID> getOnlineUserIds();
}
