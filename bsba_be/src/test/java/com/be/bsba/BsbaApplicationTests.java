package com.be.bsba;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest(properties = {
		"zalopay.app-id=2553",
		"zalopay.key1=test-key-1",
		"zalopay.key2=test-key-2",
		"zalopay.create-order-url=https://example.test/v2/create",
		"zalopay.query-order-url=https://example.test/v2/query",
		"zalopay.callback-url=http://localhost/api/v1/payments/zalopay/callback"
})
@ActiveProfiles("test")
class BsbaApplicationTests {

	@Test
	void contextLoads() {
	}
}
