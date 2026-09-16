package com.cova.taskmanager.auth;

import com.cova.taskmanager.security.JwtService;
import com.cova.taskmanager.user.User;
import com.cova.taskmanager.user.UserRepository;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

	private final UserRepository users;
	private final PasswordEncoder encoder;
	private final JwtService jwt;

	public AuthController(UserRepository users, PasswordEncoder encoder, JwtService jwt) {
		this.users = users;
		this.encoder = encoder;
		this.jwt = jwt;
	}

	@PostMapping("/register")
	AuthResponse register(@Valid @RequestBody RegisterRequest req) {
		String email = req.email().trim().toLowerCase();
		if (users.existsByEmail(email)) {
			throw new ResponseStatusException(HttpStatus.CONFLICT, "Email already registered");
		}
		User user = new User();
		user.email = email;
		user.name = req.name().trim();
		user.password = encoder.encode(req.password());
		users.save(user);
		return new AuthResponse(jwt.generate(email), email, user.name);
	}

	@PostMapping("/login")
	AuthResponse login(@Valid @RequestBody LoginRequest req) {
		String email = req.email().trim().toLowerCase();
		User user = users.findByEmail(email)
				.orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid email or password"));
		if (!encoder.matches(req.password(), user.password)) {
			throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid email or password");
		}
		return new AuthResponse(jwt.generate(email), email, user.name);
	}

	public record RegisterRequest(
			@NotBlank @Size(max = 100) String name,
			@NotBlank @Email String email,
			@NotBlank @Size(min = 6, max = 100) String password) {}

	public record LoginRequest(@NotBlank @Email String email, @NotBlank String password) {}

	public record AuthResponse(String token, String email, String name) {}
}
