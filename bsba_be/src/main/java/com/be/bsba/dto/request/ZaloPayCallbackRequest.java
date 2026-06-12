package com.be.bsba.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ZaloPayCallbackRequest {
    private String data;
    private String mac;
    private Integer type;

    @JsonProperty("app_id")
    private Integer appId;
}
