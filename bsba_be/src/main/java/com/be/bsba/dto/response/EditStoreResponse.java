package com.be.bsba.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalTime;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class EditStoreResponse {
    private String id;
    private String storeName;
    private String description;
    private String address;
    private String coverLetterUrl;
    private String phone;
    private String email;
    private LocalTime openTime;
    private LocalTime closeTime;
    private int totalCapacity;
    private double chargeFee;
}
