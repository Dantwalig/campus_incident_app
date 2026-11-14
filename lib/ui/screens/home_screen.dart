import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../data/models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../widgets/error_banner.dart';
import '../widgets/incident_list.dart';
import '../widgets/summary_tile.dart';
import 'report_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onSeeAll});

  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().profile!;
    final provider = context.watch<IncidentProvider>();
    final mine = provider.mine(user.uid);
    final firstName = user.name.split(' ').first;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $firstName \u{1F44B}',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Help make our campus safer.',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Text(
                      'Report issues and track their resolution.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primarySoft,
                child: Text(
                  firstName.isEmpty ? '?' : firstName[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _ReportBanner(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Report Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              TextButton(onPressed: onSeeAll, child: const Text('See all')),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: SummaryTile(
                  icon: Icons.description_outlined,
                  count: mine.length,
                  label: 'My Reports',
                  color: AppColors.primary,
                  background: AppColors.primarySoft,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SummaryTile(
                  icon: Icons.schedule,
                  count: mine.countByStatus(IncidentStatus.inProgress),
                  label: 'In Progress',
                  color: AppColors.info,
                  background: AppColors.infoSoft,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SummaryTile(
                  icon: Icons.check_circle_outline,
                  count: mine.countByStatus(IncidentStatus.resolved),
                  label: 'Resolved',
                  color: AppColors.success,
                  background: AppColors.successSoft,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SummaryTile(
                  icon: Icons.error_outline,
                  count: mine.countByStatus(IncidentStatus.submitted),
                  label: 'Submitted',
                  color: AppColors.danger,
                  background: AppColors.dangerSoft,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Reports',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              TextButton(onPressed: onSeeAll, child: const Text('See all')),
            ],
          ),
          if (provider.error != null) ErrorBanner(provider.error!),
          if (provider.loading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            IncidentList(
              incidents: mine.take(3).toList(),
              emptyMessage: 'You have not reported anything yet',
            ),
        ],
      ),
    );
  }
}

class _ReportBanner extends StatelessWidget {
  const _ReportBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'See an issue\non campus?',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Report it and help improve our learning environment.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 14),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportFormScreen()),
              ),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Report an Issue',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
