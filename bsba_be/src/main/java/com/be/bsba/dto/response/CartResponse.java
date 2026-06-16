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
public class CartResponse {
    private UUID id;
    private UUID userId;
    private UUID storeId;
    private String storeName;
    private String storeImage;
    private String slotDate;
    private String startTime;
    private String endTime;
    private List<CartItemResponse> items;
    private Double totalPrice;
}
