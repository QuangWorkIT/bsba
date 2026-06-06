package com.be.bsba.serviceImpl;

import com.be.bsba.dto.response.RoutePointResponse;
import com.be.bsba.service.IDirectionsService;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class DirectionsServiceImpl implements IDirectionsService {
    private static final Duration REQUEST_TIMEOUT = Duration.ofSeconds(30);
    private static final Pattern POLYLINE_PATTERN =
            Pattern.compile("\"geometry\"\\s*:\\s*\"([^\"]+)\"");

    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();

    @Override
    public List<RoutePointResponse> getDrivingRoute(
            double originLat,
            double originLng,
            double destinationLat,
            double destinationLng
    ) {
        try {
            return fetchOsrmRoute(originLat, originLng, destinationLat, destinationLng);
        } catch (RuntimeException osrmError) {
            return fetchGoogleRoute(originLat, originLng, destinationLat, destinationLng);
        }
    }

    private List<RoutePointResponse> fetchOsrmRoute(
            double originLat,
            double originLng,
            double destinationLat,
            double destinationLng
    ) {
        String url = String.format(
                "https://router.project-osrm.org/route/v1/driving/%f,%f;%f,%f?overview=full&geometries=polyline",
                originLng,
                originLat,
                destinationLng,
                destinationLat
        );

        String body = sendGet(url);
        if (!body.contains("\"code\":\"Ok\"")) {
            throw new RuntimeException("OSRM did not return a valid route");
        }

        Matcher matcher = POLYLINE_PATTERN.matcher(body);
        if (!matcher.find()) {
            throw new RuntimeException("OSRM returned an empty polyline");
        }

        return decodePolyline(matcher.group(1));
    }

    private List<RoutePointResponse> fetchGoogleRoute(
            double originLat,
            double originLng,
            double destinationLat,
            double destinationLng
    ) {
        String apiKey = System.getenv("GOOGLE_MAPS_API_KEY");
        if (apiKey == null || apiKey.isBlank()) {
            throw new RuntimeException("Google Maps API key is not configured on the server");
        }

        String url = String.format(
                "https://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&mode=driving&key=%s",
                originLat,
                originLng,
                destinationLat,
                destinationLng,
                apiKey
        );

        String body = sendGet(url);
        if (!body.contains("\"status\" : \"OK\"") && !body.contains("\"status\":\"OK\"")) {
            throw new RuntimeException("Google Directions request was denied");
        }

        Matcher matcher = Pattern.compile("\"points\"\\s*:\\s*\"([^\"]+)\"").matcher(body);
        if (!matcher.find()) {
            throw new RuntimeException("Google Directions returned an empty polyline");
        }

        return decodePolyline(matcher.group(1));
    }

    private String sendGet(String url) {
        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .timeout(REQUEST_TIMEOUT)
                    .GET()
                    .build();

            HttpResponse<String> response = httpClient.send(
                    request,
                    HttpResponse.BodyHandlers.ofString()
            );

            if (response.statusCode() != 200) {
                throw new RuntimeException("Routing HTTP " + response.statusCode());
            }

            return response.body();
        } catch (RuntimeException exception) {
            throw exception;
        } catch (Exception exception) {
            throw new RuntimeException("Failed to fetch route", exception);
        }
    }

    private List<RoutePointResponse> decodePolyline(String encoded) {
        List<RoutePointResponse> points = new ArrayList<>();
        int index = 0;
        int lat = 0;
        int lng = 0;

        while (index < encoded.length()) {
            int shift = 0;
            int result = 0;
            int value;

            do {
                value = encoded.charAt(index++) - 63;
                result |= (value & 0x1f) << shift;
                shift += 5;
            } while (value >= 0x20);

            lat += ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));

            shift = 0;
            result = 0;

            do {
                value = encoded.charAt(index++) - 63;
                result |= (value & 0x1f) << shift;
                shift += 5;
            } while (value >= 0x20);

            lng += ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));

            points.add(RoutePointResponse.builder()
                    .latitude(lat / 1e5)
                    .longitude(lng / 1e5)
                    .build());
        }

        if (points.size() < 2) {
            throw new RuntimeException("Decoded route is empty");
        }

        return points;
    }
}
