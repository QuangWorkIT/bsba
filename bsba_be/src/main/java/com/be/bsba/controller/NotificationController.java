package com.be.bsba.controller;

import com.be.bsba.dto.response.BaseResponse;
import com.be.bsba.dto.response.notification.NotificationResponse;
import com.be.bsba.service.INotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/notifications")
public class NotificationController {
    private final INotificationService notificationService;

    @GetMapping("/{userId}")
    public ResponseEntity<BaseResponse<List<NotificationResponse>>> getNotificationsForUser(@PathVariable UUID userId) {
        List<NotificationResponse> notifications = notificationService.getNotificationsForUser(userId);
        BaseResponse<List<NotificationResponse>> response = new BaseResponse<>(
                "success", "Notifications retrieved successfully", notifications);
        return ResponseEntity.ok(response);
    }
}
