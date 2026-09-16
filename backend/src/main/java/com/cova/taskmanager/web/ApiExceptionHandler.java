package com.cova.taskmanager.web;

import java.util.Map;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.server.ResponseStatusException;

@RestControllerAdvice
public class ApiExceptionHandler {

	@ExceptionHandler(MethodArgumentNotValidException.class)
	ResponseEntity<Map<String, String>> validation(MethodArgumentNotValidException ex) {
		var err = ex.getBindingResult().getFieldError();
		return ResponseEntity.badRequest().body(Map.of("message", err == null ? "Validation failed" : err.getDefaultMessage()));
	}

	@ExceptionHandler(ResponseStatusException.class)
	ResponseEntity<Map<String, String>> status(ResponseStatusException ex) {
		return ResponseEntity.status(ex.getStatusCode())
				.body(Map.of("message", ex.getReason() == null ? "Error" : ex.getReason()));
	}
}
