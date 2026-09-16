package com.cova.taskmanager.security;

import com.cova.taskmanager.user.UserRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import org.springframework.http.HttpHeaders;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
public class JwtAuthFilter extends OncePerRequestFilter {

	private final JwtService jwt;
	private final UserRepository users;

	public JwtAuthFilter(JwtService jwt, UserRepository users) {
		this.jwt = jwt;
		this.users = users;
	}

	@Override
	protected void doFilterInternal(HttpServletRequest req, HttpServletResponse res, FilterChain chain)
			throws ServletException, IOException {
		String header = req.getHeader(HttpHeaders.AUTHORIZATION);
		if (header != null && header.startsWith("Bearer ")) {
			String token = header.substring(7);
			if (jwt.valid(token) && SecurityContextHolder.getContext().getAuthentication() == null) {
				users.findByEmail(jwt.email(token)).ifPresent(user -> SecurityContextHolder.getContext()
						.setAuthentication(new UsernamePasswordAuthenticationToken(user, null, user.getAuthorities())));
			}
		}
		chain.doFilter(req, res);
	}
}
