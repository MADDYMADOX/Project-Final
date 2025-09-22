import 'package:flutter/material.dart';
import '../models/task_type.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import 'glass_card.dart';

/// Premium task type card with glassmorphism and animations
class TaskTypeCard extends StatefulWidget {
  final TaskType taskType;
  final bool isSelected;
  final VoidCallback onTap;

  const TaskTypeCard({
    super.key,
    required this.taskType,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<TaskTypeCard> createState() => _TaskTypeCardState();
}

class _TaskTypeCardState extends State<TaskTypeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _iconAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    if (widget.isSelected) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(TaskTypeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.repeat(reverse: true);
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final taskGradient = AppColors.getTaskTypeGradient(widget.taskType.displayName);
    final taskColor = AppColors.getTaskTypeColor(widget.taskType.displayName);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isSelected ? _pulseAnimation.value : 1.0,
          child: AnimatedGlassCard(
            onTap: widget.onTap,
            isSelected: widget.isSelected,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated icon container with gradient
                AnimatedContainer(
                  duration: AppConstants.mediumAnimation,
                  width: widget.isSelected ? 64 : 56,
                  height: widget.isSelected ? 64 : 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.isSelected ? taskGradient : [
                        taskColor.withAlpha((0.2 * 255).round()),
                        taskColor.withAlpha((0.1 * 255).round()),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: widget.isSelected ? [
                      BoxShadow(
                        color: taskColor.withAlpha((0.3 * 255).round()),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ] : null,
                  ),
                  child: Transform.scale(
                    scale: widget.isSelected ? _iconAnimation.value : 1.0,
                    child: Icon(
                      _getTaskIcon(widget.taskType),
                      color: widget.isSelected ? Colors.white : taskColor,
                      size: widget.isSelected ? 32 : 28,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Task name with enhanced typography
                AnimatedDefaultTextStyle(
                  duration: AppConstants.mediumAnimation,
                  style: theme.textTheme.titleMedium!.copyWith(
                    color: widget.isSelected ? taskColor : theme.colorScheme.onSurface,
                    fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: widget.isSelected ? 16 : 14,
                    letterSpacing: widget.isSelected ? 0.5 : 0.25,
                  ),
                  child: Text(
                    widget.taskType.displayName,
                    textAlign: TextAlign.center,
                  ),
                ),
                
                // Subtle description
                if (widget.isSelected) ...[
                  const SizedBox(height: 8),
                  AnimatedOpacity(
                    duration: AppConstants.mediumAnimation,
                    opacity: widget.isSelected ? 1.0 : 0.0,
                    child: Text(
                      _getTaskDescription(widget.taskType),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getTaskIcon(TaskType taskType) {
    switch (taskType) {
      case TaskType.writing:
        return Icons.edit_note_rounded;
      case TaskType.coding:
        return Icons.code_rounded;
      case TaskType.studying:
        return Icons.school_rounded;
      case TaskType.reading:
        return Icons.menu_book_rounded;
      case TaskType.creative:
        return Icons.palette_rounded;
      case TaskType.other:
        return Icons.work_rounded;
    }
  }

  String _getTaskDescription(TaskType taskType) {
    switch (taskType) {
      case TaskType.writing:
        return 'Creative writing & documentation';
      case TaskType.coding:
        return 'Programming & development';
      case TaskType.studying:
        return 'Learning & research';
      case TaskType.reading:
        return 'Reading & comprehension';
      case TaskType.creative:
        return 'Design & creative work';
      case TaskType.other:
        return 'General productivity';
    }
  }
}