package com.be.bsba.serviceImpl;

import com.be.bsba.dto.response.notification.NotificationResponse;
import com.be.bsba.entity.Booking;
import com.be.bsba.entity.Notification;
import com.be.bsba.exception.ResourceNotFoundException;
import com.be.bsba.repository.NotificationRepository;
import com.be.bsba.service.INotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import java.time.format.DateTimeFormatter;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class NotificationServiceImpl implements INotificationService {
    private static final String NOTIFICATIONS_TOPIC = "/topic/notifications";
    private static final String BOOKING_CONFIRMED_TYPE = "BOOKING_CONFIRMED";
    private static final String BOOKING_CANCELLED_TYPE = "BOOKING_CANCELLED";
    private static final String BOOKING_REMINDER_TYPE = "BOOKING_REMINDER";
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("MMM dd, yyyy");
    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("HH:mm");

    private final NotificationRepository notificationRepository;
    private final SimpMessagingTemplate messagingTemplate;

    @Override
    public List<NotificationResponse> getNotificationsForUser(UUID userId) {
        List<Notification> notifications = notificationRepository.getByUserIdOrderByCreatedAtDesc(userId);
        return notifications.stream()
                .map(NotificationResponse::from)
                .toList();
    }

    @Override
    @Transactional
    public List<NotificationResponse> markNotificationsRead(List<UUID> notificationIds) {
        if (notificationIds == null || notificationIds.isEmpty()) {
            return List.of();
        }

        Set<UUID> requestedIds = new LinkedHashSet<>(notificationIds);
        List<Notification> notifications = notificationRepository.findAllById(requestedIds);
        Set<UUID> foundIds = notifications.stream()
                .map(Notification::getId)
                .collect(java.util.stream.Collectors.toSet());

        List<UUID> missingIds = requestedIds.stream()
                .filter(id -> !foundIds.contains(id))
                .toList();
        if (!missingIds.isEmpty()) {
            throw new ResourceNotFoundException("Notifications not found: " + missingIds);
        }

        notifications.forEach(notification -> notification.setIsRead(true));
        return notificationRepository.saveAll(notifications).stream()
                .map(NotificationResponse::from)
                .toList();
    }

    @Override
    public NotificationResponse notifyBookingConfirmed(Booking booking) {
        return notifyBookingStatusChanged(
                booking,
                "Booking confirmed",
                "Your booking at %s has been confirmed.",
                BOOKING_CONFIRMED_TYPE);
    }

    @Override
    public NotificationResponse notifyBookingCancelled(Booking booking) {
        return notifyBookingStatusChanged(
                booking,
                "Booking cancelled",
                "Your booking at %s has been cancelled.",
                BOOKING_CANCELLED_TYPE);
    }

    @Override
    public NotificationResponse notifyBookingReminder(Booking booking) {
        requireBookingWithUser(booking);

        String storeName = booking.getStore() != null ? booking.getStore().getName() : "your store";
        String playTime = booking.getSlot() != null
                ? booking.getSlot().getSlotDate().format(DATE_FORMATTER)
                + " at "
                + booking.getSlot().getStartTime().format(TIME_FORMATTER)
                : "soon";
        String body = "Your booking at " + storeName + " starts on " + playTime + ".";

        return notificationRepository
                .findFirstByUserIdAndTypeAndBodyOrderByCreatedAtDesc(
                        booking.getUser().getId(),
                        BOOKING_REMINDER_TYPE,
                        body)
                .map(NotificationResponse::from)
                .orElseGet(() -> saveAndPublish(
                        "Booking reminder",
                        body,
                        BOOKING_REMINDER_TYPE,
                        booking));
    }

    private NotificationResponse notifyBookingStatusChanged(
            Booking booking,
            String title,
            String bodyTemplate,
            String type) {
        requireBookingWithUser(booking);

        String storeName = booking.getStore() != null ? booking.getStore().getName() : "your store";
        return saveAndPublish(title, String.format(bodyTemplate, storeName), type, booking);
    }

    private void requireBookingWithUser(Booking booking) {
        if (booking == null || booking.getUser() == null) {
            throw new IllegalArgumentException("Booking and booking user are required");
        }
    }

    private NotificationResponse saveAndPublish(String title, String body, String type, Booking booking) {
        Notification notification = Notification.builder()
                .title(title)
                .body(body)
                .type(type)
                .isRead(false)
                .user(booking.getUser())
                .build();

        NotificationResponse response = NotificationResponse.from(notificationRepository.saveAndFlush(notification));
        publishAfterCommit(response);
        return response;
    }

    private void publishAfterCommit(NotificationResponse notification) {
        Runnable send = () -> messagingTemplate.convertAndSend(NOTIFICATIONS_TOPIC, notification);

        if (TransactionSynchronizationManager.isSynchronizationActive()) {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                @Override
                public void afterCommit() {
                    send.run();
                }
            });
        } else {
            send.run();
        }
    }
}
