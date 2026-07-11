import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo/data/todo.dart';
import 'package:todo/features/home/presentation/page/add_task_form.dart';
import 'package:animations/animations.dart';
import 'package:todo/features/home/presentation/logic/todo_manager.dart';
import 'package:intl/intl.dart';

class CategoryStyle {
  final Color backgroundColor;
  final Color progressColor;
  final Color iconColor;
  final IconData icon;
  final String label;

  CategoryStyle({
    required this.backgroundColor,
    required this.progressColor,
    required this.iconColor,
    required this.icon,
    required this.label,
  });
}

CategoryStyle getCategoryStyle(String category) {
  switch (category) {
    case 'Office':
      return CategoryStyle(
        backgroundColor: const Color(0xFFE0F2FE), // Sky blue 100
        progressColor: const Color(0xFF0284C7), // Sky blue 600
        iconColor: const Color(0xFFEC4899), // Pink 500
        icon: Icons.business_center_rounded,
        label: 'Office Project',
      );
    case 'Personal':
      return CategoryStyle(
        backgroundColor: const Color(0xFFFFF0F5), // Lavender/pink 50
        progressColor: const Color(0xFF8B5CF6), // Purple 500
        iconColor: const Color(0xFF8B5CF6), // Purple 500
        icon: Icons.person_rounded,
        label: 'Personal Project',
      );
    case 'Self':
      return CategoryStyle(
        backgroundColor: const Color(0xFFFFEDD5), // Orange 100
        progressColor: const Color(0xFFF97316), // Orange 500
        iconColor: const Color(0xFFF97316), // Orange 500
        icon: Icons.book_rounded,
        label: 'Daily Study',
      );
    case 'Health':
      return CategoryStyle(
        backgroundColor: const Color(0xFFDCFCE7), // Green 100
        progressColor: const Color(0xFF10B981), // Green 500
        iconColor: const Color(0xFF10B981), // Green 500
        icon: Icons.favorite_rounded,
        label: 'Health & Fitness',
      );
    case 'Finance':
      return CategoryStyle(
        backgroundColor: const Color(0xFFFEE2E2), // Red 100
        progressColor: const Color(0xFFEF4444), // Red 500
        iconColor: const Color(0xFFEF4444), // Red 500
        icon: Icons.account_balance_wallet_rounded,
        label: 'Finance Tracker',
      );
    case 'Career':
      return CategoryStyle(
        backgroundColor: const Color(0xFFE2F0FD), // Sky blue 50
        progressColor: const Color(0xFF0EA5E9), // Blue 500
        iconColor: const Color(0xFF0EA5E9), // Blue 500
        icon: Icons.work_rounded,
        label: 'Career Growth',
      );
    case 'Home':
      return CategoryStyle(
        backgroundColor: const Color(0xFFECFDF5), // Emerald 50
        progressColor: const Color(0xFF059669), // Emerald 600
        iconColor: const Color(0xFF059669), // Emerald 600
        icon: Icons.home_rounded,
        label: 'Home Tasks',
      );
    case 'Leisure':
      return CategoryStyle(
        backgroundColor: const Color(0xFFFFF1F2), // Rose 50
        progressColor: const Color(0xFFF43F5E), // Rose 500
        iconColor: const Color(0xFFF43F5E), // Rose 500
        icon: Icons.surfing_rounded,
        label: 'Leisure Activities',
      );
    case 'Fun':
      return CategoryStyle(
        backgroundColor: const Color(0xFFFEF9C3), // Yellow 100
        progressColor: const Color(0xFFEAB308), // Yellow 500
        iconColor: const Color(0xFFEAB308), // Yellow 500
        icon: Icons.celebration_rounded,
        label: 'Fun & Games',
      );
    default:
      return CategoryStyle(
        backgroundColor: const Color(0xFFF1F5F9), // Slate 100
        progressColor: const Color(0xFF64748B), // Slate 500
        iconColor: const Color(0xFF64748B), // Slate 500
        icon: Icons.task_alt_rounded,
        label: category,
      );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ContainerTransitionType _transitionType = ContainerTransitionType.fade;

  Future<void> _addTaskToList(ElementTask newTask) async {
    await ref.read(taskListProvider.notifier).addTask(newTask);
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
            onPressed: () async {
              await ref.read(taskListProvider.notifier).toggleTaskStatus(task.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
            ),
            child: Text(task.isPending ? 'Complete' : 'Reopen'),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Ultra-clean premium slate background
      body: SafeArea(
        child: tasksAsyncValue.when(
          data: (tasks) {
            final totalTasks = tasks.length;
            final completedTasks = tasks.where((t) => !t.isPending).length;
            final inProgressTasks = tasks.where((t) => t.isPending).toList();

            final completionRate = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

            // Group tasks by category
            final Map<String, List<ElementTask>> groupedTasks = {};
            for (final t in tasks) {
              groupedTasks.putIfAbsent(t.category, () => []).add(t);
            }
            final categories = groupedTasks.keys.toList();

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Profile Header
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: const Color(0xFFE2E8F0),
                          child: ClipOval(
                            child: Image.network(
                              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.person_rounded,
                                color: Color(0xFF4F46E5),
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello!',
                              style: TextStyle(
                                fontSize: 13,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Livia Vaccaro',
                              style: TextStyle(
                                fontSize: 18,
                                color: const Color(0xFF0F172A),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Notification Bell
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.notifications_rounded,
                              color: Color(0xFF0F172A),
                              size: 26,
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF5E42EB),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 2. Banner Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5E42EB),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5E42EB).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your today\'s task\nalmost done!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                height: 38,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF5E42EB),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                  ),
                                  child: const Text(
                                    'View Task',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 78,
                              height: 78,
                              child: CircularProgressIndicator(
                                value: completionRate,
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                color: Colors.white,
                                strokeWidth: 7,
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Text(
                              '${(completionRate * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 3. In Progress Section
                  Row(
                    children: [
                      const Text(
                        'In Progress',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${inProgressTasks.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5E42EB),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (inProgressTasks.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFEEF2F6)),
                      ),
                      child: const Center(
                        child: Text(
                          'No tasks in progress today! 🎉',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: inProgressTasks.map((task) {
                          final style = getCategoryStyle(task.category);
                          
                          // Calculate time elapsed ratio
                          final totalDuration = task.absoluteDeadline.difference(task.startTime).inMinutes;
                          final elapsed = DateTime.now().difference(task.startTime).inMinutes;
                          double progress = 0.5;
                          if (totalDuration > 0) {
                            progress = (elapsed / totalDuration).clamp(0.1, 0.9);
                          }

                          return GestureDetector(
                            onTap: () => _showTaskDetailsDialog(context, task),
                            child: Container(
                              width: 200,
                              height: 130,
                              margin: const EdgeInsets.only(right: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: style.backgroundColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: style.progressColor.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          style.label,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          style.icon,
                                          size: 14,
                                          color: style.iconColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: Text(
                                      task.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Progress Bar
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 5,
                                      backgroundColor: Colors.white,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        style.progressColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 28),

                  // 4. Task Groups Section
                  Row(
                    children: [
                      const Text(
                        'Task Groups',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${categories.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5E42EB),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categories.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final categoryTasks = groupedTasks[category] ?? [];
                      final completedGroupTasks = categoryTasks.where((t) => !t.isPending).length;
                      final totalGroupTasks = categoryTasks.length;
                      final groupCompletionRate = totalGroupTasks == 0 ? 0.0 : completedGroupTasks / totalGroupTasks;

                      final style = getCategoryStyle(category);

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: style.backgroundColor.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                style.icon,
                                size: 24,
                                color: style.iconColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    style.label,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$totalGroupTasks Tasks',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 46,
                                  height: 46,
                                  child: CircularProgressIndicator(
                                    value: groupCompletionRate,
                                    backgroundColor: const Color(0xFFF1F5F9),
                                    color: style.progressColor,
                                    strokeWidth: 4,
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                                Text(
                                  '${(groupCompletionRate * 100).toInt()}%',
                                  style: const TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF5E42EB),
            ),
          ),
          error: (error, _) => Center(
            child: Text('Failed to load tasks: $error'),
          ),
        ),
      ),
      floatingActionButton: OpenContainer(
        transitionDuration: const Duration(milliseconds: 600),
        transitionType: _transitionType,
        openBuilder: (context, action) {
          return AddTaskForm(onAdd: _addTaskToList);
        },
        closedElevation: 6,
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        closedColor: const Color(0xFF5E42EB),
        openColor: Colors.white,
        closedBuilder: (context, action) {
          return FloatingActionButton(
            backgroundColor: const Color(0xFF5E42EB),
            onPressed: action,
            child: const Icon(Icons.add, size: 30, color: Colors.white),
          );
        },
      ),
    );
  }
}
