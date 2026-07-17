import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:todo/data/todo.dart';
import 'package:todo/data/todo_repository.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

part 'task_state.dart';

class TaskManager extends Cubit<TaskState> {
  final TodoRepository _repository;

  TaskManager(this._repository) : super(TaskLoading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final tasks = await _repository.fetchTasks();
      if (tasks.isEmpty) {
        final defaultTasks = [
          ElementTask(
            name: 'Grocery shopping app design',
            category: 'Office',
            urgencyLevel: 'Urgent Important',
            isPending: true,
            color: const Color(0xFF4F46E5),
            startTime: DateTime.now().subtract(const Duration(hours: 2)),
            absoluteDeadline: DateTime.now().add(const Duration(days: 1)),
            desireDeadline: DateTime.now().add(const Duration(hours: 4)),
          ),
          ElementTask(
            name: 'Uber Eats redesign challenge',
            category: 'Personal',
            urgencyLevel: 'Not Urgent Important',
            isPending: true,
            color: const Color(0xFF10B981),
            startTime: DateTime.now().subtract(const Duration(hours: 1)),
            absoluteDeadline: DateTime.now().add(const Duration(days: 2)),
            desireDeadline: DateTime.now().add(const Duration(hours: 12)),
          ),
          ElementTask(
            name: 'Revise flutter unit testing',
            category: 'Self',
            urgencyLevel: 'Not Urgent Important',
            isPending: true,
            color: const Color(0xFFF59E0B),
            startTime: DateTime.now(),
            absoluteDeadline: DateTime.now().add(const Duration(days: 3)),
            desireDeadline: DateTime.now().add(const Duration(days: 1)),
          ),
          ElementTask(
            name: 'Team standup meeting',
            category: 'Office',
            urgencyLevel: 'Urgent Important',
            isPending: false,
            color: const Color(0xFF4F46E5),
            startTime: DateTime.now().subtract(const Duration(hours: 4)),
            absoluteDeadline: DateTime.now().add(const Duration(hours: 2)),
            desireDeadline: DateTime.now().subtract(const Duration(hours: 3)),
          ),
          ElementTask(
            name: 'Morning jog 5km',
            category: 'Health',
            urgencyLevel: 'Not Important Urgent',
            isPending: false,
            color: const Color(0xFF10B981),
            startTime: DateTime.now().subtract(const Duration(hours: 6)),
            absoluteDeadline: DateTime.now().add(const Duration(hours: 4)),
            desireDeadline: DateTime.now().subtract(const Duration(hours: 5)),
          ),
        ];
        for (final t in defaultTasks) {
          await _repository.insertTask(t);
        }
      }
      emit(TaskLoaded(await _repository.fetchTasks()));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _refresh() async {
    emit(TaskLoaded(await _repository.fetchTasks()));
  }

  Future<void> addTask(ElementTask task) async {
    await _repository.insertTask(task);
    if (task.urgencyLevel == 'Urgent Important') {
      try {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
            channelKey: 'urgent_important_channel',
            title: '🚨 Urgent & Important Work!',
            body: 'Task: "${task.name}" needs your immediate attention!',
            notificationLayout: NotificationLayout.Default,
            payload: {'taskId': task.id},
          ),
        );
      } catch (e) {
        debugPrint('Failed to send notification: $e');
      }
    }
    await _refresh();
  }

  Future<void> updateTask(ElementTask task) async {
    await _repository.updateTask(task);
    await _refresh();
  }

  Future<void> deleteTask(String id) async {
    await _repository.deleteTask(id);
    await _refresh();
  }

  Future<void> toggleTaskStatus(String id) async {
    final currentState = state;
    final tasks = currentState is TaskLoaded
        ? currentState.tasks
        : await _repository.fetchTasks();

    final taskIndex = tasks.indexWhere((t) => t.id == id);
    if (taskIndex == -1) return;

    final toggled = tasks[taskIndex].copyWith(
      isPending: !tasks[taskIndex].isPending,
    );
    await _repository.updateTask(toggled);
    await _refresh();
  }
}
