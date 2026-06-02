package com.be.bsba.dto.response;

import lombok.*;

import java.time.OffsetDateTime;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ReviewDto {

    private UUID id;
    private Integer rating;
    private String comment;
    private String userFullName;
    private String userAvatarUrl;
    private OffsetDateTime createdAt;
}
