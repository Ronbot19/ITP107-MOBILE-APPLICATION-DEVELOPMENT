import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../services/task_repository.dart';


class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, this.task});

  final Task? task;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _location;
  late final TextEditingController _assignedTo;
  late final TextEditingController _duration;
  late final TextEditingController _tags;

  late String _category;
  late String _priority;
  late DateTime _date;
  TimeOfDay? _time;
  late bool _reminder;
  late bool _isDone;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _title = TextEditingController(text: t?.title ?? '');
    _description = TextEditingController(text: t?.description ?? '');
    _location = TextEditingController(text: t?.location ?? '');
    _assignedTo = TextEditingController(text: t?.assignedTo ?? '');
    _duration = TextEditingController(
        text: (t != null && t.durationMinutes > 0) ? '${t.durationMinutes}' : '');
    _tags = TextEditingController(text: t?.tags ?? '');
    _category = t?.category ?? Task.categories.first;
    _priority = t?.priority ?? 'Medium';
    _date = t?.date ?? DateTime.now();
    final m = t?.timeMinutes;
    _time = m == null ? null : TimeOfDay(hour: m ~/ 60, minute: m % 60);
    _reminder = t?.reminder ?? false;
    _isDone = t?.isDone ?? false;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    _assignedTo.dispose();
    _duration.dispose();
    _tags.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _title.text.trim();
    final description = _description.text.trim();
    final location = _location.text.trim();
    final assignedTo = _assignedTo.text.trim();
    final duration = int.tryParse(_duration.text.trim()) ?? 0;
    final tags = _tags.text.trim();
    final timeMinutes = _time == null ? null : _time!.hour * 60 + _time!.minute;

    if (_isEditing) {
      final task = widget.task!;
      task
        ..title = title
        ..description = description
        ..category = _category
        ..priority = _priority
        ..date = _date
        ..timeMinutes = timeMinutes
        ..location = location
        ..assignedTo = assignedTo
        ..durationMinutes = duration
        ..tags = tags
        ..reminder = _reminder
        ..isDone = _isDone;
      await TaskRepository.update(task);
    } else {
      await TaskRepository.add(Task(
        title: title,
        description: description,
        category: _category,
        priority: _priority,
        date: _date,
        timeMinutes: timeMinutes,
        location: location,
        assignedTo: assignedTo,
        durationMinutes: duration,
        tags: tags,
        reminder: _reminder,
        isDone: _isDone,
      ));
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Task' : 'New Task')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const _SectionLabel('Task details'),
              // 1. Title
              TextFormField(
                controller: _title,
                autofocus: !_isEditing,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                maxLength: 80,
                decoration: const InputDecoration(
                  labelText: 'Task title *',
                  prefixIcon: Icon(Icons.edit_note),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Task title cannot be empty'
                    : null,
              ),
              const SizedBox(height: 4),
              // 2. Description
              TextFormField(
                controller: _description,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 8),

              // 3. Category
              const _SectionLabel('Category'),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final c in Task.categories)
                    ChoiceChip(
                      label: Text(c),
                      selected: _category == c,
                      onSelected: (_) => setState(() => _category = c),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // 4. Priority
              const _SectionLabel('Priority'),
              SegmentedButton<String>(
                segments: [
                  for (final p in Task.priorities)
                    ButtonSegment<String>(value: p, label: Text(p)),
                ],
                selected: {_priority},
                onSelectionChanged: (s) => setState(() => _priority = s.first),
              ),
              const SizedBox(height: 16),

              const _SectionLabel('When'),
              // 5. Date
              _PickerField(
                label: 'Date',
                icon: Icons.calendar_month,
                value: DateFormat('EEEE, MMMM d, y').format(_date),
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),
              // 6. Time
              _PickerField(
                label: 'Time (optional)',
                icon: Icons.schedule,
                value: _time?.format(context) ?? 'Not set',
                onTap: _pickTime,
                onClear: _time == null ? null : () => setState(() => _time = null),
              ),
              const SizedBox(height: 16),

              const _SectionLabel('More info'),
              // 7. Location
              TextFormField(
                controller: _location,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
              ),
              const SizedBox(height: 12),
              // 8. Assigned to
              TextFormField(
                controller: _assignedTo,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Assigned to',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              // 9. Duration
              TextFormField(
                controller: _duration,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Estimated duration (minutes)',
                  prefixIcon: Icon(Icons.timer_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final n = int.tryParse(v.trim());
                  if (n == null || n < 1 || n > 1440) {
                    return 'Enter 1 to 1440 minutes';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // 10. Tags
              TextFormField(
                controller: _tags,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                  hintText: 'exam, urgent, group',
                  prefixIcon: Icon(Icons.sell_outlined),
                ),
              ),
              const SizedBox(height: 8),

              // 11. Reminder
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: Icon(Icons.notifications_active_outlined,
                    color: scheme.primary),
                title: const Text('Remind me'),
                value: _reminder,
                onChanged: (v) => setState(() => _reminder = v),
              ),
              // 12. Completed
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: Icon(Icons.task_alt, color: scheme.primary),
                title: const Text('Mark as completed'),
                value: _isDone,
                onChanged: (v) => setState(() => _isDone = v),
              ),
              const SizedBox(height: 16),

              FilledButton.icon(
                onPressed: _save,
                icon: Icon(_isEditing ? Icons.save : Icons.add_task),
                label: Text(_isEditing ? 'Save Changes' : 'Add Task'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final IconData icon;
  final String value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(value)),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close, size: 18, color: scheme.outline),
              )
            else
              Icon(Icons.arrow_drop_down, color: scheme.outline),
          ],
        ),
      ),
    );
  }
}
