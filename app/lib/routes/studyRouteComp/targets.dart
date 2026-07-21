import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ps_books/services/dbServices/target.dart';
import 'package:ps_books/services/notifications.dart';
import 'package:ps_books/dbs/database.dart';

class Targets extends StatefulWidget {
  const Targets({super.key});

  @override
  State<Targets> createState() => _TargetsState();
}

class _TargetsState extends State<Targets> {
  final service = TargetService();
  final _notif = Notifications();
  bool _checkedDeadlines = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_checkedDeadlines) {
      _checkedDeadlines = true;
      _checkPassedDeadlines();
    }
  }

  Future<void> _checkPassedDeadlines() async {
    final subjects = await service.getAllSubjects();
    final now = DateTime.now();
    for (final s in subjects) {
      if (s.deadline != null && !s.deadline!.isAfter(now)) {
        final topics = await service.getTopicsForSubject(s.id);
        final completed = topics.where((t) => t.isCompleted).length;
        await _notif.init();
        await _notif.showDeadlineReached(s.name, completed, topics.length);
        await service.clearDeadline(s.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<TargetSubject>>(
            stream: service.watchAllSubjects(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final subjects = snapshot.data ?? [];

              if (subjects.isEmpty) {
                return const Center(
                  child: Text("No study targets yet. Add one below."),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  return SubjectCard(
                    subject: subjects[index],
                    service: service,
                  );
                },
              );
            },
          ),
        ),

        // add subject button
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showAddSubjectDialog(context, service),
                icon: const Icon(Icons.add),
                label: const Text('Add target'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddSubjectDialog(BuildContext context, TargetService service) {
    final controller = TextEditingController();
    DateTime? selectedDeadline;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New study target'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Subject name',
                  hintText: 'e.g. Mathematics',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDeadline ?? now.add(const Duration(days: 7)),
                    firstDate: now.add(const Duration(days: 1)),
                    lastDate: now.add(const Duration(days: 365 * 5)),
                  );
                  if (picked != null) {
                    setDialogState(() => selectedDeadline = picked);
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Deadline (optional)',
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    selectedDeadline != null
                        ? '${selectedDeadline!.day}/${selectedDeadline!.month}/${selectedDeadline!.year}'
                        : 'Tap to select a date',
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isEmpty) return;
                await service.addSubject(name, deadline: selectedDeadline);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class SubjectCard extends StatelessWidget {
  final TargetSubject subject;
  final TargetService service;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TargetTopic>>(
      stream: service.watchTopicsForSubject(subject.id),
      builder: (context, snapshot) {
        final topics = snapshot.data ?? [];
        final completed = topics.where((t) => t.isCompleted).length;
        final total = topics.length;
        final progress = total == 0 ? 0.0 : completed / total;

        final deadline = subject.deadline;
        final deadlineInfo = deadline != null ? _computeDeadlineInfo(deadline, subject.deadlineOriginalDays) : null;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              // header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subject.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '$completed of $total topics done',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${(progress * 100).round()}%',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // edit deadline button
                        IconButton(
                          icon: Icon(
                            deadline != null ? Icons.edit_calendar : Icons.calendar_today,
                            size: 18,
                          ),
                          color: deadline != null
                              ? (deadlineInfo?.isUrgent == true
                                  ? Colors.red
                                  : Theme.of(context).colorScheme.primary)
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          onPressed: () => _showDeadlinePicker(context),
                        ),
                        const SizedBox(width: 4),
                        // delete subject
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          color: Theme.of(context).colorScheme.error,
                          onPressed: () => _confirmDelete(context),
                        ),
                      ],
                    ),
                    if (deadlineInfo != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          deadlineInfo.text,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: deadlineInfo.isUrgent ? Colors.red : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // progress bar
              LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),

              // topic list
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topics.length,
                itemBuilder: (context, index) {
                  return TopicRow(
                    topic: topics[index],
                    service: service,
                  );
                },
              ),

              // add topic row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _showAddTopicDialog(context, subject.id),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text(
                        'Add topic',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _DeadlineInfo _computeDeadlineInfo(DateTime deadline, int? originalDays) {
    final now = DateTime.now();
    final diff = deadline.difference(now);

    if (diff.isNegative) {
      return _DeadlineInfo('Deadline passed', true);
    }

    final totalDays = originalDays ?? diff.inDays;
    final remainingDays = diff.inDays;
    final remainingHours = diff.inHours.remainder(24);

    final elapsedDays = totalDays - remainingDays;
    final isUrgent = totalDays > 0 && elapsedDays > totalDays / 2;

    String text;
    if (remainingDays >= 7) {
      final weeks = remainingDays ~/ 7;
      final extraDays = remainingDays % 7;
      if (extraDays > 0) {
        text = '$weeks week${weeks > 1 ? 's' : ''}, $extraDays day${extraDays > 1 ? 's' : ''} remaining';
      } else {
        text = '$weeks week${weeks > 1 ? 's' : ''} remaining';
      }
    } else if (remainingDays > 0) {
      text = '$remainingDays day${remainingDays > 1 ? 's' : ''} remaining';
    } else if (remainingHours > 0) {
      text = '$remainingHours hour${remainingHours > 1 ? 's' : ''} remaining';
    } else {
      text = 'Less than an hour remaining';
    }

    return _DeadlineInfo(text, isUrgent);
  }

  void _showDeadlinePicker(BuildContext context) {
    final now = DateTime.now();
    showDatePicker(
      context: context,
      initialDate: subject.deadline ?? now.add(const Duration(days: 7)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    ).then((picked) {
      if (picked != null) {
        final originalDays = picked.difference(now).inDays;
        service.updateDeadline(subject.id, picked, originalDays);
      }
    });
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete target?'),
        content: Text(
          'This will delete "${subject.name}" and all its topics.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () async {
              await service.deleteSubject(subject.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddTopicDialog(BuildContext context, int subjectId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add topic'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Topic name',
            hintText: 'e.g. Integration by parts',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              await service.addTopic(name, subjectId);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _DeadlineInfo {
  final String text;
  final bool isUrgent;
  _DeadlineInfo(this.text, this.isUrgent);
}

class TopicRow extends StatelessWidget {
  final TargetTopic topic;
  final TargetService service;

  const TopicRow({super.key, required this.topic, required this.service});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: GestureDetector(
        onTap: () => service.markComplete(topic.id, !topic.isCompleted),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: topic.isCompleted
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            border: Border.all(
              color: topic.isCompleted
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
              width: 1.5,
            ),
          ),
          child: topic.isCompleted
              ? const Icon(Icons.check, size: 12, color: Colors.white)
              : null,
        ),
      ),
      title: Text(
        topic.name,
        style: TextStyle(
          fontSize: 13,
          decoration: topic.isCompleted
              ? TextDecoration.lineThrough
              : TextDecoration.none,
          color: topic.isCompleted
              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close, size: 16),
        onPressed: () => service.deleteTopic(topic.id),
      ),
    );
  }
}
