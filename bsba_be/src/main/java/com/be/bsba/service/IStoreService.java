package com.be.bsba.service;

import com.be.bsba.dto.projection.NearbyStoreProjection;
import java.util.List;

public interface IStoreService {
    List<NearbyStoreProjection> findNearbyStores(double lat, double lng, double radiusKm);

}
