package com.be.bsba.service;

import com.be.bsba.dto.response.notification.NotificationResponse;

import java.util.List;
import java.util.UUID;

public interface INotificationService {
    List<NotificationResponse> getNotificationsForUser(UUID userId);
}
