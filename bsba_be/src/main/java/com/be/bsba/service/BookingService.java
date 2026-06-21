package com.be.bsba.service;

import com.be.bsba.dto.request.CreateBookingRequest;
import com.be.bsba.dto.response.BookingResponse;
import java.util.List;
import java.util.UUID;

public interface BookingService {
    List<BookingResponse> getUserBookings(UUID userId);

    BookingResponse createBooking(CreateBookingRequest request);
}
