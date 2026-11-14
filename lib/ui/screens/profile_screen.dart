import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/ui_helpers.dart';
import '../../data/models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/summary_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final ok = await confirmDialog(
      context,
      title: 'Sign out',
      message: 'Do you want to sign out of your account?',
      confirmLabel: 'Sign out',
    );
    if (ok) await auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().profile!;
    final mine = context.watch<IncidentProvider>().mine(user.uid);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Profile',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primarySoft,
                  child: Text(
                    user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      Text(user.email,
                          style: const TextStyle(color: AppColors.textMuted)),
                      if (user.department != null)
                        Text(user.department!,
                            style: const TextStyle(color: AppColors.textMuted)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.isStaff ? 'Staff' : 'Student',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!user.isStaff) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SummaryTile(
                    icon: Icons.description_outlined,
                    count: mine.length,
                    label: 'Total Reports',
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
              ],
            ),
          ],
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.danger),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }
}
