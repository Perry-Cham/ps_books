import 'package:flutter/material.dart';
import 'package:ps_books/services/target.dart';
import 'package:ps_books/dbs/database.dart';
import '../../services/target.dart';

class Targets extends StatelessWidget {
  const Targets({super.key});

  @override
  Widget build(BuildContext context) {
    final service = TargetService();

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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New study target'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Subject name',
            hintText: 'e.g. Mathematics',
          ),
          autofocus: true,
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
              await service.addSubject(name);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
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
                child: Row(
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
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
                    const SizedBox(width: 8),
                    // delete subject
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      color: Theme.of(context).colorScheme.error,
                      onPressed: () => _confirmDelete(context),
                    ),
                  ],
                ),
              ),

              // progress bar
              LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceVariant,
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
                      onPressed: () =>
                          _showAddTopicDialog(context, subject.id),
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
              ? Theme.of(context).colorScheme.onSurface.withOpacity(0.4)
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