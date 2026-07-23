import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo/features/add_todo/data/todo.dart';
import 'package:todo/features/home/presentation/logic/todo_cubit.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  String _selectedCategoryFilter = 'All';
  String _selectedStatusFilter = 'All'; // 'All', 'Active', 'Completed'

  void _showTaskDetailsDialog(BuildContext context, ElementTask task) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              task.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow(Icons.category, 'Category', task.category),
                _detailRow(Icons.priority_high, 'Urgency', task.urgencyLevel),
                _detailRow(
                  Icons.access_time,
                  'Start Time',
                  DateFormat('MMM d, yyyy h:mm a').format(task.startTime),
                ),
                _detailRow(
                  Icons.alarm,
                  'Desired Deadline',
                  DateFormat('MMM d, yyyy h:mm a').format(task.endTime),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await ctx.read<TodoCubit>().deleteTask(task.id);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
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
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF475569),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }

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
                    children:
                        ['All', 'Active', 'Completed'].map((status) {
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
                                color:
                                    isSelected
                                        ? const Color(0xFF4F46E5)
                                        : const Color(0xFF475569),
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
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
                    children:
                        [
                          'All',
                          ...Category.values.map((c) => c.value),
                        ].map<Widget>((cat) {
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
                              color:
                                  isSelected
                                      ? const Color(0xFF4F46E5)
                                      : const Color(0xFF475569),
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
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
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tasks'),
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
      body: BlocBuilder<TodoCubit, TodoState>(
        builder: (context, state) {
          if (state is TodoLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
            );
          }
          if (state is TaskError) {
            return Center(
              child: Text('Failed to load tasks: ${state.message}'),
            );
          }
          final tasks = (state as TodoLoaded).tasks;
          final filteredTasks =
              tasks.where((task) {
                final matchesCategory =
                    _selectedCategoryFilter == 'All' ||
                    task.category == _selectedCategoryFilter;
                bool matchesStatus = true;
                if (_selectedStatusFilter == 'Active') {
                  matchesStatus = task.isPending;
                } else if (_selectedStatusFilter == 'Completed') {
                  matchesStatus = !task.isPending;
                }
                return matchesCategory && matchesStatus;
              }).toList();

          if (filteredTasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedCategoryFilter != 'All' ||
                            _selectedStatusFilter != 'All'
                        ? 'No tasks match filters'
                        : 'No tasks yet',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              final isCompleted = !task.isPending;
              return GestureDetector(
                onTap: () => _showTaskDetailsDialog(context, task),
                child: Card(
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2F6),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    task.category,
                                    style: const TextStyle(
                                      color: Color(0xFF475569),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  task.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isCompleted
                                            ? const Color(0xFF94A3B8)
                                            : const Color(0xFF0F172A),
                                    decoration:
                                        isCompleted
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              task.urgencyLevel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4F46E5),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () {
                              context.read<TodoCubit>().toggleTaskStatus(
                                task.id,
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    isCompleted
                                        ? const Color(0xFF4F46E5)
                                        : Colors.white.withOpacity(0.9),
                                border: Border.all(
                                  color:
                                      isCompleted
                                          ? const Color(0xFF4F46E5)
                                          : const Color(0xFFCBD5E1),
                                  width: 2,
                                ),
                              ),
                              child:
                                  isCompleted
                                      ? const Icon(
                                        Icons.check,
                                        size: 12,
                                        color: Colors.white,
                                      )
                                      : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
