package com.be.bsba.service;

import com.be.bsba.dto.request.CreateBookingRequest;
import com.be.bsba.dto.response.BookingLookupResponse;
import com.be.bsba.dto.response.BookingResponse;
import java.util.List;
import java.util.UUID;

public interface BookingService {
    List<BookingResponse> getUserBookings(UUID userId);

    BookingLookupResponse getPendingBookingByUserAndStore(String userId, String storeId);

    BookingResponse createBooking(CreateBookingRequest request);
}
