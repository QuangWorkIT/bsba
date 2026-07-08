package com.be.bsba.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalTime;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class UpdateStoreRequest {
    @NotNull(message = "staff id is required")
    private String staffId;

    @NotNull(message = "store id is required")
    private String storeId;
    private String storeName;
    private String description;
    private String address;
    private String coverLetterUrl;
    private String phone;
    private String email;
    private LocalTime openTime;
    private LocalTime closeTime;
    private int totalCapacity;
    private Double chargeFee;
}
