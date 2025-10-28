import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nurse_app/core/theme/app_theme.dart';
import 'package:nurse_app/features/tasks/domain/entities/task.dart';
import 'package:nurse_app/features/visits/domain/entities/visit.dart';

class TaskCompletionItem extends StatefulWidget {
  final Task task;
  final TaskCompletion taskCompletion;
  final Function(TaskCompletion) onChanged;

  const TaskCompletionItem({
    super.key,
    required this.task,
    required this.taskCompletion,
    required this.onChanged,
  });

  @override
  State<TaskCompletionItem> createState() => _TaskCompletionItemState();
}

class _TaskCompletionItemState extends State<TaskCompletionItem> {
  late TextEditingController _notesController;
  late bool _isCompleted;
  
  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.taskCompletion.notes ?? '');
    _isCompleted = widget.taskCompletion.completed;
  }
  
  @override
  void didUpdateWidget(TaskCompletionItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.taskCompletion != widget.taskCompletion) {
      _notesController.text = widget.taskCompletion.notes ?? '';
      setState(() {
        _isCompleted = widget.taskCompletion.completed;
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
  
  void _toggleCompletion() {
    final now = DateTime.now();
    final updatedTaskCompletion = TaskCompletion(
      taskId: widget.taskCompletion.taskId,
      taskTitle: widget.taskCompletion.taskTitle,
      completed: !_isCompleted,
      completedAt: !_isCompleted ? now : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );
    
    setState(() {
      _isCompleted = !_isCompleted;
    });
    
    widget.onChanged(updatedTaskCompletion);
  }
  
  void _updateNotes() {
    final updatedTaskCompletion = TaskCompletion(
      taskId: widget.taskCompletion.taskId,
      taskTitle: widget.taskCompletion.taskTitle,
      completed: _isCompleted,
      completedAt: widget.taskCompletion.completedAt,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );
    
    widget.onChanged(updatedTaskCompletion);
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(widget.task.priority);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Completion checkbox with one-tap functionality
            InkWell(
              onTap: _toggleCompletion,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _isCompleted 
                    ? AppColors.success.withOpacity(0.1) 
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isCompleted ? AppColors.success : AppColors.secondary,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: _isCompleted
                    ? const Icon(Icons.check, color: AppColors.success, size: 32)
                    : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Task details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: priorityColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: _isCompleted 
                                ? TextDecoration.lineThrough 
                                : null,
                            color: _isCompleted 
                                ? AppColors.textSecondary 
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.task.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: _isCompleted 
                          ? AppColors.textSecondary 
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Due: ${DateFormat('MMM dd, yyyy - HH:mm').format(widget.task.dueDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isDueDatePassed(widget.task.dueDate) && !_isCompleted
                          ? AppColors.danger
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (_isCompleted && widget.taskCompletion.completedAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Completed: ${DateFormat('MMM dd, yyyy - HH:mm').format(widget.taskCompletion.completedAt!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        // Notes field (expands when task is completed)
        if (_isCompleted) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              hintText: 'Add notes about this task...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            maxLines: 2,
            onChanged: (_) => _updateNotes(),
          ),
        ],
      ],
    );
  }
  
  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return AppColors.danger;
      case TaskPriority.medium:
        return AppColors.warning;
      case TaskPriority.low:
        return AppColors.success;
    }
  }
  
  bool _isDueDatePassed(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now());
  }
}
