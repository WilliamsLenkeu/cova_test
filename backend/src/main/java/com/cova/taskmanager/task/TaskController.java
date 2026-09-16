package com.cova.taskmanager.task;

import com.cova.taskmanager.user.User;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/tasks")
public class TaskController {

	private final TaskRepository tasks;

	public TaskController(TaskRepository tasks) {
		this.tasks = tasks;
	}

	@GetMapping
	List<TaskResponse> list(
			@AuthenticationPrincipal User user,
			@RequestParam(required = false) TaskStatus status,
			@RequestParam(required = false) String q) {
		String query = (q == null || q.isBlank()) ? null : q.trim();
		return tasks.search(user, status, query).stream().map(TaskResponse::from).toList();
	}

	@PostMapping
	TaskResponse create(@AuthenticationPrincipal User user, @Valid @RequestBody TaskRequest req) {
		Task task = new Task();
		task.owner = user;
		apply(task, req);
		return TaskResponse.from(tasks.save(task));
	}

	@PutMapping("/{id}")
	TaskResponse update(
			@AuthenticationPrincipal User user, @PathVariable Long id, @Valid @RequestBody TaskRequest req) {
		Task task = owned(user, id);
		apply(task, req);
		return TaskResponse.from(tasks.save(task));
	}

	@DeleteMapping("/{id}")
	void delete(@AuthenticationPrincipal User user, @PathVariable Long id) {
		tasks.delete(owned(user, id));
	}

	private Task owned(User user, Long id) {
		return tasks.findByIdAndOwner(id, user)
				.orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Task not found"));
	}

	private static void apply(Task task, TaskRequest req) {
		task.title = req.title().trim();
		task.description = req.description() == null ? null : req.description().trim();
		task.status = req.status();
	}

	public record TaskRequest(
			@NotBlank @Size(max = 200) String title,
			@Size(max = 2000) String description,
			@NotNull TaskStatus status) {}

	public record TaskResponse(
			Long id, String title, String description, TaskStatus status, Instant createdAt, Instant updatedAt) {
		static TaskResponse from(Task t) {
			return new TaskResponse(t.id, t.title, t.description, t.status, t.createdAt, t.updatedAt);
		}
	}
}
