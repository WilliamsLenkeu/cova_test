import 'package:flutter/material.dart';

import '../theme.dart';

class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFCEBEA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0C4C0)),
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 14, height: 1.35, color: AppColors.danger),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg) = switch (status) {
      'DONE' => ('Terminé', const Color(0xFF1B6B57), const Color(0xFFE4F3EE)),
      'IN_PROGRESS' => ('En cours', const Color(0xFF8A5A00), const Color(0xFFF7EFDC)),
      _ => ('À faire', const Color(0xFF3D4450), const Color(0xFFEEF0F3)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          color: fg,
        ),
      ),
    );
  }
}

class BusyButton extends StatelessWidget {
  const BusyButton({
    super.key,
    required this.label,
    required this.busy,
    required this.onPressed,
  });

  final String label;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: busy ? null : onPressed,
      child: busy
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
            )
          : Text(label),
    );
  }
}

String? requiredField(String? v, String label) =>
    (v == null || v.trim().isEmpty) ? '$label requis' : null;

String? emailField(String? v) {
  final t = v?.trim() ?? '';
  if (t.isEmpty) return 'Email requis';
  if (!t.contains('@')) return 'Email invalide';
  return null;
}

String? passwordField(String? v, {int min = 1}) {
  if (v == null || v.isEmpty) return 'Mot de passe requis';
  if (v.length < min) return 'Au moins $min caractères';
  return null;
}
