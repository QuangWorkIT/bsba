package com.be.bsba.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CartDetailResponse {
    private UUID id;
    private UUID bookingId;
    private UUID storeId;
    private String storeName;
    private String storeImage;
    private String slotDate;
    private String startTime;
    private String endTime;
    private Integer participants;
    private List<BoardGameResponse> boardGames;
    private double chargeFee;
    private double retailPrice;
    private double totalPrice;
}
