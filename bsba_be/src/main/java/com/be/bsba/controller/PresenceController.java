package com.be.bsba.controller;

import com.be.bsba.dto.response.ApiResponse;
import com.be.bsba.service.PresenceService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/presence")
@RequiredArgsConstructor
public class PresenceController {

    private final PresenceService presenceService;

    /** Initial snapshot of who is online, for the inbox to render before live updates arrive. */
    @GetMapping
    public ApiResponse<List<UUID>> getOnlineUsers() {
        return ApiResponse.success(presenceService.getOnlineUserIds(), "Online users retrieved successfully");
    }

    /**
     * STOMP: a client announces itself right after connecting by sending its userId
     * to /app/presence. The session id ties it to the connection so we can flip the
     * user offline when that session drops.
     */
    @MessageMapping("/presence")
    public void announce(@Payload Map<String, String> payload, SimpMessageHeaderAccessor headerAccessor) {
        String rawUserId = payload != null ? payload.get("userId") : null;
        if (rawUserId == null || rawUserId.isBlank()) {
            return;
        }
        presenceService.markOnline(headerAccessor.getSessionId(), UUID.fromString(rawUserId));
    }
}
