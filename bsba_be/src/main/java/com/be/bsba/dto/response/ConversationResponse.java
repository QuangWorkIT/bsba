package com.be.bsba.dto.response;

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
public class ConversationResponse {
    private UUID id;
    private UUID storeId;
    private String storeName;
    private String storeCoverImageUrl;
    private UUID customerId;
    private String customerName;
    private String customerAvatarUrl;
    private String lastMessagePreview;
    private OffsetDateTime lastMessageAt;
    private long unreadCount;
    private OffsetDateTime createdAt;
    private OffsetDateTime updatedAt;
}
