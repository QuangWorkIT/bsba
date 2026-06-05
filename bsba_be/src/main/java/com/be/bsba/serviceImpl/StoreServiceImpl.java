package com.be.bsba.serviceImpl;

import com.be.bsba.dto.projection.NearbyStoreProjection;
import com.be.bsba.repository.StoreRepository;
import com.be.bsba.service.IStoreService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class StoreServiceImpl implements IStoreService {
    private final StoreRepository storeRepository;

    @Override
    public List<NearbyStoreProjection> findNearbyStores(double lat, double lng, double radiusKm) {
        return storeRepository.findNearbyStores(lat, lng, radiusKm);
    }
}
