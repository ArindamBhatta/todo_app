import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/features/add_todo/data/todo.dart';
import 'package:todo/features/auth/presentation/logic/auth_manager.dart';
import 'package:todo/features/auth/presentation/logic/auth_state.dart';
import 'package:todo/features/home/presentation/logic/todo_cubit.dart';
import 'package:todo/features/home/presentation/page/details_page.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:todo/features/home/presentation/page/widgets/category_style.dart';
import 'package:todo/features/home/presentation/page/widgets/shake_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkNotificationPermissions();
  }

  void _checkNotificationPermissions() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!mounted) return;
      if (!isAllowed) {
        showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text('Enable Notifications'),
                content: const Text(
                  'To get alerts for Urgent and Important tasks, please allow notifications in settings.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Later'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      AwesomeNotifications()
                          .requestPermissionToSendNotifications()
                          .then((allowed) {
                            if (!allowed) {
                              AwesomeNotifications()
                                  .showNotificationConfigPage();
                            }
                          });
                    },
                    child: const Text('Allow'),
                  ),
                ],
              ),
        );
      }
    });
  }

  Widget _buildProfileHeader() {
    return BlocBuilder<AuthManager, AuthState>(
      builder: (context, authState) {
        final String displayName =
            authState is AuthAuthenticated
                ? authState.user.displayName
                : 'Guest';
        final String? photoUrl =
            authState is AuthAuthenticated ? authState.user.photoUrl : null;

        return Row(
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
                backgroundImage:
                    photoUrl != null ? NetworkImage(photoUrl) : null,
                child:
                    photoUrl == null
                        ? const Icon(
                          Icons.person_rounded,
                          color: Color(0xFF4F46E5),
                          size: 28,
                        )
                        : null,
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
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  onPressed: () async {
                    final isAllowed =
                        await AwesomeNotifications().isNotificationAllowed();
                    if (!isAllowed) {
                      await AwesomeNotifications()
                          .requestPermissionToSendNotifications()
                          .then((allowed) {
                            if (!allowed) {
                              AwesomeNotifications()
                                  .showNotificationConfigPage();
                            }
                          });
                    } else {
                      await AwesomeNotifications().createNotification(
                        content: NotificationContent(
                          id: 9999,
                          channelKey: 'urgent_important_channel',
                          title: '🔔 Notification System Active!',
                          body:
                              'Local notifications are active and ready for Urgent Important tasks.',
                          notificationLayout: NotificationLayout.Default,
                        ),
                      );
                    }
                  },
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
        );
      },
    );
  }

  Widget _buildTaskCard({
    required ElementTask task,
    required CategoryStyle style,
    required double progress,
    required bool isUrgentImportant,
  }) {
    return OpenContainer<void>(
      closedElevation: 0,
      openElevation: 0,
      transitionDuration: const Duration(milliseconds: 450),
      closedColor: Colors.transparent,
      openColor: const Color(0xFFF8FAFC),
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      openShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      closedBuilder: (context, openContainer) {
        return GestureDetector(
          onTap: openContainer,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: style.backgroundColor,
              borderRadius: BorderRadius.circular(20),
              border:
                  isUrgentImportant
                      ? Border.all(color: const Color(0xFFEF4444), width: 1.5)
                      : null,
              image: DecorationImage(
                image: AssetImage(
                  categoryImageMap[task.category] ?? 'assets/Personal.jpg',
                ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.55),
                  BlendMode.darken,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      isUrgentImportant
                          ? const Color(0xFFEF4444).withValues(alpha: 0.25)
                          : style.progressColor.withValues(alpha: 0.05),
                  blurRadius: isUrgentImportant ? 14 : 10,
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
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              style.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          if (isUrgentImportant) ...[
                            const SizedBox(width: 4),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(style.icon, size: 12, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Text(
                    task.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isUrgentImportant
                          ? const Color(0xFFEF4444)
                          : style.progressColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      openBuilder: (context, _) => DetailsPage(task: task),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: BlocBuilder<TodoCubit, TodoState>(
          builder: (context, state) {
            if (state is TodoLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF5E42EB)),
              );
            }
            if (state is TodoEmpty) {
              return const Center(child: Text('No tasks yet.'));
            }
            if (state is TaskError) {
              return Center(
                child: Text(
                  'Failed to load tasks: ${state.message ?? 'Unknown error'}',
                ),
              );
            }
            final tasks = (state as TodoLoaded).tasks;

            final totalTasks = tasks.length;
            final completedTasks = tasks.where((t) => !t.isPending).length;
            final inProgressTasks = tasks.where((t) => t.isPending).toList();
            final completionRate =
                totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Profile Header
                  _buildProfileHeader(),
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
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.2,
                                ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
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
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.4,
                          ),
                      itemCount: inProgressTasks.length,
                      itemBuilder: (context, index) {
                        final task = inProgressTasks[index];
                        final style = getCategoryStyle(task.category);

                        // Calculate time elapsed ratio
                        final totalDuration =
                            task.endTime.difference(task.startTime).inMinutes;
                        final elapsed =
                            DateTime.now().difference(task.startTime).inMinutes;
                        double progress = 0.5;
                        if (totalDuration > 0) {
                          progress = (elapsed / totalDuration).clamp(0.1, 0.9);
                        }

                        final isUrgentImportant =
                            task.urgencyLevel == 'Urgent Important';

                        return ShakeWidget(
                          shake: isUrgentImportant,
                          child: _buildTaskCard(
                            task: task,
                            style: style,
                            progress: progress,
                            isUrgentImportant: isUrgentImportant,
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
