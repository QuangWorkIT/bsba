package com.be.bsba.controller;

import com.be.bsba.dto.response.ApiResponse;
import com.be.bsba.dto.response.notification.NotificationResponse;
import com.be.bsba.service.INotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/notifications")
public class NotificationController {
    private final INotificationService notificationService;

    @GetMapping("/{userId}")
    public ApiResponse<List<NotificationResponse>> getNotificationsForUser(@PathVariable UUID userId) {
        List<NotificationResponse> notifications = notificationService.getNotificationsForUser(userId);
        return ApiResponse.success(notifications, "Notifications retrieved successfully");
    }
}
