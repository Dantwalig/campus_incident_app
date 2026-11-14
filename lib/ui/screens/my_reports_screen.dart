import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/incident_filter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../widgets/error_banner.dart';
import '../widgets/incident_filter_bar.dart';
import '../widgets/incident_list.dart';

enum _Scope { mine, campus }

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  IncidentFilter _filter = const IncidentFilter();
  _Scope _scope = _Scope.mine;

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().profile!.uid;
    final provider = context.watch<IncidentProvider>();
    final source = _scope == _Scope.mine ? provider.mine(uid) : provider.all;
    final results = _filter.apply(source);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          const Text('Reports',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          SegmentedButton<_Scope>(
            segments: const [
              ButtonSegment(value: _Scope.mine, label: Text('My reports')),
              ButtonSegment(value: _Scope.campus, label: Text('Campus feed')),
            ],
            selected: {_scope},
            onSelectionChanged: (s) => setState(() => _scope = s.first),
          ),
          const SizedBox(height: 14),
          IncidentFilterBar(
            filter: _filter,
            onChanged: (f) => setState(() => _filter = f),
          ),
          const SizedBox(height: 12),
          if (provider.error != null) ErrorBanner(provider.error!),
          if (provider.loading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            IncidentList(
              incidents: results,
              showReporter: _scope == _Scope.campus,
              emptyMessage: _scope == _Scope.mine
                  ? 'No reports match your filters'
                  : 'No campus reports match your filters',
            ),
        ],
      ),
    );
  }
}
