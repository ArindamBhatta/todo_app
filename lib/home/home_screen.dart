import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo/common/scrollable_tab_bar.dart';
import 'package:todo/data/todo.dart';
import 'package:todo/home/add_task_form.dart';
import 'package:animations/animations.dart';
import 'package:todo/logic/todo_manager.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ContainerTransitionType _transitionType = ContainerTransitionType.fade;

  Future<void> _addTaskToList(ElementTask newTask) async {
    await ref.read(taskListProvider.notifier).addTask(newTask);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: UrgencyLevel.values.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsyncValue = ref.watch(taskListProvider);
    final urgencyLevels =
        UrgencyLevel.values.map((level) => level.value).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Todo App')),
        backgroundColor: Colors.tealAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Column(
          children: [
            ScrollableTabBar(
              menuOptions: urgencyLevels,
              tabController: _tabController,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children:
                    urgencyLevels.map((urgency) {
                      return tasksAsyncValue.when(
                        data: (tasks) {
                          final tasksForUrgency =
                              tasks
                                  .where((task) => task.urgencyLevel == urgency)
                                  .toList();

                          if (tasksForUrgency.isEmpty) {
                            return const Center(child: Text('No tasks yet'));
                          }

                          return ListView.builder(
                            itemCount: tasksForUrgency.length,
                            itemBuilder: (context, index) {
                              final task = tasksForUrgency[index];
                              final categoryImagePath =
                                  categoryImageMap[task.category] ??
                                  'assets/Office.jpg';

                              return ListTile(
                                title: Text(task.name),
                                subtitle: Text(task.category),
                                leading: CircleAvatar(
                                  backgroundImage: AssetImage(
                                    categoryImagePath,
                                  ),
                                ),
                                trailing: Icon(getIconData(task.urgencyLevel)),
                              );
                            },
                          );
                        },
                        loading:
                            () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        error:
                            (error, _) => Center(
                              child: Text('Failed to load tasks: $error'),
                            ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: OpenContainer(
        transitionDuration: Duration(milliseconds: 900),
        transitionType: _transitionType,
        openBuilder: (context, action) {
          return AddTaskForm(onAdd: _addTaskToList);
        },
        closedElevation: 6,
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        closedColor: Colors.teal,
        openColor: Colors.white,

        closedBuilder: (context, action) {
          return FloatingActionButton(
            backgroundColor: Colors.teal,
            onPressed: action,
            child: const Icon(Icons.add, size: 30, color: Colors.white),
          );
        },
      ),
    );
  }
}
