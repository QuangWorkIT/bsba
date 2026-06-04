package com.be.bsba.dto.response;

import com.be.bsba.constant.MessageType;
import com.be.bsba.constant.SenderType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.OffsetDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MessageResponse {
    private UUID id;
    private UUID conversationId;
    private UUID senderId;
    private SenderType senderType;
    private String content;
    private MessageType type;
    private Boolean isRead;
    private OffsetDateTime createdAt;
}
