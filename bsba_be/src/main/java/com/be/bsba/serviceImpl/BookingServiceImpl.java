package com.be.bsba.serviceImpl;

import com.be.bsba.constant.BookingStatus;
import com.be.bsba.constant.UserRole;
import com.be.bsba.dto.response.BookingResponse;
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

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class BookingServiceImpl implements BookingService {

    private final BookingRepository bookingRepository;
    private final StoreStaffRepository storeStaffRepository;

    @Override
    @Transactional(readOnly = true)
    public Page<BookingResponse> getBookings(UUID userId, UserRole role, BookingStatus status, Pageable pageable) {
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

        return bookings.map(this::mapToResponse);
    }

    private BookingResponse mapToResponse(Booking booking) {
        User customer = booking.getUser();
        Store store = booking.getStore();
        StoreTimeSlot slot = booking.getSlot();

        return BookingResponse.builder()
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
