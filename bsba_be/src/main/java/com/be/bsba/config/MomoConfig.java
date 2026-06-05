package com.be.bsba.config;

import com.be.bsba.dto.momo.MomoPaymentRequest;
import com.be.bsba.dto.momo.MomoPaymentResponse;
import com.fasterxml.jackson.databind.ObjectMapper;
import feign.Request;
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import java.util.concurrent.TimeUnit;

@Configuration
@EnableFeignClients(basePackages = "com.be.bsba.config")
public class MomoConfig {

    @Bean
    public ObjectMapper objectMapper() {
        return new ObjectMapper();
    }

    @Bean
    @ConfigurationProperties(prefix = "momo.api")
    public MomoApiProperties momoApiProperties() {
        return new MomoApiProperties();
    }

    @Bean
    public Request.Options momoFeignOptions(MomoApiProperties props) {
        long timeout = props.getTimeoutSeconds() > 0 ? props.getTimeoutSeconds() : 30;
        return new Request.Options(timeout, TimeUnit.SECONDS, timeout, TimeUnit.SECONDS, true);
    }

    @Data
    public static class MomoApiProperties {
        private String baseUrl;
        private String path;
        private String partnerCode;
        private String accessKey;
        private String secretKey;
        private String ipnUrl;
        private String redirectUrl;
        private String requestType;
        private String lang;
        private long timeoutSeconds = 30;
    }

    @FeignClient(name = "momoClient", url = "${momo.api.base-url}")
    public interface MomoFeignClient {
        @PostMapping("${momo.api.path}")
        MomoPaymentResponse createPayment(@RequestBody MomoPaymentRequest request);
    }
}
