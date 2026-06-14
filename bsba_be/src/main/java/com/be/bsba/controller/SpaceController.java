package com.be.bsba.controller;

import com.be.bsba.constant.SpaceSort;
import com.be.bsba.dto.response.ApiResponse;
import com.be.bsba.dto.response.PagedResult;
import com.be.bsba.dto.response.SpaceCardResponse;
import com.be.bsba.service.SpaceService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/spaces")
@RequiredArgsConstructor
public class SpaceController {

    private final SpaceService spaceService;

    @GetMapping
    public ApiResponse<PagedResult<SpaceCardResponse>> getSpaces(
            @RequestParam(required = false) Double lat,
            @RequestParam(required = false) Double lng,
            @RequestParam(defaultValue = "ALL") SpaceSort sort,
            @RequestParam(required = false) String q,
            Pageable pageable) {
        PagedResult<SpaceCardResponse> spaces =
                PagedResult.from(spaceService.getSpaces(lat, lng, sort, q, pageable));
        return ApiResponse.success(spaces, "Spaces retrieved successfully");
    }
}
