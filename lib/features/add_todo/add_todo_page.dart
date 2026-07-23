import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:todo/features/add_todo/data/todo.dart';
import 'package:todo/features/home/presentation/logic/todo_cubit.dart';

class AddTodoPage extends StatefulWidget {
  const AddTodoPage({super.key});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final _formKey = GlobalKey<FormState>();

  String taskGroup = categoryImageMap.keys.first;
  String projectName = '';
  String description = '';

  late DateTime startDate;
  late DateTime endDate;
  UrgencyLevel urgencyLevel = UrgencyLevel.urgentImportant;

  @override
  void initState() {
    super.initState();
    final today = _today();
    startDate = today;
    endDate = today;
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Widget _buildCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Future<void> _pickDate(bool isStartDate) async {
    final initialDate = isStartDate ? startDate : endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF6B4EFF)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
          if (endDate.isBefore(startDate)) {
            endDate = picked;
          }
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> _showCategoryPicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Task Group',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1E2D),
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                    itemCount: categoryImageMap.length,
                    itemBuilder: (context, index) {
                      final category = categoryImageMap.keys.elementAt(index);
                      final imagePath = categoryImageMap[category]!;
                      final isSelected = category == taskGroup;

                      return InkWell(
                        onTap: () => Navigator.pop(context, category),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? const Color(0xFF6B4EFF)
                                      : const Color(0xFFE8EAF0),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(14),
                                  ),
                                  child: Image.asset(
                                    imagePath,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                                child: Text(
                                  category,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        isSelected
                                            ? const Color(0xFF6B4EFF)
                                            : const Color(0xFF1E1E2D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() => taskGroup = selected);
    }
  }

  Future<void> _showUrgencyPicker() async {
    final selected = await showModalBottomSheet<UrgencyLevel>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Urgency Level',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1E2D),
                  ),
                ),
                const SizedBox(height: 8),
                ...UrgencyLevel.values.map((level) {
                  final isSelected = level == urgencyLevel;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? const Color(0xFFF3F0FF)
                                : const Color(0xFFF8F9FC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        getIconData(level.value),
                        color:
                            isSelected
                                ? const Color(0xFF6B4EFF)
                                : const Color(0xFF8F93A4),
                      ),
                    ),
                    title: Text(
                      level.value,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color:
                            isSelected
                                ? const Color(0xFF6B4EFF)
                                : const Color(0xFF1E1E2D),
                      ),
                    ),
                    trailing:
                        isSelected
                            ? const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF6B4EFF),
                            )
                            : null,
                    onTap: () => Navigator.pop(context, level),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() => urgencyLevel = selected);
    }
  }

  void _saveProject() {
    if (!_formKey.currentState!.validate()) return;

    final trimmedName = projectName.trim();
    if (trimmedName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a project name')),
      );
      return;
    }

    final task = ElementTask(
      id: uuid.v4(),
      name: trimmedName,
      description: description,
      startTime: startDate,
      endTime: endDate,
      category: taskGroup,
      urgencyLevel: urgencyLevel.value,
      isPending: true,
    );

    context.read<TodoCubit>().addTask(task);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF1E1E2D),
            size: 28,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Add Project',
          style: TextStyle(
            color: Color(0xFF1E1E2D),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF1E1E2D),
                  size: 28,
                ),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6B4EFF),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF4FEFF), Color(0xFFFFF4FA), Color(0xFFF9FFEF)],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _showCategoryPicker,
                    child: _buildCard(
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              categoryImageMap[taskGroup]!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Task Group',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF8F93A4),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  taskGroup,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF1E1E2D),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down_rounded,
                            color: Color(0xFF1E1E2D),
                            size: 32,
                          ),
                        ],
                      ),
                    ),
                  ),

                  _buildCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Project Name',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8F93A4),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextFormField(
                          initialValue: projectName,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1E1E2D),
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Enter project name',
                            isDense: true,
                            contentPadding: EdgeInsets.only(top: 8, bottom: 8),
                            border: InputBorder.none,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Project name is required';
                            }
                            return null;
                          },
                          onChanged: (val) => projectName = val,
                        ),
                      ],
                    ),
                  ),

                  _buildCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8F93A4),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextFormField(
                          initialValue: description,
                          maxLines: 4,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1E1E2D),
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Enter project description (optional)',
                            isDense: true,
                            contentPadding: EdgeInsets.only(top: 12, bottom: 8),
                            border: InputBorder.none,
                          ),
                          onChanged: (val) => description = val,
                        ),
                      ],
                    ),
                  ),

                  GestureDetector(
                    onTap: () => _pickDate(true),
                    child: _buildCard(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F0FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.calendar_today_rounded,
                              color: Color(0xFF6B4EFF),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Start Date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF8F93A4),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('dd MMMM, yyyy').format(startDate),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF1E1E2D),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down_rounded,
                            color: Color(0xFF1E1E2D),
                            size: 32,
                          ),
                        ],
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () => _pickDate(false),
                    child: _buildCard(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F0FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.calendar_today_rounded,
                              color: Color(0xFF6B4EFF),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'End Date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF8F93A4),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('dd MMMM, yyyy').format(endDate),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF1E1E2D),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down_rounded,
                            color: Color(0xFF1E1E2D),
                            size: 32,
                          ),
                        ],
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: _showUrgencyPicker,
                    child: _buildCard(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF4E5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              getIconData(urgencyLevel.value),
                              color: const Color(0xFFF59E0B),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Urgency Level',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF8F93A4),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  urgencyLevel.value,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF1E1E2D),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down_rounded,
                            color: Color(0xFF1E1E2D),
                            size: 32,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6B4EFF).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B4EFF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: _saveProject,
                      child: const Text(
                        'Add Project',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
