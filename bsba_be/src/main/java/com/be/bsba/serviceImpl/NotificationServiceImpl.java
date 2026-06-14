package com.be.bsba.serviceImpl;

import com.be.bsba.dto.response.notification.NotificationResponse;
import com.be.bsba.entity.Notification;
import com.be.bsba.repository.NotificationRepository;
import com.be.bsba.service.INotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class NotificationServiceImpl implements INotificationService {
    private final NotificationRepository notificationRepository;

    @Override
    public List<NotificationResponse> getNotificationsForUser(UUID userId) {
        List<Notification> notifications = notificationRepository.getByUserId(userId);
        return notifications.stream()
                .map(NotificationResponse::from)
                .toList();
    }
}
