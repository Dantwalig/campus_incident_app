import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/models/incident.dart';
import '../../data/models/incident_filter.dart';

class IncidentFilterBar extends StatefulWidget {
  const IncidentFilterBar({
    super.key,
    required this.filter,
    required this.onChanged,
  });

  final IncidentFilter filter;
  final ValueChanged<IncidentFilter> onChanged;

  @override
  State<IncidentFilterBar> createState() => _IncidentFilterBarState();
}

class _IncidentFilterBarState extends State<IncidentFilterBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.text,
          fontSize: 13,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = widget.filter;
    return Column(
      children: [
        TextField(
          controller: _controller,
          onChanged: (v) => widget.onChanged(filter.copyWith(query: v)),
          decoration: InputDecoration(
            hintText: 'Search by title, description or place',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _controller.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _controller.clear();
                      widget.onChanged(filter.copyWith(query: ''));
                    },
                  ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _chip('All', filter.status == null,
                  () => widget.onChanged(filter.copyWith(clearStatus: true))),
              for (final s in IncidentStatus.values)
                _chip(s.label, filter.status == s,
                    () => widget.onChanged(filter.copyWith(status: s))),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _chip('Any category', filter.category == null,
                  () => widget.onChanged(filter.copyWith(clearCategory: true))),
              for (final c in IncidentCategory.values)
                _chip(c.label, filter.category == c,
                    () => widget.onChanged(filter.copyWith(category: c))),
            ],
          ),
        ),
      ],
    );
  }
}
