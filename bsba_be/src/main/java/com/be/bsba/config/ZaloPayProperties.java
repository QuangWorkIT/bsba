package com.be.bsba.config;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

@Data
@Validated
@ConfigurationProperties(prefix = "zalopay")
public class ZaloPayProperties {

    @NotBlank
    private String appId;

    @NotBlank
    private String key1;

    @NotBlank
    private String key2;

    @NotBlank
    private String createOrderUrl;

    private String queryOrderUrl;

    @NotBlank
    private String callbackUrl;
}
