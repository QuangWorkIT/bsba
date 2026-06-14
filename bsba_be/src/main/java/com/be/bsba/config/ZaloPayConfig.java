package com.be.bsba.config;

import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.core.env.Profiles;
import org.springframework.web.client.RestClient;

import java.net.URI;
import java.util.Locale;

@Configuration
@RequiredArgsConstructor
@EnableConfigurationProperties(ZaloPayProperties.class)
public class ZaloPayConfig {

    private final ZaloPayProperties properties;
    private final Environment environment;

    @PostConstruct
    void validateCallbackUrl() {
        URI callbackUri;
        try {
            callbackUri = URI.create(properties.getCallbackUrl().trim());
        } catch (IllegalArgumentException exception) {
            throw new IllegalStateException("zalopay.callback-url must be a valid URL", exception);
        }

        String host = callbackUri.getHost();
        if (host == null) {
            throw new IllegalStateException("zalopay.callback-url must include a valid host");
        }

        boolean devOrTest = environment.acceptsProfiles(Profiles.of("dev", "test"));
        if (devOrTest) {
            String scheme = callbackUri.getScheme();
            if (!"http".equalsIgnoreCase(scheme) && !"https".equalsIgnoreCase(scheme)) {
                throw new IllegalStateException("zalopay.callback-url must use HTTP or HTTPS in dev/test profiles");
            }
            return;
        }

        String normalizedHost = host.toLowerCase(Locale.ROOT);
        if (!"https".equalsIgnoreCase(callbackUri.getScheme())
                || isLocalHost(normalizedHost)
                || isNgrokHost(normalizedHost)) {
            throw new IllegalStateException(
                    "zalopay.callback-url must be a public HTTPS URL outside dev/test profiles"
            );
        }
    }

    @Bean
    RestClient zaloPayRestClient() {
        return RestClient.builder().build();
    }

    private boolean isLocalHost(String host) {
        return host.equals("localhost")
                || host.equals("0.0.0.0")
                || host.equals("::1")
                || host.startsWith("127.");
    }

    private boolean isNgrokHost(String host) {
        return host.endsWith(".ngrok.io")
                || host.endsWith(".ngrok.app")
                || host.endsWith(".ngrok-free.app")
                || host.endsWith(".ngrok-free.dev");
    }
}
