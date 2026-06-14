package com.be.bsba.util;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class HmacUtilTests {

    @Test
    void verifiesHmacSha256WithoutTimingSensitiveStringComparison() {
        String data = "2553|260612_order|user|10000|1710000000000|{}|[]";
        String mac = HmacUtil.hmacSha256(data, "test-key");

        assertTrue(HmacUtil.verifyHmacSha256(data, "test-key", mac));
        assertTrue(HmacUtil.verifyHmacSha256(data, "test-key", mac.toUpperCase()));
        assertFalse(HmacUtil.verifyHmacSha256(data + "changed", "test-key", mac));
    }
}
