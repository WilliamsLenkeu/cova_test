package com.cova.taskmanager.task;

import com.cova.taskmanager.user.User;
import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "tasks")
public class Task {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	public Long id;

	@Column(nullable = false, length = 200)
	public String title;

	@Column(length = 2000)
	public String description;

	@Enumerated(EnumType.STRING)
	@Column(nullable = false, length = 32)
	public TaskStatus status = TaskStatus.TODO;

	@Column(nullable = false, updatable = false)
	public Instant createdAt;

	@Column(nullable = false)
	public Instant updatedAt;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "owner_id", nullable = false)
	public User owner;

	@PrePersist
	void onCreate() {
		createdAt = updatedAt = Instant.now();
	}

	@PreUpdate
	void onUpdate() {
		updatedAt = Instant.now();
	}
}
