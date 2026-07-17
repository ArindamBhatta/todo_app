import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/features/splash/presentation/page/splash_screen.dart';
import 'package:todo/core/theme/theme_bloc.dart';
// import 'package:awesome_notifications/awesome_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await AwesomeNotifications().initialize(
  //   null,
  //   [
  //     NotificationChannel(
  //       channelGroupKey: 'urgent_tasks_group',
  //       channelKey: 'urgent_important_channel',
  //       channelName: 'Urgent Important Tasks',
  //       channelDescription: 'Notification channel for urgent important tasks',
  //       defaultColor: const Color(0xFFEF4444),
  //       ledColor: Colors.red,
  //       importance: NotificationImportance.High,
  //       channelShowBadge: true,
  //       playSound: true,
  //     ),
  //   ],
  //   channelGroups: [
  //     NotificationChannelGroup(
  //       channelGroupKey: 'urgent_tasks_group',
  //       channelGroupName: 'Urgent Tasks Group',
  //     ),
  //   ],
  //   debug: true,
  // );

  // Request notification permissions if not already allowed
  // await AwesomeNotifications().isNotificationAllowed().then((isAllowed) async {
  //   if (!isAllowed) {
  //     await AwesomeNotifications().requestPermissionToSendNotifications();
  //   }
  // });

  runApp(const ProviderScope(child: TodoApp()));
}

class TodoApp extends ConsumerWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (context) => ThemeBloc(initialThemeMode: ThemeMode.light),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Todo App",
            home: const SplashScreen(),
            theme: themeState.themeData,
          );
        },
      ),
    );
  }
}
