package com.be.bsba.dto.response;

import lombok.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StoreDetailResponse {

    private UUID id;
    private String name;
    private String description;
    private String address;
    private BigDecimal latitude;
    private BigDecimal longitude;
    private String phone;
    private String email;
    private String coverImageUrl;
    private Integer totalCapacity;
    private BigDecimal ratingAvg;
    private Long reviewCount;
    private Boolean isFavorited;

    private List<StoreImageDto> images;
    private List<BoardGameDto> boardGames;
    private List<TimeSlotDto> timeSlots;
    private List<ReviewDto> reviews;
}
