package com.be.bsba.dto.response;

import com.be.bsba.constant.BookingStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.OffsetDateTime;
import java.util.UUID;

/**
 * A booking row for the staff "Manage Bookings" list. The client formats the
 * time range from {@code startTime}/{@code endTime} and derives today/upcoming
 * from {@code slotDate}. (Separate from the customer-facing {@link BookingResponse}.)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StaffBookingResponse {
    private UUID id;

    private UUID customerId;
    private String customerName;
    private String customerAvatarUrl;

    private UUID storeId;
    private String storeName;

    private LocalDate slotDate;
    private LocalTime startTime;
    private LocalTime endTime;

    private Integer participantCount;
    private BookingStatus status;
    private String note;

    private OffsetDateTime createdAt;
}
