package com.be.bsba.serviceImpl;

import com.be.bsba.dto.response.BookingResponse;
import com.be.bsba.entity.Booking;
import com.be.bsba.repository.BookingRepository;
import com.be.bsba.service.BookingService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class BookingServiceImpl implements BookingService {

    private final BookingRepository bookingRepository;
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("EEE, MMM dd");
    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("h:mm a");

    @Override
    public List<BookingResponse> getUserBookings(UUID userId) {
        List<Booking> bookings = bookingRepository.findAllByUserIdOrderByCreatedAtDesc(userId);

        return bookings.stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    private BookingResponse mapToResponse(Booking booking) {
        String dateStr = "N/A";
        String timeStr = "N/A";

        if (booking.getSlot() != null) {
            dateStr = booking.getSlot().getSlotDate().format(DATE_FORMATTER);
            timeStr = booking.getSlot().getStartTime().format(TIME_FORMATTER) + " - " +
                      booking.getSlot().getEndTime().format(TIME_FORMATTER);
        }

        return BookingResponse.builder()
                .id(booking.getId())
                .storeName(booking.getStore() != null ? booking.getStore().getName() : "Unknown Store")
                .storeLocation(booking.getStore() != null ? booking.getStore().getAddress() : "Unknown Location")
                .date(dateStr)
                .time(timeStr)
                .participants(booking.getParticipantCount())
                .total(booking.getTotalPrice())
                .imageAsset("") // Default empty, UI can handle or we can add store image URL later
                .status(booking.getStatus())
                .createdAt(booking.getCreatedAt())
                .build();
    }
}
