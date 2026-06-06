package com.be.bsba.controller;


import com.be.bsba.dto.projection.NearbyStoreProjection;
import com.be.bsba.dto.response.ApiResponse;
import com.be.bsba.dto.response.RoutePointResponse;
import com.be.bsba.service.IDirectionsService;
import com.be.bsba.service.IStoreService;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Positive;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/map")
public class MapController {
    private final IStoreService storeService;
    private final IDirectionsService directionsService;

    @GetMapping("/nearby")
    public ApiResponse<List<NearbyStoreProjection>> findNearbyStores(
            @RequestParam
            @DecimalMin("-90.0")
            @DecimalMax("90.0")
            double lat,

            @RequestParam
            @DecimalMin("-180.0")
            @DecimalMax("180.0")
            double lng,

            @RequestParam(defaultValue = "5")
            @Positive
            @Max(50)
            double radiusKm
    ) {
        List<NearbyStoreProjection> nearbyStores = storeService.findNearbyStores(lat, lng, radiusKm);
        return ApiResponse.success(nearbyStores, "Nearby stores retrieved successfully");
    }

    @GetMapping("/search")
    public ApiResponse<List<NearbyStoreProjection>> searchStores(
            @RequestParam(required = false) String name,
            @RequestParam(required = false) String description,
            @RequestParam(required = false) String address
    ) {
        List<NearbyStoreProjection> stores = storeService.searchStores(name, description, address);
        return ApiResponse.success(stores, "Stores retrieved successfully");
    }

    @GetMapping("/directions")
    public ApiResponse<List<RoutePointResponse>> getDrivingDirections(
            @RequestParam
            @DecimalMin("-90.0")
            @DecimalMax("90.0")
            double originLat,

            @RequestParam
            @DecimalMin("-180.0")
            @DecimalMax("180.0")
            double originLng,

            @RequestParam
            @DecimalMin("-90.0")
            @DecimalMax("90.0")
            double destinationLat,

            @RequestParam
            @DecimalMin("-180.0")
            @DecimalMax("180.0")
            double destinationLng
    ) {
        List<RoutePointResponse> route = directionsService.getDrivingRoute(
                originLat,
                originLng,
                destinationLat,
                destinationLng
        );
        return ApiResponse.success(route, "Driving directions retrieved successfully");
    }
}
