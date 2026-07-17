part of 'todo_manager.dart';

sealed class TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<ElementTask> tasks;
  TaskLoaded(this.tasks);
}

class TaskError extends TaskState {
  final String message;
  TaskError(this.message);
}
