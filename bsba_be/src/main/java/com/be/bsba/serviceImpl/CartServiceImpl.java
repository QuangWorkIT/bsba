package com.be.bsba.serviceImpl;

import com.be.bsba.dto.request.CreateCartRequest;
import com.be.bsba.dto.response.CartResponse;
import com.be.bsba.entity.Booking;
import com.be.bsba.entity.BookingCart;
import com.be.bsba.entity.Store;
import com.be.bsba.entity.StoreTimeSlot;
import com.be.bsba.exception.BadRequestException;
import com.be.bsba.exception.ResourceNotFoundException;
import com.be.bsba.repository.BookingCartRepository;
import com.be.bsba.repository.BookingRepository;
import com.be.bsba.service.ICartService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CartServiceImpl implements ICartService {
    private final BookingRepository bookingRepository;
    private final BookingCartRepository bookingCartRepository;

    @Override
    @Transactional
    public CartResponse createCart(CreateCartRequest request) {
        UUID bookingId = parseUuid(request.getBookingId());

        if (bookingCartRepository.existsByBookingId(bookingId)) {
            throw new BadRequestException("Card already exists for booking id: " + bookingId);
        }

        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found with id: " + bookingId));

        BookingCart card = BookingCart.builder()
                .booking(booking)
                .note(request.getNote())
                .build();

        BookingCart savedCard = bookingCartRepository.save(card);
        return mapToResponse(savedCard);
    }

    private UUID parseUuid(String value) {
        try {
            return UUID.fromString(value);
        } catch (IllegalArgumentException ex) {
            throw new BadRequestException("Booking ID" + " must be a valid UUID");
        }
    }

    private CartResponse mapToResponse(BookingCart card) {
        Booking booking = card.getBooking();
        Store store = booking.getStore();
        StoreTimeSlot slot = booking.getSlot();

        return CartResponse.builder()
                .id(card.getId())
                .userId(booking.getUser() != null ? booking.getUser().getId() : null)
                .bookingId(booking.getId())
                .storeId(store != null ? store.getId() : null)
                .storeName(store != null ? store.getName() : null)
                .storeImage(store != null ? store.getCoverImageUrl() : null)
                .slotDate(slot != null && slot.getSlotDate() != null ? slot.getSlotDate().toString() : null)
                .startTime(slot != null && slot.getStartTime() != null ? slot.getStartTime().toString() : null)
                .endTime(slot != null && slot.getEndTime() != null ? slot.getEndTime().toString() : null)
                .build();
    }
}
