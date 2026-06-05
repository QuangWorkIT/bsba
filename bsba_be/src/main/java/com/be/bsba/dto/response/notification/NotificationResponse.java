package com.be.bsba.dto.response.notification;

import com.be.bsba.entity.Notification;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.OffsetDateTime;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class NotificationResponse {
    private UUID id;
    private String title;
    private String body;
    private String type;
    private Boolean isRead;
    private UUID userId;
    private OffsetDateTime createdAt;

    public static NotificationResponse from(Notification notification) {
        return new NotificationResponse(
                notification.getId(),
                notification.getTitle(),
                notification.getBody(),
                notification.getType(),
                notification.getIsRead(),
                notification.getUser().getId(),
                notification.getCreatedAt()
        );
    }
}
