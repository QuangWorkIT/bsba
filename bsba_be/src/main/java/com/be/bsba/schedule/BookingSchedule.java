package com.be.bsba.schedule;

import com.be.bsba.constant.BookingStatus;
import com.be.bsba.entity.Booking;
import com.be.bsba.repository.BookingRepository;
import com.be.bsba.service.INotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class BookingSchedule {
    private static final ZoneId VIETNAM_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");

    private final BookingRepository bookingRepository;
    private final INotificationService notificationService;

    @Scheduled(cron = "0 0 * * * *", zone = "Asia/Ho_Chi_Minh")
    @Transactional
    public void sendUpcomingBookingReminders() {
        LocalDateTime now = LocalDateTime.now(VIETNAM_ZONE);
        LocalDateTime reminderLimit = now.plusHours(24);
        log.info("Booking reminder schedule started: windowStart={}, windowEnd={}", now, reminderLimit);

        List<Booking> bookings = bookingRepository.findBookingsStartingBetween(
                BookingStatus.CONFIRMED,
                now.toLocalDate(),
                now.toLocalTime(),
                reminderLimit.toLocalDate(),
                reminderLimit.toLocalTime());

        log.info("Booking reminder schedule found {} confirmed booking(s) starting within 24 hours", bookings.size());
        bookings.forEach(booking -> {
            log.debug("Sending booking reminder: bookingId={}, userId={}, slotDate={}, startTime={}",
                    booking.getId(),
                    booking.getUser() != null ? booking.getUser().getId() : null,
                    booking.getSlot() != null ? booking.getSlot().getSlotDate() : null,
                    booking.getSlot() != null ? booking.getSlot().getStartTime() : null);
            notificationService.notifyBookingReminder(booking);
        });
        log.info("Booking reminder schedule completed: processed={} booking(s)", bookings.size());
    }

    @Scheduled(cron = "0 15 * * * *", zone = "Asia/Ho_Chi_Minh")
    @Transactional
    public void cancelExpiredIncompleteBookings() {
        LocalDateTime now = LocalDateTime.now(VIETNAM_ZONE);
        log.info("Expired booking cancellation schedule started: cutoff={}", now);

        List<Booking> expiredBookings = bookingRepository.findExpiredBookingsExcludingStatuses(
                List.of(BookingStatus.COMPLETED, BookingStatus.CANCELLED),
                now.toLocalDate(),
                now.toLocalTime());

        log.info("Expired booking cancellation schedule found {} incomplete expired booking(s)", expiredBookings.size());
        expiredBookings.forEach(booking -> {
            log.debug("Cancelling expired booking: bookingId={}, userId={}, currentStatus={}, slotDate={}, endTime={}",
                    booking.getId(),
                    booking.getUser() != null ? booking.getUser().getId() : null,
                    booking.getStatus(),
                    booking.getSlot() != null ? booking.getSlot().getSlotDate() : null,
                    booking.getSlot() != null ? booking.getSlot().getEndTime() : null);
            booking.setStatus(BookingStatus.CANCELLED);
            notificationService.notifyBookingCancelled(booking);
        });

        if (!expiredBookings.isEmpty()) {
            bookingRepository.saveAll(expiredBookings);
        }
        log.info("Expired booking cancellation schedule completed: cancelled={} booking(s)", expiredBookings.size());
    }
}
