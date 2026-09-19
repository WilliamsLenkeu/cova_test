import 'package:flutter/material.dart';

import '../api.dart';
import '../theme.dart';
import '../widgets/ui.dart';
import 'tasks_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, this.api});

  final Api? api;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late final Api api = widget.api ?? Api();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool register = false;
  String? error;
  bool busy = false;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      register = !register;
      error = null;
      formKey.currentState?.reset();
    });
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (register) {
        await api.register(name.text.trim(), email.text.trim(), password.text);
      } else {
        await api.login(email.text.trim(), password.text);
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(fadeRoute(TasksPage(api: api)));
    } catch (e) {
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 32, 24, 24 + bottom),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Tâches',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.4,
                        height: 1.05,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        register
                            ? 'Crée ton compte pour commencer.'
                            : 'Connecte-toi pour voir ta liste.',
                        key: ValueKey(register),
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.45,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    if (error != null) ...[
                      ErrorBanner(message: error!),
                      const SizedBox(height: 16),
                    ],
                    AnimatedSize(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      alignment: Alignment.topCenter,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (register) ...[
                            TextFormField(
                              controller: name,
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.words,
                              autofillHints: const [AutofillHints.name],
                              decoration: const InputDecoration(
                                labelText: 'Nom',
                              ),
                              validator: (v) =>
                                  register ? requiredField(v, 'Nom') : null,
                            ),
                            const SizedBox(height: 12),
                          ],
                          TextFormField(
                            controller: email,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              hintText: 'toi@exemple.com',
                            ),
                            validator: emailField,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: password,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            autofillHints: register
                                ? const [AutofillHints.newPassword]
                                : const [AutofillHints.password],
                            onFieldSubmitted: (_) => busy ? null : _submit(),
                            decoration: InputDecoration(
                              labelText: 'Mot de passe',
                              hintText: register ? '6 caractères min.' : null,
                            ),
                            validator: (v) =>
                                passwordField(v, min: register ? 6 : 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    BusyButton(
                      label: register ? 'S’inscrire' : 'Se connecter',
                      busy: busy,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: busy ? null : _toggleMode,
                      child: Text(
                        register
                            ? 'Déjà un compte ? Se connecter'
                            : 'Créer un compte',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
