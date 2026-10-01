import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/task.dart';
import '../models/task_adapter.dart';

/// All Hive access lives here so the UI never touches the box directly.
class TaskRepository {
  TaskRepository._();

  static const String boxName = 'taskBox';

  /// Call once from `main()` before `runApp()`.
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskAdapter());
    await Hive.openBox<Task>(boxName);
  }

  static Box<Task> get box => Hive.box<Task>(boxName);

  /// Used by ValueListenableBuilder to rebuild the UI on any change.
  static ValueListenable<Box<Task>> get listenable => box.listenable();

  // READ: unfinished tasks first, then by date (earliest first).
  static List<Task> getAll() {
    final tasks = box.values.toList();
    tasks.sort((a, b) {
      if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
      return a.date.compareTo(b.date);
    });
    return tasks;
  }

  // CREATE
  static Future<void> add(Task task) => box.add(task);

  // UPDATE
  static Future<void> update(Task task) => task.save();

  // DELETE
  static Future<void> delete(Task task) => task.delete();

  static Future<void> toggleDone(Task task) {
    task.isDone = !task.isDone;
    return task.save();
  }
}
