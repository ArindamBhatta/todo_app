import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo/data/todo.dart';
import 'package:todo/data/todo_repository.dart';

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepository();
});

final taskListProvider =
    AsyncNotifierProvider<TaskListNotifier, List<ElementTask>>(
      TaskListNotifier.new,
    );

class TaskListNotifier extends AsyncNotifier<List<ElementTask>> {
  late final TodoRepository _repository;

  @override
  Future<List<ElementTask>> build() async {
    _repository = ref.read(todoRepositoryProvider);
    return _repository.fetchTasks();
  }

  Future<void> _refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _repository.fetchTasks());
  }

  Future<void> addTask(ElementTask task) async {
    await _repository.insertTask(task);
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
    final tasks = state.valueOrNull ?? await _repository.fetchTasks();
    final taskIndex = tasks.indexWhere((task) => task.id == id);
    if (taskIndex == -1) {
      return;
    }

    final toggledTask = tasks[taskIndex].copyWith(
      isPending: !tasks[taskIndex].isPending,
    );
    await _repository.updateTask(toggledTask);
    await _refresh();
  }
}
