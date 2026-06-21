package com.be.bsba.service;

import com.be.bsba.constant.BookingStatus;
import com.be.bsba.constant.UserRole;
import com.be.bsba.dto.response.BookingResponse;
import com.be.bsba.dto.response.StaffBookingResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.UUID;

public interface BookingService {

    // Customer "My Bookings": the user's own bookings, newest first.
    List<BookingResponse> getUserBookings(UUID userId);

    /**
     * Staff "Manage Bookings": paged, role-aware list. Staff see bookings of the
     * stores they're assigned to; admin sees all. {@code status} is optional —
     * null returns every status.
     */
    Page<StaffBookingResponse> getStaffBookings(UUID userId, UserRole role, BookingStatus status, Pageable pageable);
}
