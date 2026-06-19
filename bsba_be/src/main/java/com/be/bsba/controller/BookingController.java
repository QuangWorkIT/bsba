package com.be.bsba.controller;

import com.be.bsba.constant.BookingStatus;
import com.be.bsba.dto.response.ApiResponse;
import com.be.bsba.dto.response.BookingResponse;
import com.be.bsba.dto.response.PagedResult;
import com.be.bsba.security.CurrentUserProvider;
import com.be.bsba.security.CurrentUserProvider.AuthUser;
import com.be.bsba.service.BookingService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/bookings")
@RequiredArgsConstructor
public class BookingController {

    private final BookingService bookingService;
    private final CurrentUserProvider currentUserProvider;

    /**
     * GET /api/v1/bookings?status=..
     * Role-aware list for the "Manage Bookings" screen. The caller's id + role
     * come from the JWT (not the request params). {@code status} is optional.
     */
    @GetMapping
    public ApiResponse<PagedResult<BookingResponse>> getBookings(
            @RequestParam(required = false) BookingStatus status,
            Pageable pageable) {
        AuthUser me = currentUserProvider.requireCurrentUser();
        PagedResult<BookingResponse> bookings = PagedResult.from(
                bookingService.getBookings(me.id(), me.role(), status, pageable));
        return ApiResponse.success(bookings, "Bookings retrieved successfully");
    }
}
