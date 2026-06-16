package com.be.bsba.util;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertAll;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class HmacUtilTests {

    private static final String DATA = "2553|260612_order|user|10000|1710000000000|{}|[]";
    private static final String KEY = "test-key";

    @Test
    void hmacSha256ReturnsExpectedLowercaseHexDigest() {
        String digest = HmacUtil.hmacSha256("The quick brown fox jumps over the lazy dog", "key");

        assertEquals("f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8", digest);
    }

    @Test
    void verifyHmacSha256AcceptsMatchingMacCaseInsensitively() {
        String mac = HmacUtil.hmacSha256(DATA, KEY);

        assertAll(
                () -> assertTrue(HmacUtil.verifyHmacSha256(DATA, KEY, mac)),
                () -> assertTrue(HmacUtil.verifyHmacSha256(DATA, KEY, mac.toUpperCase()))
        );
    }

    @Test
    void verifyHmacSha256RejectsTamperedInputsAndMissingValues() {
        String mac = HmacUtil.hmacSha256(DATA, KEY);

        assertAll(
                () -> assertFalse(HmacUtil.verifyHmacSha256(DATA + "changed", KEY, mac)),
                () -> assertFalse(HmacUtil.verifyHmacSha256(DATA, KEY + "changed", mac)),
                () -> assertFalse(HmacUtil.verifyHmacSha256(null, KEY, mac)),
                () -> assertFalse(HmacUtil.verifyHmacSha256(DATA, null, mac)),
                () -> assertFalse(HmacUtil.verifyHmacSha256(DATA, KEY, null))
        );
    }
}
