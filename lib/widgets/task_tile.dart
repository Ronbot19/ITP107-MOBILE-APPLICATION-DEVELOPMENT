import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';

/// One row in the to-do list: checkbox, title, date/time, and detail chips.
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
  });

  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  String _dateTimeText(BuildContext context) {
    var text = DateFormat('EEE, MMM d, y').format(task.date);
    final m = task.timeMinutes;
    if (m != null) {
      final t = TimeOfDay(hour: m ~/ 60, minute: m % 60);
      text += ' • ${t.format(context)}';
    }
    return text;
  }

  (Color, Color) _priorityColors(ColorScheme s) {
    switch (task.priority) {
      case 'High':
        return (s.errorContainer, s.onErrorContainer);
      case 'Low':
        return (s.primaryContainer, s.onPrimaryContainer);
      default:
        return (s.tertiaryContainer, s.onTertiaryContainer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final today = DateUtils.dateOnly(DateTime.now());
    final overdue =
        !task.isDone && DateUtils.dateOnly(task.date).isBefore(today);
    final (prioBg, prioFg) = _priorityColors(scheme);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 14, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: task.isDone,
                onChanged: (_) => onToggle(),
                shape: const CircleBorder(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration:
                              task.isDone ? TextDecoration.lineThrough : null,
                          color:
                              task.isDone ? scheme.outline : scheme.onSurface,
                        ),
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: scheme.outline),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.event,
                            size: 16,
                            color: overdue ? scheme.error : scheme.primary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _dateTimeText(context),
                            style: TextStyle(
                                color:
                                    overdue ? scheme.error : scheme.outline),
                          ),
                        ),
                        if (overdue) ...[
                          const SizedBox(width: 8),
                          Text('Overdue',
                              style: TextStyle(
                                  color: scheme.error,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _Chip(
                            label: '${task.priority} priority',
                            bg: prioBg,
                            fg: prioFg),
                        _Chip(
                            label: task.category,
                            bg: scheme.secondaryContainer,
                            fg: scheme.onSecondaryContainer),
                        if (task.location.isNotEmpty)
                          _Chip(
                              icon: Icons.place_outlined,
                              label: task.location,
                              bg: scheme.surfaceContainerHighest,
                              fg: scheme.onSurfaceVariant),
                        if (task.assignedTo.isNotEmpty)
                          _Chip(
                              icon: Icons.person_outline,
                              label: task.assignedTo,
                              bg: scheme.surfaceContainerHighest,
                              fg: scheme.onSurfaceVariant),
                        if (task.durationMinutes > 0)
                          _Chip(
                              icon: Icons.timer_outlined,
                              label: '${task.durationMinutes} min',
                              bg: scheme.surfaceContainerHighest,
                              fg: scheme.onSurfaceVariant),
                        if (task.reminder)
                          _Chip(
                              icon: Icons.notifications_active_outlined,
                              label: 'Reminder',
                              bg: scheme.surfaceContainerHighest,
                              fg: scheme.onSurfaceVariant),
                      ],
                    ),
                    if (task.tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        task.tags
                            .split(',')
                            .map((t) => t.trim())
                            .where((t) => t.isNotEmpty)
                            .map((t) => '#$t')
                            .join('  '),
                        style: TextStyle(
                            color: scheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.bg, required this.fg, this.icon});

  final String label;
  final Color bg;
  final Color fg;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
          ],
          Text(label,
              style: TextStyle(
                  color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
