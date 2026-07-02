package com.be.bsba.serviceImpl;

import com.be.bsba.constant.BookingStatus;
import com.be.bsba.dto.request.CheckInBookingRequest;
import com.be.bsba.dto.response.BookingResponse;
import com.be.bsba.entity.Booking;
import com.be.bsba.entity.Store;
import com.be.bsba.entity.StoreTimeSlot;
import com.be.bsba.exception.BadRequestException;
import com.be.bsba.repository.BookingCartGameRepository;
import com.be.bsba.repository.BookingCartRepository;
import com.be.bsba.repository.BookingRepository;
import com.be.bsba.repository.StoreRepository;
import com.be.bsba.repository.StoreStaffRepository;
import com.be.bsba.repository.StoreTimeSlotRepository;
import com.be.bsba.repository.UserRepository;
import com.be.bsba.service.INotificationService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class BookingServiceImplTests {

    private static final ZoneId VIETNAM_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");
    private static final UUID BOOKING_ID = UUID.fromString("11111111-1111-1111-1111-111111111111");
    private static final String QR_CODE = "ABC123";

    @Mock
    private BookingRepository bookingRepository;

    @Mock
    private BookingCartRepository bookingCartRepository;

    @Mock
    private BookingCartGameRepository bookingCartGameRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private StoreRepository storeRepository;

    @Mock
    private StoreTimeSlotRepository storeTimeSlotRepository;

    @Mock
    private StoreStaffRepository storeStaffRepository;

    @Mock
    private INotificationService notificationService;

    private BookingServiceImpl service;

    @BeforeEach
    void setUp() {
        service = new BookingServiceImpl(
                bookingRepository,
                bookingCartRepository,
                bookingCartGameRepository,
                userRepository,
                storeRepository,
                storeTimeSlotRepository,
                storeStaffRepository,
                notificationService
        );
    }

    @Test
    void checkInBookingRejectsBookingThatIsNotConfirmed() {
        Booking booking = Booking.builder()
                .id(BOOKING_ID)
                .qrCode(QR_CODE)
                .status(BookingStatus.PENDING)
                .build();
        when(bookingRepository.findByQrCode(QR_CODE)).thenReturn(Optional.of(booking));

        BadRequestException exception = assertThrows(
                BadRequestException.class,
                () -> service.checkInBooking(request()));

        assertEquals("The booking is not confirmed", exception.getMessage());
        verify(bookingRepository, never()).save(any());
        verifyNoInteractions(notificationService);
    }

    @Test
    void checkInBookingRejectsBookingOutsideSlotWindow() {
        LocalDateTime yesterday = LocalDateTime.now(VIETNAM_ZONE).minusDays(1);
        Booking booking = confirmedBooking(StoreTimeSlot.builder()
                .slotDate(yesterday.toLocalDate())
                .startTime(yesterday.minusHours(1).toLocalTime())
                .endTime(yesterday.toLocalTime())
                .build());
        when(bookingRepository.findByQrCode(QR_CODE)).thenReturn(Optional.of(booking));

        BadRequestException exception = assertThrows(
                BadRequestException.class,
                () -> service.checkInBooking(request()));

        assertEquals("The booking is overdue", exception.getMessage());
        verify(bookingRepository, never()).save(any());
        verifyNoInteractions(notificationService);
    }

    @Test
    void checkInBookingCompletesAndNotifiesWhenBookingIsConfirmedInsideSlotWindow() {
        LocalDateTime now = LocalDateTime.now(VIETNAM_ZONE);
        Booking booking = confirmedBooking(StoreTimeSlot.builder()
                .slotDate(now.toLocalDate())
                .startTime(now.minusMinutes(5).toLocalTime())
                .endTime(now.plusMinutes(5).toLocalTime())
                .build());
        when(bookingRepository.findByQrCode(QR_CODE)).thenReturn(Optional.of(booking));
        when(bookingRepository.save(booking)).thenReturn(booking);
        when(bookingCartRepository.findByBookingId(BOOKING_ID)).thenReturn(Optional.empty());

        BookingResponse response = service.checkInBooking(request());

        assertEquals(BookingStatus.COMPLETED, response.getStatus());
        assertEquals(BookingStatus.COMPLETED, booking.getStatus());
        verify(bookingRepository).save(booking);
        verify(notificationService).notifyBookingCompleted(booking);
    }

    private CheckInBookingRequest request() {
        return new CheckInBookingRequest(QR_CODE);
    }

    private Booking confirmedBooking(StoreTimeSlot slot) {
        return Booking.builder()
                .id(BOOKING_ID)
                .qrCode(QR_CODE)
                .status(BookingStatus.CONFIRMED)
                .store(Store.builder().name("Board Game Store").build())
                .slot(slot)
                .build();
    }
}
