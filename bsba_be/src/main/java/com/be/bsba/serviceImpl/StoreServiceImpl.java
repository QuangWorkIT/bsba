package com.be.bsba.serviceImpl;

import com.be.bsba.dto.projection.NearbyStoreProjection;
import com.be.bsba.repository.StoreRepository;
import com.be.bsba.service.IStoreService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class StoreServiceImpl implements IStoreService {
    private final StoreRepository storeRepository;

    @Override
    @Transactional(readOnly = true)
    public List<NearbyStoreProjection> findNearbyStores(double lat, double lng, double radiusKm) {
        return storeRepository.findNearbyStores(lat, lng, radiusKm);
    }

    @Override
    @Transactional(readOnly = true)
    public List<NearbyStoreProjection> searchStores(String name, String description, String address) {
        return storeRepository.searchStores(
                normalizeSearchParam(name),
                normalizeSearchParam(description),
                normalizeSearchParam(address)
        );
    }

    private String normalizeSearchParam(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }
}
