package com.cova.taskmanager.security;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;

class JwtServiceTest {

	@Test
	void roundTrip() {
		var jwt = new JwtService("cova-taskmanager-dev-secret-change-me-32chars-min", 60_000);
		String token = jwt.generate("a@test.com");
		assertTrue(jwt.valid(token));
		assertEquals("a@test.com", jwt.email(token));
		assertFalse(jwt.valid("bad"));
	}
}
