
// Forms
import 'package:flutter/material.dart';
import 'package:ps_books/services/DB%20services/timetableToDB.dart';
import 'package:ps_books/dbs/database.dart';

class AddSessionForm extends StatefulWidget{
  const AddSessionForm({required this.dayId});
  final int dayId;

  @override
  State<AddSessionForm> createState() => AddSessionFormState();
}

class AddSessionFormState extends State<AddSessionForm> {
  late final TextEditingController start_time;
  late final TextEditingController end_time;
  late final TextEditingController subjects;

  @override
  void initState() {
    super.initState();
    start_time = TextEditingController();
    end_time = TextEditingController();
    subjects = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    start_time.dispose();
    end_time.dispose();
    subjects.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add Session"),
      content: Column(
        children: [
          Text(
            'Add Session',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),

          // start time
          TextFormField(
            controller: start_time,
            decoration: const InputDecoration(labelText: 'Start time'),
          ),
          const SizedBox(height: 8),

          // end time
          TextFormField(
            controller: end_time,
            decoration: const InputDecoration(labelText: 'End time'),
          ),
          const SizedBox(height: 8),

          // subjects — comma separated same as your web version
          TextFormField(
            controller: subjects,
            decoration: const InputDecoration(
              labelText: 'Subjects',
              hintText: 'Mathematics, Physics',
            ),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  await TimetableToDb().addSession(
                    dayId: widget.dayId,
                    start: start_time.text,
                    end: end_time.text,
                    subjects: subjects.text,
                  );
                  Navigator.pop(context);
                },
                child: Text("Submit"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Edit Session

class EditSessionForm extends StatefulWidget {
  const EditSessionForm({
    required this.sessionId,
    required this.session,
  });

  final int sessionId;
  final TimetableSession session;

  @override
  State<EditSessionForm> createState() => _EditSessionFormState();
}

class _EditSessionFormState extends State<EditSessionForm> {
  late final TextEditingController start_time;
  late final TextEditingController end_time;
  late final TextEditingController subjects;

  @override
  void initState() {
    super.initState();
    start_time = TextEditingController();
    end_time = TextEditingController();
    subjects = TextEditingController();

    start_time.text = widget.session.start;
    end_time.text = widget.session.end;
    subjects.text = widget.session.subjects;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    start_time.dispose();
    end_time.dispose();
    subjects.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit Session"),
      content: Column(
        children: [
          const SizedBox(height: 8),

          // start time
          TextFormField(
            controller: start_time,
            decoration: const InputDecoration(labelText: 'Start time'),
          ),
          const SizedBox(height: 8),

          // end time
          TextFormField(
            controller: end_time,
            decoration: const InputDecoration(labelText: 'End time'),
          ),
          const SizedBox(height: 8),

          // subjects — comma separated same as your web version
          TextFormField(
            controller: subjects,
            decoration: const InputDecoration(
              labelText: 'Subjects',
              hintText: 'Mathematics, Physics',
            ),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  await TimetableToDb().editSession(
                    widget.sessionId,
                    start: start_time.text,
                    end: end_time.text,
                    subjects: subjects.text,
                  );
                  Navigator.pop(context);
                },
                child: Text("Submit"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
