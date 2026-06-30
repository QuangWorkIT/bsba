package com.be.bsba.service;

import com.be.bsba.dto.response.notification.NotificationResponse;
import com.be.bsba.entity.Booking;

import java.util.List;
import java.util.UUID;

public interface INotificationService {
    List<NotificationResponse> getNotificationsForUser(UUID userId);
    NotificationResponse notifyBookingConfirmed(Booking booking);
    NotificationResponse notifyBookingCancelled(Booking booking);
    NotificationResponse notifyBookingReminder(Booking booking);
}
