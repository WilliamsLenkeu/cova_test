package com.cova.taskmanager.user;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.Collection;
import java.util.List;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

@Entity
@Table(name = "users")
public class User implements UserDetails {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	public Long id;

	@Column(nullable = false, unique = true, length = 191)
	public String email;

	@Column(nullable = false, length = 100)
	public String name;

	@Column(nullable = false)
	public String password;

	@Column(nullable = false, updatable = false)
	public Instant createdAt;

	@PrePersist
	void onCreate() {
		createdAt = Instant.now();
	}

	@Override
	public Collection<? extends GrantedAuthority> getAuthorities() {
		return List.of();
	}

	@Override
	public String getPassword() {
		return password;
	}

	@Override
	public String getUsername() {
		return email;
	}
}
