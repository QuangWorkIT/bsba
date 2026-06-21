package com.be.bsba.dto.response;

import com.be.bsba.constant.BookingStatus;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.OffsetDateTime;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BookingResponse {
    private UUID id;
    private String storeName;
    private String storeLocation;
    @JsonProperty("slot_date")
    private LocalDate slotDate;
    @JsonProperty("start_time")
    private LocalTime startTime;
    @JsonProperty("end_time")
    private LocalTime endTime;
    private Integer participants;
    private BigDecimal total;
    private String imageAsset;
    private BookingStatus status;
    private OffsetDateTime createdAt;
}
