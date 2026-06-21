package com.be.bsba.serviceImpl;

import com.be.bsba.constant.BookingStatus;
import com.be.bsba.constant.UserRole;
import com.be.bsba.dto.response.BookingResponse;
import com.be.bsba.dto.response.StaffBookingResponse;
import com.be.bsba.entity.Booking;
import com.be.bsba.entity.Store;
import com.be.bsba.entity.StoreTimeSlot;
import com.be.bsba.entity.User;
import com.be.bsba.repository.BookingRepository;
import com.be.bsba.repository.StoreStaffRepository;
import com.be.bsba.service.BookingService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
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
    private final StoreStaffRepository storeStaffRepository;

    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("EEE, MMM dd");
    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("h:mm a");

    // ── Customer "My Bookings" ──────────────────────────────────────────────
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

    // ── Staff "Manage Bookings" ─────────────────────────────────────────────
    @Override
    @Transactional(readOnly = true)
    public Page<StaffBookingResponse> getStaffBookings(UUID userId, UserRole role, BookingStatus status, Pageable pageable) {
        // Default to newest first when the caller didn't ask for a specific order.
        Pageable effective = pageable.getSort().isSorted()
                ? pageable
                : PageRequest.of(pageable.getPageNumber(), pageable.getPageSize(),
                        Sort.by(Sort.Direction.DESC, "createdAt"));

        Page<Booking> bookings;
        switch (role) {
            case ADMIN -> bookings = (status == null)
                    ? bookingRepository.findAll(effective)
                    : bookingRepository.findByStatus(status, effective);
            case STAFF -> {
                List<UUID> storeIds = storeStaffRepository.findStoreIdsByStaffId(userId);
                if (storeIds.isEmpty()) {
                    return Page.empty(effective);
                }
                bookings = (status == null)
                        ? bookingRepository.findByStoreIdIn(storeIds, effective)
                        : bookingRepository.findByStoreIdInAndStatus(storeIds, status, effective);
            }
            default -> bookings = (status == null)
                    ? bookingRepository.findByUserId(userId, effective)
                    : bookingRepository.findByUserIdAndStatus(userId, status, effective);
        }

        return bookings.map(this::mapToStaffResponse);
    }

    private StaffBookingResponse mapToStaffResponse(Booking booking) {
        User customer = booking.getUser();
        Store store = booking.getStore();
        StoreTimeSlot slot = booking.getSlot();

        return StaffBookingResponse.builder()
                .id(booking.getId())
                .customerId(customer != null ? customer.getId() : null)
                .customerName(customer != null ? customer.getFullName() : null)
                .customerAvatarUrl(customer != null ? customer.getAvatarUrl() : null)
                .storeId(store != null ? store.getId() : null)
                .storeName(store != null ? store.getName() : null)
                .slotDate(slot != null ? slot.getSlotDate() : null)
                .startTime(slot != null ? slot.getStartTime() : null)
                .endTime(slot != null ? slot.getEndTime() : null)
                .participantCount(booking.getParticipantCount())
                .status(booking.getStatus())
                .note(booking.getNote())
                .totalPrice(booking.getTotalPrice())
                .createdAt(booking.getCreatedAt())
                .build();
    }
}
