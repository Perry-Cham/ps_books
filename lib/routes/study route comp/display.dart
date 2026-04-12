import 'package:flutter/material.dart';
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/routes/study%20route%20comp/timetable.dart';
import 'package:ps_books/services/timetableToDB.dart';

class TimetableDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return StreamBuilder(
      stream: Timetabletodb().getTimeTable(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          print(snapshot.error);
          return Center(
            child: Text("You haven't created any study TimeTables Yet"),
          );
        }
        //Rework this logic to add error handling
        print("hello");
        final data = snapshot.data;
        if (data == null || data.isEmpty) {
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: Text("You haven't created any study TimeTables Yet"),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return TimeTableForm();
                          },
                        );
                      },
                      icon: Icon(Icons.add),
                      label: Text('Create a new timetable'),
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          return Display(timetable: data);
        }
      },
    );
  }
}

class Display extends StatefulWidget {
  Display({super.key, required this.timetable});
  final List<TimeTable> timetable;

  @override
  State<Display> createState() {
    // TODO: implement createState
    return DisplayState();
  }
}

class DisplayState extends State<Display> with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = TabController(
      length: widget.timetable.length,
      initialIndex: DateTime.now().weekday % 7,
      vsync: this,
    );
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        TabBar(
          controller: _controller,
          isScrollable: size.width < 600 ? true : false,
          tabs: widget.timetable.map((el) {
            return Tab(text: el.day.day.toLowerCase().substring(0, 3));
          }).toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _controller,
            children: widget.timetable.map((el) {
              return _DayPanel(day: el.day, sessions: el.session);
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 10,
            children: [
              // Break Day Toggle Switch
              StreamBuilder<bool>(
                stream: _breakDayStream(widget.timetable[_controller.index].day.id),
                builder: (context, snapshot) {
                  final isBreakDay = snapshot.data ?? false;
                  return Row(
                    children: [
                      Text('Break Day'),
                      SizedBox(width: 8),
                      Switch(
                        value: isBreakDay,
                        onChanged: (value) async {
                          await Timetabletodb().toggleBreakDay(
                            widget.timetable[_controller.index].day.id,
                          );
                          setState(() {});
                        },
                      ),
                    ],
                  );
                },
              ),
              ElevatedButton.icon(
                onPressed: widget.timetable[_controller.index].day.isBreakDay ? null : () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return _AddSessionForm(
                        dayId: widget.timetable[_controller.index].day.id,
                      );
                    },
                  );
                },
                icon: Icon(Icons.add),
                label: Text("Add Session"),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                await Timetabletodb().deleteTimetable();
                },
                icon: Icon(Icons.delete),
                label: Text("Delete Timetable"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Stream<bool> _breakDayStream(int dayId) {
    return Timetabletodb().getTimeTable().map((timetables) {
      final day = timetables.firstWhere(
        (t) => t.day.id == dayId,
        orElse: () => TimeTable(day: TimetableDay(id: 0, day: '', isBreakDay: false), session: []),
      );
      return day.day.isBreakDay;
    });
  }
}

class _DayPanel extends StatelessWidget {
  final TimetableDay day;
  final List<TimetableSession> sessions;

  const _DayPanel({required this.day, required this.sessions});

  @override
  Widget build(BuildContext context) {
    if (day.isBreakDay) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.beach_access, size: 64, color: Theme.of(context).colorScheme.primary),
            SizedBox(height: 16),
            Text(
              'Break day — no sessions scheduled',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return _SessionCard(session: session, index: index);
      },
    );
  }
}

class _SessionCard extends StatelessWidget {
  final TimetableSession session;
  final int index;

  const _SessionCard({required this.session, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 3,
          ),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Session ${index + 1} · ${session.start} – ${session.end}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                if (session.subjects.isEmpty)
                  const Text('No subjects assigned')
                else
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: session.subjects
                        .split(',')
                        .map((subject) => _SubjectPill(subject: subject))
                        .toList(),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return _EditSessionForm(
                          sessionId: session.id,
                          session: session,
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.edit),
                  label: Text("Edit"),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Timetabletodb().deleteSession(session.id);
                  },
                  icon: Icon(Icons.delete),
                  label: Text("Delete"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectPill extends StatelessWidget {
  final String subject;

  const _SubjectPill({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        subject,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

// Forms
class _AddSessionForm extends StatefulWidget {
  _AddSessionForm({required this.dayId});
  final int dayId;

  @override
  State<_AddSessionForm> createState() => _SessionFormState();
}

class _SessionFormState extends State<_AddSessionForm> {
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
                  await Timetabletodb().addSession(
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

class _EditSessionForm extends StatefulWidget {
  _EditSessionForm({
    required this.sessionId,
    required this.session,
  });

  final int sessionId;
  final TimetableSession session;

  @override
  State<_EditSessionForm> createState() => __EditSessionFormState();
}

class __EditSessionFormState extends State<_EditSessionForm> {
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
                  await Timetabletodb().editSession(
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
