import 'package:hive/hive.dart';

class Task extends HiveObject {
  Task({
    required this.title,
    required this.date,
    this.description = '',
    this.category = 'General',
    this.priority = 'Medium',
    this.timeMinutes,
    this.location = '',
    this.assignedTo = '',
    this.durationMinutes = 0,
    this.tags = '',
    this.reminder = false,
    this.isDone = false,
  });

  static const List<String> categories = [
    'General',
    'School',
    'Work',
    'Personal',
    'Health',
    'Shopping',
  ];

  static const List<String> priorities = ['Low', 'Medium', 'High'];

  String title;
  String description;
  String category;
  String priority;
  DateTime date;

  /// Time of day as minutes after midnight (null = no time set).
  int? timeMinutes;
  String location;
  String assignedTo;
  int durationMinutes;
  String tags;
  bool reminder;
  bool isDone;

  /// Copy without the Hive key (used for UNDO after delete).
  Task copy() => Task(
        title: title,
        date: date,
        description: description,
        category: category,
        priority: priority,
        timeMinutes: timeMinutes,
        location: location,
        assignedTo: assignedTo,
        durationMinutes: durationMinutes,
        tags: tags,
        reminder: reminder,
        isDone: isDone,
      );
}
