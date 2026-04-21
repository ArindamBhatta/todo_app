// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:todo/data/todo.dart';
// import 'package:todo/logic/todo_manager.dart';

// class DetailsPage extends ConsumerWidget {
//   final ElementTask task;

//   const DetailsPage({super.key, required this.task});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Task Details')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               task.name,
//               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             Text("Category: ${task.category}"),
//             Text("Start Time: ${task.startTime}"),
//             Text("Deadline: ${task.absoluteDeadline}"),
//             Text("Target Date: ${task.desireDeadline}"),
//             // Text("Expected Submit: ${task.urgencyLevel}"),
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: () async {
//                     await ref
//                         .read(taskListProvider.notifier)
//                         .toggleTaskStatus(task.id);
//                     if (context.mounted) {
//                       Navigator.pop(context);
//                     }
//                   },
//                   icon: Icon(task.isPending ? Icons.undo : Icons.check),
//                   label: Text(
//                     task.isPending ? 'Mark Incomplete' : 'Mark Complete',
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 ElevatedButton.icon(
//                   onPressed: () async {
//                     await ref
//                         .read(taskListProvider.notifier)
//                         .deleteTask(task.id);
//                     if (context.mounted) {
//                       Navigator.pop(context);
//                     }
//                   },
//                   icon: const Icon(Icons.delete),
//                   label: const Text('Delete'),
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
