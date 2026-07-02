package com.be.bsba.controller;

import com.be.bsba.dto.request.NotificationReadRequest;
import com.be.bsba.dto.response.ApiResponse;
import com.be.bsba.dto.response.notification.NotificationResponse;
import com.be.bsba.service.INotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
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

    @PatchMapping("/read")
    public ApiResponse<List<NotificationResponse>> markNotificationsRead(@RequestBody NotificationReadRequest request) {
        List<NotificationResponse> notifications = notificationService.markNotificationsRead(request.getNotificationIds());
        return ApiResponse.success(notifications, "Notifications marked as read successfully");
    }
}
