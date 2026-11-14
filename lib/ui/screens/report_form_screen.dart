import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/ui_extensions.dart';
import '../../core/ui_helpers.dart';
import '../../core/validators.dart';
import '../../data/models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/primary_button.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _detail = TextEditingController();

  IncidentCategory? _category;
  String? _place;
  File? _photo;
  bool _anonymous = false;
  bool _categoryError = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _detail.dispose();
    super.dispose();
  }

  String get _location {
    final detail = _detail.text.trim();
    if (_place == 'Other') return detail;
    return detail.isEmpty ? _place! : '$_place, $detail';
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 80,
      );
      if (picked != null) setState(() => _photo = File(picked.path));
    } catch (_) {
      if (mounted) showSnack(context, 'Could not open the photo picker', error: true);
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final formOk = _formKey.currentState!.validate();
    setState(() => _categoryError = _category == null);
    if (!formOk || _category == null) return;

    final incidents = context.read<IncidentProvider>();
    final user = context.read<AuthProvider>().profile!;
    final location = _location;

    final duplicates = await incidents.findDuplicates(_category!, location);
    if (!mounted) return;
    if (duplicates.isNotEmpty) {
      final proceed = await confirmDialog(
        context,
        title: 'Similar report found',
        message: '"${duplicates.first.title}" was already reported for this '
            'category and location (${duplicates.first.status.label}). '
            'Do you still want to submit a new report?',
        confirmLabel: 'Submit anyway',
      );
      if (!proceed || !mounted) return;
    }

    final ok = await incidents.submit(
      user: user,
      title: _title.text,
      description: _description.text,
      category: _category!,
      location: location,
      photo: _photo,
      anonymous: _anonymous,
    );
    if (!mounted) return;
    if (ok) {
      showSnack(context, 'Report submitted. Thank you!');
      Navigator.pop(context);
    } else {
      showSnack(context, incidents.error ?? 'Submission failed', error: true);
    }
  }

  Widget _label(String text, {bool optional = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 16),
        child: Text.rich(
          TextSpan(
            text: text,
            style: const TextStyle(fontWeight: FontWeight.w600),
            children: [
              if (optional)
                const TextSpan(
                  text: ' (optional)',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final submitting = context.watch<IncidentProvider>().busy;

    return Scaffold(
      appBar: AppBar(title: const Text('Report an Incident')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              _label('Select a category'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in IncidentCategory.values)
                    CategoryChip(
                      category: c,
                      selected: _category == c,
                      onTap: () => setState(() {
                        _category = c;
                        _categoryError = false;
                      }),
                    ),
                ],
              ),
              if (_categoryError)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text('Please choose a category',
                      style: TextStyle(color: AppColors.danger, fontSize: 12)),
                ),
              _label('Title'),
              TextFormField(
                controller: _title,
                maxLength: 120,
                validator: (v) => Validators.minLength(v, 3, 'Title'),
                decoration: const InputDecoration(
                  hintText: 'Briefly describe the issue...',
                  counterText: '',
                ),
              ),
              _label('Description'),
              TextFormField(
                controller: _description,
                maxLines: 4,
                validator: (v) => Validators.minLength(v, 10, 'Description'),
                decoration: const InputDecoration(
                  hintText: 'Provide more details about the issue, e.g. what '
                      'happened, when, impact, etc.',
                ),
              ),
              _label('Location'),
              DropdownButtonFormField<String>(
                value: _place,
                items: [
                  for (final p in AppConstants.campusLocations)
                    DropdownMenuItem(value: p, child: Text(p)),
                ],
                validator: (v) => v == null ? 'Choose a location' : null,
                onChanged: (v) => setState(() => _place = v),
                decoration: const InputDecoration(
                  hintText: 'Select a location',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _detail,
                validator: (v) => _place == 'Other'
                    ? Validators.required(v, 'Location details')
                    : null,
                decoration: InputDecoration(
                  hintText: _place == 'Other'
                      ? 'Describe the location'
                      : 'Room or spot, e.g. Room 204 (optional)',
                ),
              ),
              _label('Add a photo', optional: true),
              _photo == null
                  ? InkWell(
                      onTap: _showPhotoOptions,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 96,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_outlined, color: AppColors.textMuted),
                            SizedBox(height: 6),
                            Text('Tap to add photos',
                                style: TextStyle(color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    )
                  : Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _photo!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => setState(() => _photo = null),
                            ),
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _anonymous,
                onChanged: (v) => setState(() => _anonymous = v),
                title: const Text('Report anonymously'),
                subtitle: const Text(
                  'Your name is hidden from staff and other students.',
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Submit Report',
                onPressed: _submit,
                loading: submitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
