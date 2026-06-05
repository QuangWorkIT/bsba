package com.be.bsba.util;

import lombok.extern.slf4j.Slf4j;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;

@Slf4j

public class MomoSignatureUtil {

    private static final String HMAC_SHA256 = "HmacSHA256";

    public static String createRequestSignature(
            String accessKey, String amount, String extraData,
            String ipnUrl, String orderId, String orderInfo,
            String partnerCode, String redirectUrl,
            String requestId, String requestType,
            String secretKey) {

        String rawHash = "accessKey=" + accessKey
                + "&amount=" + amount
                + "&extraData=" + extraData
                + "&ipnUrl=" + ipnUrl
                + "&orderId=" + orderId
                + "&orderInfo=" + orderInfo
                + "&partnerCode=" + partnerCode
                + "&redirectUrl=" + redirectUrl
                + "&requestId=" + requestId
                + "&requestType=" + requestType;

        log.info("[MoMo] Raw signature string: {}", rawHash);

        return hmacSha256(rawHash, secretKey);
    }

    public static boolean verifyIpnSignature(
            String accessKey, String amount, String extraData,
            String message, String orderId, String orderInfo,
            String orderType, String partnerCode, String payType,
            String requestId, String responseTime, String resultCode,
            String transId, String secretKey, String receivedSignature) {

        String rawHash = "accessKey=" + accessKey
                + "&amount=" + amount
                + "&extraData=" + extraData
                + "&message=" + message
                + "&orderId=" + orderId
                + "&orderInfo=" + orderInfo
                + "&orderType=" + orderType
                + "&partnerCode=" + partnerCode
                + "&payType=" + payType
                + "&requestId=" + requestId
                + "&responseTime=" + responseTime
                + "&resultCode=" + resultCode
                + "&transId=" + transId;

        String calculated = hmacSha256(rawHash, secretKey);
        return calculated.equals(receivedSignature);
    }

    private static String hmacSha256(String data, String key) {
        try {
            Mac mac = Mac.getInstance(HMAC_SHA256);
            SecretKeySpec secretKeySpec = new SecretKeySpec(
                    key.getBytes(StandardCharsets.UTF_8), HMAC_SHA256);
            mac.init(secretKeySpec);
            byte[] rawHmac = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            return bytesToHex(rawHmac);
        } catch (Exception e) {
            throw new RuntimeException("Failed to generate HMAC SHA256", e);
        }
    }

    private static String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }
}
