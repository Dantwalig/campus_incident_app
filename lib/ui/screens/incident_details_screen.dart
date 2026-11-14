import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../core/ui_extensions.dart';
import '../../core/ui_helpers.dart';
import '../../core/validators.dart';
import '../../data/models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/status_badge.dart';
import '../widgets/status_timeline.dart';

class IncidentDetailsScreen extends StatelessWidget {
  const IncidentDetailsScreen({super.key, required this.incidentId});

  final String incidentId;

  static void open(BuildContext context, String id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => IncidentDetailsScreen(incidentId: id)),
    );
  }

  Future<void> _edit(BuildContext context, Incident incident) async {
    final titleController = TextEditingController(text: incident.title);
    final descController = TextEditingController(text: incident.description);
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit report'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                validator: (v) => Validators.minLength(v, 3, 'Title'),
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descController,
                maxLines: 4,
                validator: (v) => Validators.minLength(v, 10, 'Description'),
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved != true || !context.mounted) return;

    final provider = context.read<IncidentProvider>();
    final ok = await provider.editIncident(
      incident.id,
      titleController.text,
      descController.text,
    );
    if (!context.mounted) return;
    showSnack(
      context,
      ok ? 'Report updated' : (provider.error ?? 'Update failed'),
      error: !ok,
    );
  }

  Future<void> _delete(BuildContext context, Incident incident) async {
    final provider = context.read<IncidentProvider>();
    final confirmed = await confirmDialog(
      context,
      title: 'Delete report',
      message: 'This permanently removes your report. Continue?',
      confirmLabel: 'Delete',
    );
    if (!confirmed || !context.mounted) return;
    final ok = await provider.deleteIncident(incident);
    if (!context.mounted) return;
    if (ok) {
      Navigator.pop(context);
      showSnack(context, 'Report deleted');
    } else {
      showSnack(context, provider.error ?? 'Delete failed', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final incident = context.watch<IncidentProvider>().byId(incidentId);
    final auth = context.watch<AuthProvider>();
    final profile = auth.profile!;

    if (incident == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Incident Details')),
        body: const Center(child: Text('This report no longer exists.')),
      );
    }

    final isOwner = incident.reporterId == profile.uid;
    final canModify = isOwner && incident.status == IncidentStatus.submitted;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Details'),
        actions: [
          if (canModify)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') _edit(context, incident);
                if (value == 'delete') _delete(context, incident);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            if (incident.photoUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  incident.photoUrl!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : const SizedBox(
                          height: 220,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                  errorBuilder: (context, error, stack) => Container(
                    height: 120,
                    color: AppColors.primarySoft,
                    child: const Center(child: Icon(Icons.broken_image_outlined)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    incident.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(incident.status),
              ],
            ),
            const SizedBox(height: 10),
            _MetaRow(Icons.category_outlined, incident.category.label),
            _MetaRow(Icons.location_on_outlined, incident.location),
            _MetaRow(Icons.calendar_today_outlined,
                'Submitted ${formatDateTime(incident.createdAt)}'),
            _MetaRow(Icons.person_outline, 'Reported by ${incident.reporterName}'),
            const SizedBox(height: 18),
            const Text('Status Timeline',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            AppCard(child: StatusTimeline(incident: incident)),
            const SizedBox(height: 18),
            const Text('Description',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(incident.description, style: const TextStyle(height: 1.4)),
            if (incident.staffNote != null && incident.staffNote!.isNotEmpty) ...[
              const SizedBox(height: 18),
              const Text('Staff note',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              AppCard(child: Text(incident.staffNote!)),
            ],
            const SizedBox(height: 18),
            const Text('Activity',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            for (final change in incident.history.reversed)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(Icons.circle, size: 10, color: change.status.color),
                title: Text('${change.status.label} by ${change.changedBy}'),
                subtitle: Text(
                  change.note == null || change.note!.isEmpty
                      ? formatDateTime(change.timestamp)
                      : '${formatDateTime(change.timestamp)}\n${change.note}',
                ),
              ),
            if (profile.isStaff) ...[
              const SizedBox(height: 18),
              _StaffPanel(incident: incident),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(color: AppColors.textMuted)),
          ),
        ],
      ),
    );
  }
}

/// Only built for staff. The same rule is enforced in firestore.rules.
class _StaffPanel extends StatefulWidget {
  const _StaffPanel({required this.incident});

  final Incident incident;

  @override
  State<_StaffPanel> createState() => _StaffPanelState();
}

class _StaffPanelState extends State<_StaffPanel> {
  late IncidentStatus _status = widget.incident.status;
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    final provider = context.read<IncidentProvider>();
    final staff = context.read<AuthProvider>().profile!;
    final unchanged =
        _status == widget.incident.status && _note.text.trim().isEmpty;
    if (unchanged) {
      showSnack(context, 'Pick a new status or add a note', error: true);
      return;
    }
    final ok = await provider.updateStatus(
      widget.incident.id,
      _status,
      staff.name,
      _note.text,
    );
    if (!mounted) return;
    if (ok) _note.clear();
    showSnack(
      context,
      ok ? 'Status updated' : (provider.error ?? 'Update failed'),
      error: !ok,
    );
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<IncidentProvider>().busy;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Update status (staff)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          DropdownButtonFormField<IncidentStatus>(
            value: _status,
            items: [
              for (final s in IncidentStatus.values)
                DropdownMenuItem(value: s, child: Text(s.label)),
            ],
            onChanged: (v) => setState(() => _status = v ?? _status),
            decoration: const InputDecoration(labelText: 'New status'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Note for the student (optional)',
            ),
          ),
          const SizedBox(height: 14),
          PrimaryButton(label: 'Update status', onPressed: _update, loading: busy),
        ],
      ),
    );
  }
}
