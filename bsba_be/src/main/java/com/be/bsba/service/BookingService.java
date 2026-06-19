package com.be.bsba.service;

import com.be.bsba.constant.BookingStatus;
import com.be.bsba.constant.UserRole;
import com.be.bsba.dto.response.BookingResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.UUID;

public interface BookingService {

    /**
     * List bookings from the caller's perspective. A customer sees only their own;
     * staff see bookings of the stores they're assigned to; admin sees all.
     * {@code status} is optional — null returns every status.
     */
    Page<BookingResponse> getBookings(UUID userId, UserRole role, BookingStatus status, Pageable pageable);
}
