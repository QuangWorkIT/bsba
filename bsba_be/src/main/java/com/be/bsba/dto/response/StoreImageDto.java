package com.be.bsba.dto.response;

import lombok.*;

import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StoreImageDto {

    private UUID id;
    private String imageUrl;
    private Integer displayOrder;
}
