package com.be.bsba.service;

import com.be.bsba.constant.SpaceSort;
import com.be.bsba.dto.response.SpaceCardResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface SpaceService {
    Page<SpaceCardResponse> getSpaces(Double lat, Double lng, SpaceSort sort, String q, Pageable pageable);
}
