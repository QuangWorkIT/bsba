package com.be.bsba.controller;

import com.be.bsba.dto.request.CreateBookingRequest;
import com.be.bsba.dto.response.ApiResponse;
import com.be.bsba.dto.response.BookingLookupResponse;
import com.be.bsba.dto.response.BookingResponse;
import com.be.bsba.service.BookingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
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

    @GetMapping
    public ResponseEntity<ApiResponse<List<BookingResponse>>> getUserBookings(
            @RequestHeader(value = "X-User-Id", required = false) String userIdStr) {
        
        // Default testing user if header is missing
        UUID userId = (userIdStr != null) ? UUID.fromString(userIdStr) : UUID.fromString("00000000-0000-0000-0000-000000000001");
        
        List<BookingResponse> bookings = bookingService.getUserBookings(userId);
        return ResponseEntity.ok(ApiResponse.success(bookings, "User bookings retrieved successfully"));
    }

    @GetMapping("/lookup")
    public ApiResponse<BookingLookupResponse> getBookingByUserStoreAndSlot(
            @RequestParam String userId,
            @RequestParam String storeId) {
        BookingLookupResponse booking = bookingService.getPendingBookingByUserAndStore(userId, storeId);
        String message = booking != null
                ? "Pending booking retrieved successfully"
                : "No pending booking found for this user and store";
        return ApiResponse.success(booking, message);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<BookingResponse> createBooking(@Valid @RequestBody CreateBookingRequest request) {
        BookingResponse booking = bookingService.createBooking(request);
        return ApiResponse.success(booking, "Booking created successfully");
    }
}
