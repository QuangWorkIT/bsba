package com.be.bsba.service;

import com.be.bsba.constant.UserRole;
import com.be.bsba.dto.request.SendMessageRequest;
import com.be.bsba.dto.request.StartConversationRequest;
import com.be.bsba.dto.response.ConversationResponse;
import com.be.bsba.dto.response.MessageResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.UUID;

public interface ChatService {
    Page<ConversationResponse> getConversations(UUID userId, UserRole role, Pageable pageable);
    ConversationResponse startConversation(UUID userId, StartConversationRequest request);
    Page<MessageResponse> getMessages(UUID conversationId, Pageable pageable);
    MessageResponse sendMessage(UUID conversationId, UUID userId, UserRole role, SendMessageRequest request);
}
