package com.be.bsba.serviceImpl;

import com.be.bsba.constant.MessageType;
import com.be.bsba.constant.SenderType;
import com.be.bsba.dto.request.SendMessageRequest;
import com.be.bsba.dto.response.MessageResponse;
import com.be.bsba.entity.Conversation;
import com.be.bsba.entity.Message;
import com.be.bsba.entity.User;
import com.be.bsba.exception.ResourceNotFoundException;
import com.be.bsba.repository.ConversationRepository;
import com.be.bsba.repository.MessageRepository;
import com.be.bsba.repository.UserRepository;
import com.be.bsba.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ChatServiceImpl implements ChatService {

    private final ConversationRepository conversationRepository;
    private final MessageRepository messageRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional
    public MessageResponse sendMessage(UUID conversationId, UUID userId, SendMessageRequest request) {
        Conversation conversation = conversationRepository.findById(conversationId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Conversation not found with id: " + conversationId));

        User sender = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "User not found with id: " + userId));

        // The conversation owner is the customer; anyone else replying is staff.
        SenderType senderType = sender.getId().equals(conversation.getUser().getId())
                ? SenderType.CUSTOMER
                : SenderType.STAFF;

        MessageType type = request.getType() != null ? request.getType() : MessageType.TEXT;

        Message message = Message.builder()
                .conversation(conversation)
                .sender(sender)
                .senderType(senderType)
                .content(request.getContent())
                .type(type)
                .isRead(false)
                .build();

        Message savedMessage = messageRepository.save(message);

        // Keep the denormalized inbox-preview fields in sync.
        conversation.setLastMessagePreview(savedMessage.getContent());
        conversation.setLastMessageAt(savedMessage.getCreatedAt());
        conversationRepository.save(conversation);

        return mapToResponse(savedMessage);
    }

    private MessageResponse mapToResponse(Message message) {
        return MessageResponse.builder()
                .id(message.getId())
                .conversationId(message.getConversation().getId())
                .senderId(message.getSender() != null ? message.getSender().getId() : null)
                .senderType(message.getSenderType())
                .content(message.getContent())
                .type(message.getType())
                .isRead(message.getIsRead())
                .createdAt(message.getCreatedAt())
                .build();
    }
}
