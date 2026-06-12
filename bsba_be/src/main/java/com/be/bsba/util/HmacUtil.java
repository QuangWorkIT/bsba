package com.be.bsba.util;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.Locale;

public final class HmacUtil {
    private static final String HMAC_SHA256 = "HmacSHA256";

    private HmacUtil() {
    }

    public static String hmacSha256(String data, String key) {
        try {
            Mac mac = Mac.getInstance(HMAC_SHA256);
            SecretKeySpec secretKeySpec = new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), HMAC_SHA256);
            mac.init(secretKeySpec);
            byte[] rawHmac = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            return bytesToHex(rawHmac);
        } catch (Exception e) {
            throw new IllegalStateException("Failed to generate HMAC SHA256", e);
        }
    }

    public static boolean verifyHmacSha256(String data, String key, String expectedMac) {
        if (data == null || key == null || expectedMac == null) {
            return false;
        }
        String actualMac = hmacSha256(data, key);
        return MessageDigest.isEqual(
                actualMac.getBytes(StandardCharsets.US_ASCII),
                expectedMac.toLowerCase(Locale.ROOT).getBytes(StandardCharsets.US_ASCII)
        );
    }

    private static String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder(bytes.length * 2);
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }
}
