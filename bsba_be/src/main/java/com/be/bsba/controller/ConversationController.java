package com.be.bsba.controller;

import com.be.bsba.dto.request.SendMessageRequest;
import com.be.bsba.dto.response.ApiResponse;
import com.be.bsba.dto.response.MessageResponse;
import com.be.bsba.service.ChatService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/conversations")
@RequiredArgsConstructor
public class ConversationController {

    private final ChatService chatService;

    @PostMapping("/{id}/messages")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<MessageResponse> sendMessage(
            @PathVariable UUID id,
            @RequestParam UUID userId,
            @Valid @RequestBody SendMessageRequest request) {
        MessageResponse message = chatService.sendMessage(id, userId, request);
        return ApiResponse.success(message, "Message sent successfully");
    }
}
