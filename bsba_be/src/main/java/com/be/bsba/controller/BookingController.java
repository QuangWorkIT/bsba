package com.be.bsba.controller;

import com.be.bsba.dto.request.CreateBookingRequest;
import com.be.bsba.dto.request.CheckInBookingRequest;
import com.be.bsba.constant.BookingStatus;
import com.be.bsba.dto.response.ApiResponse;
import com.be.bsba.dto.response.BookingLookupResponse;
import com.be.bsba.dto.response.BookingResponse;
import com.be.bsba.dto.response.PagedResult;
import com.be.bsba.dto.response.StaffBookingResponse;
import com.be.bsba.security.CurrentUserProvider;
import com.be.bsba.security.CurrentUserProvider.AuthUser;
import com.be.bsba.service.BookingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/bookings")
@RequiredArgsConstructor
public class BookingController {

    private final BookingService bookingService;
    private final CurrentUserProvider currentUserProvider;

    // Customer "My Bookings".
    @GetMapping
    public ResponseEntity<ApiResponse<List<BookingResponse>>> getUserBookings(
            @RequestHeader(value = "X-User-Id", required = false) String userIdStr) {

        // Default testing user if header is missing
        UUID userId = (userIdStr != null) ? UUID.fromString(userIdStr) : UUID.fromString("00000000-0000-0000-0000-000000000001");

        List<BookingResponse> bookings = bookingService.getUserBookings(userId);
        return ResponseEntity.ok(ApiResponse.success(bookings, "User bookings retrieved successfully"));
    }

    @GetMapping("/lookup")
    public ApiResponse<List<BookingLookupResponse>> getBookingByUserStoreAndSlot(
            @RequestParam String userId,
            @RequestParam String storeId) {
        List<BookingLookupResponse> bookings = bookingService.getPendingBookingsByUserAndStore(userId, storeId);
        String message = bookings.isEmpty()
                ? "No pending bookings found for this user and store"
                : "Pending bookings retrieved successfully";
        return ApiResponse.success(bookings, message);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<BookingResponse> createBooking(@Valid @RequestBody CreateBookingRequest request) {
        BookingResponse booking = bookingService.createBooking(request);
        return ApiResponse.success(booking, "Booking created successfully");
    }

    @PostMapping("/checkin")
    public ApiResponse<BookingResponse> checkInBooking(@Valid @RequestBody CheckInBookingRequest request) {
        BookingResponse booking = bookingService.checkInBooking(request);
        return ApiResponse.success(booking, "Booking checked in successfully");
    }

    /**
     * GET /api/v1/bookings/manage?status=..
     * Staff "Manage Bookings": role-aware, paged. The caller's id + role come
     * from the JWT (not request params). {@code status} is optional.
     */
    @GetMapping("/manage")
    public ApiResponse<PagedResult<StaffBookingResponse>> getStaffBookings(
            @RequestParam(required = false) BookingStatus status,
            Pageable pageable) {
        AuthUser me = currentUserProvider.requireCurrentUser();
        PagedResult<StaffBookingResponse> bookings = PagedResult.from(
                bookingService.getStaffBookings(me.id(), me.role(), status, pageable));
        return ApiResponse.success(bookings, "Bookings retrieved successfully");
    }
}
