import 'package:flutter/material.dart';

import '../api.dart';
import '../theme.dart';
import '../widgets/ui.dart';
import 'auth_page.dart';

const _statuses = ['TODO', 'IN_PROGRESS', 'DONE'];
const _statusLabel = {
  'TODO': 'À faire',
  'IN_PROGRESS': 'En cours',
  'DONE': 'Terminé',
};

class TasksPage extends StatefulWidget {
  const TasksPage({super.key, required this.api});

  final Api api;

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final search = TextEditingController();
  List<Map<String, dynamic>> tasks = [];
  String? statusFilter;
  String? error;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final raw = await widget.api.tasks(status: statusFilter, q: search.text);
      tasks = raw.cast<Map<String, dynamic>>();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _openSheet([Map<String, dynamic>? task]) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _TaskSheet(api: widget.api, task: task),
    );
    if (changed == true) await _load();
  }

  Future<void> _logout() async {
    await widget.api.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(fadeRoute(AuthPage(api: widget.api)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes tâches'),
        actions: [
          TextButton(
            onPressed: _logout,
            child: const Text('Quitter', style: TextStyle(color: AppColors.muted)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openSheet(),
        tooltip: 'Nouvelle tâche',
        child: const Icon(Icons.add, size: 28),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: search,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _load(),
              decoration: InputDecoration(
                hintText: 'Recherche',
                prefixIcon: const Icon(Icons.search, color: AppColors.muted),
                suffixIcon: search.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          search.clear();
                          _load();
                        },
                      ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Tous',
                  selected: statusFilter == null,
                  onTap: () {
                    setState(() => statusFilter = null);
                    _load();
                  },
                ),
                for (final s in _statuses) ...[
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: _statusLabel[s]!,
                    selected: statusFilter == s,
                    onTap: () {
                      setState(() => statusFilter = s);
                      _load();
                    },
                  ),
                ],
              ],
            ),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: ErrorBanner(message: error!),
            ),
          Expanded(
            child: loading
                ? const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: AppColors.accent,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    color: AppColors.accent,
                    onRefresh: _load,
                    child: tasks.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 96),
                              _EmptyState(),
                            ],
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                            itemCount: tasks.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) => _TaskTile(
                              task: tasks[i],
                              onTap: () => _openSheet(tasks[i]),
                              onDelete: () => _confirmDelete(tasks[i]),
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Map<String, dynamic> task) async {
    final id = task['id'];
    if (id is! int && id is! num) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: Text('${task['title']}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await widget.api.delete((id as num).toInt());
      await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.accent : AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? AppColors.accent : AppColors.line),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskSheet extends StatefulWidget {
  const _TaskSheet({required this.api, this.task});

  final Api api;
  final Map<String, dynamic>? task;

  @override
  State<_TaskSheet> createState() => _TaskSheetState();
}

class _TaskSheetState extends State<_TaskSheet> {
  late final title = TextEditingController(text: '${widget.task?['title'] ?? ''}');
  late final description =
      TextEditingController(text: '${widget.task?['description'] ?? ''}');
  late String status = '${widget.task?['status'] ?? 'TODO'}';
  final formKey = GlobalKey<FormState>();
  String? error;
  bool busy = false;

  bool get editing => widget.task != null;

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final t = title.text.trim();
      final d = description.text.trim();
      if (editing) {
        final id = (widget.task!['id'] as num).toInt();
        await widget.api.update(id, t, d, status);
      } else {
        await widget.api.create(t, d, status);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottom),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              editing ? 'Modifier' : 'Nouvelle tâche',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 16),
            if (error != null) ...[
              ErrorBanner(message: error!),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: title,
              textInputAction: TextInputAction.next,
              autofocus: !editing,
              decoration: const InputDecoration(
                labelText: 'Titre',
                hintText: 'Ce qu’il faut faire',
              ),
              validator: (v) => requiredField(v, 'Titre'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: description,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Optionnel',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: status,
              decoration: const InputDecoration(labelText: 'Statut'),
              items: [
                for (final s in _statuses)
                  DropdownMenuItem(value: s, child: Text(_statusLabel[s]!)),
              ],
              onChanged: busy
                  ? null
                  : (v) {
                      if (v != null) status = v;
                    },
            ),
            const SizedBox(height: 20),
            BusyButton(
              label: editing ? 'Enregistrer' : 'Ajouter',
              busy: busy,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.onTap,
    required this.onDelete,
  });

  final Map<String, dynamic> task;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final title = '${task['title'] ?? ''}';
    final desc = '${task['description'] ?? ''}'.trim();
    final status = '${task['status'] ?? 'TODO'}';

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                              height: 1.3,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusChip(status: status),
                      ],
                    ),
                    if (desc.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                tooltip: 'Supprimer',
                icon: const Icon(Icons.delete_outline, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 40, color: AppColors.muted),
          SizedBox(height: 14),
          Text(
            'Rien pour l’instant',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
              color: AppColors.ink,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Appuie sur + pour ajouter ta première tâche.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.45, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
