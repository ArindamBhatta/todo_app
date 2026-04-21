import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/data/todo.dart';
import 'package:todo/data/todo_database.dart';

class TodoRepository {
  static const String _webTasksKey = 'todo_tasks_cache';

  Future<List<ElementTask>> fetchTasks() async {
    if (kIsWeb) {
      final tasks = await _loadWebTasks();
      tasks.sort((a, b) => a.absoluteDeadline.compareTo(b.absoluteDeadline));
      return tasks;
    }

    final db = await TodoDatabase.instance.database;
    final rows = await db.query('tasks', orderBy: 'absolute_deadline ASC');
    return rows.map(ElementTask.fromMap).toList();
  }

  Future<void> insertTask(ElementTask task) async {
    if (kIsWeb) {
      final tasks = await _loadWebTasks();
      tasks.removeWhere((existingTask) => existingTask.id == task.id);
      tasks.add(task);
      await _saveWebTasks(tasks);
      return;
    }

    final db = await TodoDatabase.instance.database;
    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTask(ElementTask task) async {
    if (kIsWeb) {
      final tasks = await _loadWebTasks();
      final taskIndex = tasks.indexWhere(
        (existingTask) => existingTask.id == task.id,
      );
      if (taskIndex == -1) {
        tasks.add(task);
      } else {
        tasks[taskIndex] = task;
      }
      await _saveWebTasks(tasks);
      return;
    }

    final db = await TodoDatabase.instance.database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(String id) async {
    if (kIsWeb) {
      final tasks = await _loadWebTasks();
      tasks.removeWhere((task) => task.id == id);
      await _saveWebTasks(tasks);
      return;
    }

    final db = await TodoDatabase.instance.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ElementTask>> _loadWebTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_webTasksKey);
    if (raw == null || raw.isEmpty) {
      return <ElementTask>[];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map(
          (item) => ElementTask.fromMap(Map<String, Object?>.from(item as Map)),
        )
        .toList();
  }

  Future<void> _saveWebTasks(List<ElementTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(tasks.map((task) => task.toMap()).toList());
    await prefs.setString(_webTasksKey, encoded);
  }
}
