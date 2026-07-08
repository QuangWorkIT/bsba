package com.be.bsba.controller;

import com.be.bsba.dto.request.SendMessageRequest;
import com.be.bsba.dto.request.StartConversationRequest;
import com.be.bsba.dto.response.ApiResponse;
import com.be.bsba.dto.response.ConversationResponse;
import com.be.bsba.dto.response.MessageResponse;
import com.be.bsba.dto.response.PagedResult;
import com.be.bsba.security.CurrentUserProvider;
import com.be.bsba.security.CurrentUserProvider.AuthUser;
import com.be.bsba.service.ChatService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/conversations")
@RequiredArgsConstructor
public class ConversationController {

    private final ChatService chatService;
    private final CurrentUserProvider currentUserProvider;

    @GetMapping
    public ApiResponse<PagedResult<ConversationResponse>> getConversations(Pageable pageable) {
        AuthUser me = currentUserProvider.requireCurrentUser();
        PagedResult<ConversationResponse> conversations =
                PagedResult.from(chatService.getConversations(me.id(), me.role(), pageable));
        return ApiResponse.success(conversations, "Conversations retrieved successfully");
    }

    @GetMapping("/unread-count")
    public ApiResponse<Long> getUnreadCount() {
        AuthUser me = currentUserProvider.requireCurrentUser();
        long count = chatService.getUnreadCount(me.id(), me.role());
        return ApiResponse.success(count, "Unread count retrieved successfully");
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<ConversationResponse> startConversation(
            @Valid @RequestBody StartConversationRequest request) {
        AuthUser me = currentUserProvider.requireCurrentUser();
        ConversationResponse conversation = chatService.startConversation(me.id(), me.role(), request);
        return ApiResponse.success(conversation, "Conversation created successfully");
    }

    @GetMapping("/{id}/messages")
    public ApiResponse<PagedResult<MessageResponse>> getMessages(
            @PathVariable UUID id,
            Pageable pageable) {
        AuthUser me = currentUserProvider.requireCurrentUser();
        PagedResult<MessageResponse> messages =
                PagedResult.from(chatService.getMessages(id, me.id(), me.role(), pageable));
        return ApiResponse.success(messages, "Messages retrieved successfully");
    }

    @PostMapping("/{id}/messages")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<MessageResponse> sendMessage(
            @PathVariable UUID id,
            @Valid @RequestBody SendMessageRequest request) {
        AuthUser me = currentUserProvider.requireCurrentUser();
        MessageResponse message = chatService.sendMessage(id, me.id(), me.role(), request);
        return ApiResponse.success(message, "Message sent successfully");
    }

    @PatchMapping("/{id}/read")
    public ApiResponse<Void> markConversationRead(@PathVariable UUID id) {
        AuthUser me = currentUserProvider.requireCurrentUser();
        chatService.markConversationRead(id, me.id(), me.role());
        return ApiResponse.success(null, "Conversation marked as read");
    }
}
