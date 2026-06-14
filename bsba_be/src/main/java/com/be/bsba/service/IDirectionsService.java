package com.be.bsba.service;

import com.be.bsba.dto.response.RoutePointResponse;

import java.util.List;

public interface IDirectionsService {
    List<RoutePointResponse> getDrivingRoute(
            double originLat,
            double originLng,
            double destinationLat,
            double destinationLng
    );
}
