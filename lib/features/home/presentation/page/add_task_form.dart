import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:todo/data/todo.dart';
import 'package:intl/intl.dart';

class AddTaskForm extends StatefulWidget {
  final Future<void> Function(ElementTask newTask) onAdd;

  const AddTaskForm({required this.onAdd, super.key});

  @override
  State<AddTaskForm> createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<AddTaskForm> {
  //* Properties
  final _formKey = GlobalKey<FormState>();
  String title = UrgencyLevel.urgentImportant.value;
  String name = '';
  String category = Category.office.value;
  DateTime startTime = DateTime.now();
  DateTime absoluteDeadline = DateTime.now().add(Duration(hours: 1));
  DateTime desireDeadline = DateTime.now().add(Duration(days: 1));
  Color currentColor = Colors.white;
  late Color pickerColor;

  //* methods
  void changeColor(Color color) {
    setState(() {
      pickerColor = color;
    });
  }

  Future<void> pickDateTime({
    required DateTime initialDate,
    required Function(DateTime) onPicked,
  }) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );
      if (time != null) {
        onPicked(
          DateTime(date.year, date.month, date.day, time.hour, time.minute),
        );
      }
    }
  }

  Widget _buildDateTimePicker({
    required String label,
    required DateTime value,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label),
        subtitle: Text(DateFormat('MMM d, yyyy h:mm a').format(value)),

        trailing: const Icon(Icons.calendar_today),
        onTap: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 200,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: title,
                          items:
                              UrgencyLevel.values
                                  .map(
                                    (e) => DropdownMenuItem<String>(
                                      value: e.value,
                                      child: Text(e.value),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) => setState(() => title = val!),
                          decoration: InputDecoration(
                            labelText: "Urgency Level",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          value: category,
                          items:
                              Category.values
                                  .map(
                                    (e) => DropdownMenuItem<String>(
                                      value: e.value,
                                      child: Text(e.value),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) => setState(() => category = val!),
                          decoration: InputDecoration(
                            labelText: "Category",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  //* Text Field
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Task Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (val) => name = val,
                    validator:
                        (val) => val == null || val.isEmpty ? "Required" : null,
                  ),

                  const SizedBox(height: 16),

                  _buildDateTimePicker(
                    label: "Absolute Deadline",
                    value: absoluteDeadline,
                    onPressed:
                        () => pickDateTime(
                          initialDate: absoluteDeadline,
                          onPicked:
                              (dt) => setState(() {
                                absoluteDeadline = dt;
                              }),
                        ),
                  ),

                  _buildDateTimePicker(
                    label: "Desired Deadline",
                    value: desireDeadline,
                    onPressed:
                        () => pickDateTime(
                          initialDate: desireDeadline,
                          onPicked:
                              (dt) => setState(() {
                                desireDeadline = dt;
                              }),
                        ),
                  ),
                  const SizedBox(height: 16),

                  //* Color Picker
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentColor,
                        foregroundColor: currentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        pickerColor = currentColor;
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Pick a color!'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: pickerColor,
                                  onColorChanged: changeColor,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    setState(() => currentColor = pickerColor);
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Got it'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.color_lens_outlined),
                      label: const Text('Choose Task Color', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5), // Indigo 600
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Add Task', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await widget.onAdd(
                            ElementTask(
                              name: name,
                              urgencyLevel: title,
                              color: currentColor,
                              isPending: false,
                              startTime: startTime,
                              absoluteDeadline: absoluteDeadline,
                              category: category,
                              desireDeadline: desireDeadline,
                            ),
                          );
                          if (mounted) {
                            Navigator.pop(context);
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
