package com.be.bsba.service;

import com.be.bsba.dto.request.SendMessageRequest;
import com.be.bsba.dto.response.MessageResponse;

import java.util.UUID;

public interface ChatService {
    MessageResponse sendMessage(UUID conversationId, UUID userId, SendMessageRequest request);
}
