import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo/core/scrollable_tab_bar.dart';
import 'package:todo/data/todo.dart';
import 'package:todo/features/home/presentation/page/add_task_form.dart';
import 'package:animations/animations.dart';
import 'package:todo/features/home/presentation/logic/todo_manager.dart';

import 'package:intl/intl.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ContainerTransitionType _transitionType = ContainerTransitionType.fade;
  String _selectedCategoryFilter = 'All';
  String _selectedStatusFilter = 'All'; // 'All', 'Active', 'Completed'

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Tasks',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedCategoryFilter = 'All';
                            _selectedStatusFilter = 'All';
                          });
                          setState(() {});
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: ['All', 'Active', 'Completed'].map((status) {
                      final isSelected = _selectedStatusFilter == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                _selectedStatusFilter = status;
                              });
                              setState(() {});
                            }
                          },
                          selectedColor: const Color(0xFFE0E7FF),
                          checkmarkColor: const Color(0xFF4F46E5),
                          labelStyle: TextStyle(
                            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF475569),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: ['All', ...Category.values.map((c) => c.value)].map<Widget>((cat) {
                      final isSelected = _selectedCategoryFilter == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() {
                              _selectedCategoryFilter = cat;
                            });
                            setState(() {});
                          }
                        },
                        selectedColor: const Color(0xFFE0E7FF),
                        checkmarkColor: const Color(0xFF4F46E5),
                        labelStyle: TextStyle(
                          color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF475569),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

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

  void _showTaskDetailsDialog(BuildContext context, ElementTask task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(task.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow(Icons.category, 'Category', task.category),
            _detailRow(Icons.priority_high, 'Urgency', task.urgencyLevel),
            _detailRow(Icons.access_time, 'Start Time', DateFormat('MMM d, yyyy h:mm a').format(task.startTime)),
            _detailRow(Icons.alarm, 'Desired Deadline', DateFormat('MMM d, yyyy h:mm a').format(task.desireDeadline)),
            _detailRow(Icons.dangerous, 'Absolute Deadline', DateFormat('MMM d, yyyy h:mm a').format(task.absoluteDeadline)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(taskListProvider.notifier).deleteTask(task.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsyncValue = ref.watch(taskListProvider);
    final urgencyLevels =
        UrgencyLevel.values.map((level) => level.value).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Matrix'),
        actions: [
          IconButton(
            icon: Icon(
              _selectedCategoryFilter != 'All' || _selectedStatusFilter != 'All'
                  ? Icons.filter_alt
                  : Icons.filter_alt_outlined,
              color: const Color(0xFF4F46E5),
            ),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Column(
          children: [
            // Dynamic overall progress banner
            if (tasksAsyncValue.hasValue) ...[
              Builder(
                builder: (context) {
                  final tasks = tasksAsyncValue.value ?? [];
                  final completed = tasks.where((task) => !task.isPending).length;
                  final total = tasks.length;
                  
                  if (total == 0 || completed == 0 || completed == total) {
                    return const SizedBox.shrink();
                  }
                  
                  final percentage = completed / total;
                  return Container(
                    margin: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEEF2F6), Color(0xFFE0E7FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFC7D2FE)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: CircularProgressIndicator(
                                value: percentage,
                                backgroundColor: const Color(0xFFE2E8F0),
                                color: const Color(0xFF4F46E5),
                                strokeWidth: 5,
                              ),
                            ),
                            Text(
                              '${(percentage * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Task Completion Progress',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4338CA),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$completed of $total tasks completed today',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              ),
            ],
            ScrollableTabBar(
              menuOptions: urgencyLevels,
              tabController: _tabController,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children:
                    urgencyLevels.map((urgency) {
                      return tasksAsyncValue.when(
                        data: (tasks) {
                          final tasksForUrgency =
                              tasks
                                  .where((task) {
                                    final matchesUrgency = task.urgencyLevel == urgency;
                                    final matchesCategory = _selectedCategoryFilter == 'All' || task.category == _selectedCategoryFilter;
                                    bool matchesStatus = true;
                                    if (_selectedStatusFilter == 'Active') {
                                      matchesStatus = task.isPending;
                                    } else if (_selectedStatusFilter == 'Completed') {
                                      matchesStatus = !task.isPending;
                                    }
                                    return matchesUrgency && matchesCategory && matchesStatus;
                                  })
                                  .toList();

                          if (tasksForUrgency.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 8),
                                  Text(
                                    _selectedCategoryFilter != 'All' || _selectedStatusFilter != 'All'
                                        ? 'No tasks match filters'
                                        : 'No tasks yet',
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            );
                          }

                          return GridView.builder(
                            padding: const EdgeInsets.all(8),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1.05,
                                ),
                            itemCount: tasksForUrgency.length,
                            itemBuilder: (context, index) {
                              final task = tasksForUrgency[index];
                              final categoryImagePath =
                                  categoryImageMap[task.category] ??
                                  'assets/Office.jpg';
                              final isCompleted = !task.isPending;

                              return GestureDetector(
                                onTap: () {
                                  _showTaskDetailsDialog(context, task);
                                },
                                child: Card(
                                  elevation: 2,
                                  shadowColor: Colors.black.withOpacity(0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  color: Colors.white,
                                  child: Stack(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Stack(
                                              children: [
                                                Image.asset(
                                                  categoryImagePath,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  fit: BoxFit.cover,
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Colors.transparent,
                                                        Colors.black.withOpacity(0.4),
                                                      ],
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 8,
                                                  left: 10,
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black.withOpacity(0.6),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      task.category,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  task.name,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: isCompleted
                                                        ? const Color(0xFF94A3B8)
                                                        : const Color(0xFF0F172A),
                                                    decoration: isCompleted
                                                        ? TextDecoration.lineThrough
                                                        : TextDecoration.none,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      getIconData(task.urgencyLevel),
                                                      size: 14,
                                                      color: const Color(0xFF4F46E5),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    const Expanded(
                                                      child: Text(
                                                        'Urgent',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: Color(0xFF64748B),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: InkWell(
                                          onTap: () {
                                            ref.read(taskListProvider.notifier)
                                                .toggleTaskStatus(task.id);
                                          },
                                          borderRadius: BorderRadius.circular(20),
                                          child: Container(
                                            width: 26,
                                            height: 26,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isCompleted
                                                  ? const Color(0xFF4F46E5)
                                                  : Colors.white.withOpacity(0.9),
                                              border: Border.all(
                                                color: isCompleted
                                                    ? const Color(0xFF4F46E5)
                                                    : const Color(0xFFCBD5E1),
                                                width: 2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.1),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                )
                                              ],
                                            ),
                                            child: isCompleted
                                                ? const Icon(
                                                    Icons.check,
                                                    size: 14,
                                                    color: Colors.white,
                                                  )
                                                : null,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
        transitionDuration: const Duration(milliseconds: 900),
        transitionType: _transitionType,
        openBuilder: (context, action) {
          return AddTaskForm(onAdd: _addTaskToList);
        },
        closedElevation: 6,
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        closedColor: const Color(0xFF4F46E5), // Indigo 600
        openColor: Colors.white,
        closedBuilder: (context, action) {
          return FloatingActionButton(
            backgroundColor: const Color(0xFF4F46E5), // Indigo 600
            onPressed: action,
            child: const Icon(Icons.add, size: 30, color: Colors.white),
          );
        },
      ),
    );
  }
}
