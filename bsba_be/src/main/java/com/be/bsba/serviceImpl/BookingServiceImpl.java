package com.be.bsba.serviceImpl;

import com.be.bsba.constant.BookingStatus;
import com.be.bsba.constant.TimeSlotStatus;
import com.be.bsba.dto.request.CheckInBookingRequest;
import com.be.bsba.dto.request.CreateBookingRequest;
import com.be.bsba.dto.response.BookingLookupResponse;
import com.be.bsba.constant.UserRole;
import com.be.bsba.dto.response.BookingResponse;
import com.be.bsba.dto.response.StaffBookingResponse;
import com.be.bsba.entity.BoardGame;
import com.be.bsba.entity.Booking;
import com.be.bsba.entity.BookingCart;
import com.be.bsba.entity.BookingCartGame;
import com.be.bsba.entity.Store;
import com.be.bsba.entity.StoreTimeSlot;
import com.be.bsba.entity.User;
import com.be.bsba.exception.BadRequestException;
import com.be.bsba.exception.ResourceNotFoundException;
import com.be.bsba.repository.BookingCartGameRepository;
import com.be.bsba.repository.BookingCartRepository;
import com.be.bsba.repository.BookingRepository;
import com.be.bsba.repository.StoreStaffRepository;
import com.be.bsba.repository.StoreRepository;
import com.be.bsba.repository.StoreTimeSlotRepository;
import com.be.bsba.repository.UserRepository;
import com.be.bsba.service.BookingService;
import com.be.bsba.service.INotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class BookingServiceImpl implements BookingService {

    private final BookingRepository bookingRepository;
    private final BookingCartRepository bookingCartRepository;
    private final BookingCartGameRepository bookingCartGameRepository;
    private final UserRepository userRepository;
    private final StoreRepository storeRepository;
    private final StoreTimeSlotRepository storeTimeSlotRepository;
    private final StoreStaffRepository storeStaffRepository;
    private final INotificationService notificationService;

    private static final ZoneId VIETNAM_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("EEE, MMM dd");
    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("h:mm a");

    // ── Customer "My Bookings" ──────────────────────────────────────────────
    private BigDecimal calculateBookingTotal(Booking booking) {
        BigDecimal retailPrice = bookingCartRepository.findByBookingId(booking.getId())
                .map(BookingCart::getId)
                .map(bookingCartGameRepository::findAllByCartId)
                .map(this::calculateRetailPrice)
                .orElse(BigDecimal.ZERO);

        return retailPrice.add(calculateStoreCharge(booking));
    }

    private BigDecimal calculateRetailPrice(List<BookingCartGame> cartGames) {
        if (cartGames == null) {
            return BigDecimal.ZERO;
        }

        return cartGames.stream()
                .map(this::calculateBookingGamePrice)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private BigDecimal calculateBookingGamePrice(BookingCartGame cartGame) {
        BoardGame boardGame = cartGame.getBoardGame();
        BigDecimal rentalPrice = boardGame != null && boardGame.getRentalPrice() != null
                ? boardGame.getRentalPrice()
                : BigDecimal.ZERO;
        int quantity = cartGame.getQuantity() != null ? cartGame.getQuantity() : 0;
        return rentalPrice.multiply(BigDecimal.valueOf(quantity));
    }

    private BigDecimal calculateStoreCharge(Booking booking) {
        Store store = booking.getStore();
        if (store == null) {
            return BigDecimal.ZERO;
        }

        Double chargeFee = store.getChargeFee();
        return chargeFee != null ? BigDecimal.valueOf(chargeFee) : BigDecimal.ZERO;
    }

    @Override
    @Transactional(readOnly = true)
    public List<BookingResponse> getUserBookings(UUID userId) {
        List<Booking> bookings = bookingRepository.findAllByUserIdOrderByCreatedAtDesc(userId);

        return bookings.stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<BookingLookupResponse> getPendingBookingsByUserAndStore(String userIdValue, String storeIdValue) {
        UUID userId = parseUuid(userIdValue, "User ID");
        UUID storeId = parseUuid(storeIdValue, "Store ID");

        return bookingRepository.findByUserIdAndStoreIdAndStatusOrderBySlotSlotDateAscSlotStartTimeAsc(
                        userId,
                        storeId,
                        BookingStatus.PENDING)
                .stream()
                .map(this::mapToLookupResponse)
                .toList();
    }

    @Override
    @Transactional
    public BookingResponse createBooking(CreateBookingRequest request) {
        User user = userRepository.findById(UUID.fromString(request.getUserId()))
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + request.getUserId()));
        Store store = storeRepository.findById(UUID.fromString(request.getStoreId()))
                .orElseThrow(() -> new ResourceNotFoundException("Store not found with id: " + request.getStoreId()));
        StoreTimeSlot slot = storeTimeSlotRepository.findById(UUID.fromString(request.getSlotId()))
                .orElseThrow(() -> new ResourceNotFoundException("Store time slot not found with id: " + request.getSlotId()));

        validateUserHasNotBookedSlot(user, slot);
        validateTimeSlotForBooking(slot, store);

        String qrCode = generateQrCode();
        Booking booking = Booking.builder()
                .user(user)
                .store(store)
                .slot(slot)
                .qrCode(qrCode)
                .participantCount(request.getParticipantCount())
                .note(request.getNote())
                .status(BookingStatus.PENDING)
                .build();

        Booking savedBooking = bookingRepository.save(booking);
        return mapToResponse(savedBooking);
    }

    @Override
    @Transactional
    public BookingResponse checkInBooking(CheckInBookingRequest request) {
        Booking booking = bookingRepository.findByQrCode(request.getQrCode().trim())
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found with QR code: " + request.getQrCode()));

        validateBookingCanBeCheckedIn(booking);

        booking.setStatus(BookingStatus.COMPLETED);
        Booking savedBooking = bookingRepository.save(booking);
        notificationService.notifyBookingCompleted(savedBooking);
        return mapToResponse(savedBooking);
    }

    private String generateQrCode() {
        return UUID.randomUUID().toString().substring(0,6);
    }

    private void validateUserHasNotBookedSlot(User user, StoreTimeSlot slot) {
        if (bookingRepository.existsByUserIdAndSlotId(user.getId(), slot.getId())) {
            throw new BadRequestException("User already booked this slot.");
        }
    }

    private void validateBookingCanBeCheckedIn(Booking booking) {
        if (!BookingStatus.CONFIRMED.equals(booking.getStatus())) {
            throw new BadRequestException("The booking is not confirmed");
        }

        StoreTimeSlot slot = booking.getSlot();
        if (slot == null || slot.getSlotDate() == null || slot.getStartTime() == null || slot.getEndTime() == null) {
            throw new BadRequestException("The booking is overdue");
        }

        LocalDateTime now = LocalDateTime.now(VIETNAM_ZONE);
        LocalDateTime slotStart = LocalDateTime.of(slot.getSlotDate(), slot.getStartTime());
        LocalDateTime slotEnd = LocalDateTime.of(slot.getSlotDate(), slot.getEndTime());

        if (now.isBefore(slotStart) || now.isAfter(slotEnd)) {
            log.warn("Booking check-in attempt outside of slot time. Now: {}, Slot Start: {}, Slot End: {}", now, slotStart, slotEnd);
            throw new BadRequestException("The booking is overdue");
        }
    }

    private UUID parseUuid(String value, String fieldName) {
        try {
            return UUID.fromString(value);
        } catch (IllegalArgumentException ex) {
            throw new BadRequestException(fieldName + " must be a valid UUID");
        }
    }

    private void validateTimeSlotForBooking(StoreTimeSlot slot, Store store) {
        if (slot.getStore() == null || !store.getId().equals(slot.getStore().getId())) {
            throw new BadRequestException("Store time slot does not belong to store with id: " + store.getId());
        }

        if (!TimeSlotStatus.AVAILABLE.equals(slot.getStatus())) {
            throw new BadRequestException("Store time slot is not available");
        }
    }

    private BookingLookupResponse mapToLookupResponse(Booking booking) {
        UUID cartId = bookingCartRepository.findByBookingId(booking.getId())
                .map(BookingCart::getId)
                .orElse(null);

        return BookingLookupResponse.builder()
                .bookingId(booking.getId())
                .cartId(cartId)
                .slotId(booking.getSlot() != null ? booking.getSlot().getId() : null)
                .build();
    }

    private BookingResponse mapToResponse(Booking booking) {
        StoreTimeSlot slot = booking.getSlot();

        return BookingResponse.builder()
                .id(booking.getId())
                .qrCode(booking.getQrCode())
                .slotId(booking.getSlot() != null ? booking.getSlot().getId() : null)
                .storeName(booking.getStore() != null ? booking.getStore().getName() : "Unknown Store")
                .storeLocation(booking.getStore() != null ? booking.getStore().getAddress() : "Unknown Location")
                .slotDate(slot != null ? slot.getSlotDate() : null)
                .startTime(slot != null ? slot.getStartTime() : null)
                .endTime(slot != null ? slot.getEndTime() : null)
                .participants(booking.getParticipantCount())
                .total(calculateBookingTotal(booking))
                .imageAsset(booking.getStore().getCoverImageUrl() != null ? booking.getStore().getCoverImageUrl() : "") // Default empty, UI can handle or we can add store image URL later
                .status(booking.getStatus())
                .createdAt(booking.getCreatedAt())
                .build();
    }

    // ── Staff "Manage Bookings" ─────────────────────────────────────────────
    @Override
    @Transactional(readOnly = true)
    public Page<StaffBookingResponse> getStaffBookings(UUID userId, UserRole role, BookingStatus status, Pageable pageable) {
        // Default to first when the caller didn't ask for a specific order.
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

        return bookings.map(this::mapToStaffResponse);
    }

    private StaffBookingResponse mapToStaffResponse(Booking booking) {
        User customer = booking.getUser();
        Store store = booking.getStore();
        StoreTimeSlot slot = booking.getSlot();

        return StaffBookingResponse.builder()
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
                .createdAt(booking.getCreatedAt())
                .build();
    }
}
