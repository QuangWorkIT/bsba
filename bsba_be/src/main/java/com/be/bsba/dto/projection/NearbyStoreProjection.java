package com.be.bsba.dto.projection;

import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.UUID;

public interface NearbyStoreProjection {
    UUID getId();
    String getName();
    String getDescription();
    String getAddress();
    BigDecimal getLatitude();
    BigDecimal getLongitude();
    BigDecimal getRatingAvg();
    String getCoverImageUrl();
    LocalTime getOpenTime();
    LocalTime getCloseTime();
    Double getDistanceKm();
}
