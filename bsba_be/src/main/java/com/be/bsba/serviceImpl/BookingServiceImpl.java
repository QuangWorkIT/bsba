package com.be.bsba.serviceImpl;

import com.be.bsba.constant.BookingStatus;
import com.be.bsba.constant.TimeSlotStatus;
import com.be.bsba.dto.request.CreateBookingRequest;
import com.be.bsba.dto.response.BookingResponse;
import com.be.bsba.entity.Booking;
import com.be.bsba.entity.Store;
import com.be.bsba.entity.StoreTimeSlot;
import com.be.bsba.entity.User;
import com.be.bsba.exception.BadRequestException;
import com.be.bsba.exception.ResourceNotFoundException;
import com.be.bsba.repository.BookingRepository;
import com.be.bsba.repository.StoreRepository;
import com.be.bsba.repository.StoreTimeSlotRepository;
import com.be.bsba.repository.UserRepository;
import com.be.bsba.service.BookingService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class BookingServiceImpl implements BookingService {

    private final BookingRepository bookingRepository;
    private final UserRepository userRepository;
    private final StoreRepository storeRepository;
    private final StoreTimeSlotRepository storeTimeSlotRepository;
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("EEE, MMM dd");
    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("h:mm a");

    @Override
    @Transactional(readOnly = true)
    public List<BookingResponse> getUserBookings(UUID userId) {
        List<Booking> bookings = bookingRepository.findAllByUserIdOrderByCreatedAtDesc(userId);

        return bookings.stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    @Override
    @Transactional
    public BookingResponse createBooking(CreateBookingRequest request) {
        User user = userRepository.findById(UUID.fromString(request.getUserId()))
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + request.getUserId()));
        Store store = storeRepository.findById(UUID.fromString(request.getStoreId()))
                .orElseThrow(() -> new ResourceNotFoundException("Store not found with id: " + request.getStoreId()));
        StoreTimeSlot slot = storeTimeSlotRepository.findById(UUID.fromString(request.getSlotId()))
                .orElseThrow(() -> new ResourceNotFoundException("Store time slot not found with id: " + request.getSlotId()));

        validateTimeSlotForBooking(slot, store);

        Booking booking = Booking.builder()
                .user(user)
                .store(store)
                .slot(slot)
                .participantCount(request.getParticipantCount())
                .totalPrice(request.getTotalPrice())
                .note(request.getNote())
                .status(BookingStatus.PENDING)
                .build();

        Booking savedBooking = bookingRepository.save(booking);
        return mapToResponse(savedBooking);
    }

    private void validateTimeSlotForBooking(StoreTimeSlot slot, Store store) {
        if (slot.getStore() == null || !store.getId().equals(slot.getStore().getId())) {
            throw new BadRequestException("Store time slot does not belong to store with id: " + store.getId());
        }

        if (!TimeSlotStatus.AVAILABLE.equals(slot.getStatus())) {
            throw new BadRequestException("Store time slot is not available");
        }
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
