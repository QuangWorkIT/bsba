package com.be.bsba.controller;

import com.be.bsba.constant.UserRole;
import com.be.bsba.dto.request.SendMessageRequest;
import com.be.bsba.dto.request.StartConversationRequest;
import com.be.bsba.dto.response.ApiResponse;
import com.be.bsba.dto.response.ConversationResponse;
import com.be.bsba.dto.response.MessageResponse;
import com.be.bsba.dto.response.PagedResult;
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

    @GetMapping
    public ApiResponse<PagedResult<ConversationResponse>> getConversations(
            @RequestParam UUID userId,
            @RequestParam(defaultValue = "CUSTOMER") UserRole role,
            Pageable pageable) {
        PagedResult<ConversationResponse> conversations =
                PagedResult.from(chatService.getConversations(userId, role, pageable));
        return ApiResponse.success(conversations, "Conversations retrieved successfully");
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<ConversationResponse> startConversation(
            @RequestParam UUID userId,
            @Valid @RequestBody StartConversationRequest request) {
        ConversationResponse conversation = chatService.startConversation(userId, request);
        return ApiResponse.success(conversation, "Conversation created successfully");
    }

    @GetMapping("/{id}/messages")
    public ApiResponse<PagedResult<MessageResponse>> getMessages(
            @PathVariable UUID id,
            Pageable pageable) {
        PagedResult<MessageResponse> messages =
                PagedResult.from(chatService.getMessages(id, pageable));
        return ApiResponse.success(messages, "Messages retrieved successfully");
    }

    @PostMapping("/{id}/messages")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<MessageResponse> sendMessage(
            @PathVariable UUID id,
            @RequestParam UUID userId,
            @RequestParam(defaultValue = "CUSTOMER") UserRole role,
            @Valid @RequestBody SendMessageRequest request) {
        MessageResponse message = chatService.sendMessage(id, userId, role, request);
        return ApiResponse.success(message, "Message sent successfully");
    }

    @PatchMapping("/{id}/read")
    public ApiResponse<Void> markConversationRead(
            @PathVariable UUID id,
            @RequestParam UUID userId,
            @RequestParam(defaultValue = "CUSTOMER") UserRole role) {
        chatService.markConversationRead(id, userId, role);
        return ApiResponse.success(null, "Conversation marked as read");
    }
}
