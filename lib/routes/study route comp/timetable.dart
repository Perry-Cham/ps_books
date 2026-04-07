import 'package:flutter/material.dart';
import 'package:ps_books/services/timetableToDB.dart';

class TimeTableForm extends StatefulWidget {
  @override
  State<TimeTableForm> createState() => TimeTableFormState();
}

class TimeTableFormState extends State<TimeTableForm> {
  final days = [
    "sunday",
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
  ];
  List<Day> Days = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      Days = days.map((d) => Day(day: d)).toList();
    });
  }

  // equivalent of your updateTimetableDayData function
  void _toggleBreak(int dayIndex, bool value) {
    setState(() {
      print("${Days[dayIndex].isBreak}, ${value}");
      Days[dayIndex].isBreak = value;
    });
  }

  // equivalent of your numSessions onChange
  void _setSessionCount(int dayIndex, int count) {
    setState(() {
      final current = Days[dayIndex].sessions;
      if (count > current.length) {
        // add new empty sessions
        final toAdd = count - current.length;
        for (int i = 0; i < toAdd; i++) {
          current.add(Session());
        }
      } else {
        // remove sessions from the end
        Days[dayIndex].sessions = current.take(count).toList();
      }
    });
    print(Days);
  }

  // equivalent of your updateSessionField function
  void _updateSession(
    int dayIndex,
    int sessionIndex, {
    String? start,
    String? end,
    String? subjects,
  }) {
    setState(() {
      final session = Days[dayIndex].sessions[sessionIndex];
      if (start != null) session.start = start;
      if (end != null) session.end = end;
      if (subjects != null) {
        session.subjects = subjects.split(',').map((s) => s.trim()).toList();
      }
    });
    print(Days);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AlertDialog(
      title: Text('Timetable'),
      content: Container(
        width: 500,
        child: ListView.builder(
          itemBuilder: (context, index) {
            print(index);
            if (index < Days.length) {
              return DayWidget(
                data: Days[index],
                index: index,
                toggleBreak: (value) {
                  _toggleBreak(index, value);
                },
                sessionNumberChange: (int index, int count) =>
                    _setSessionCount(index, count),
                onSessionUpdate:
                    (
                      int sessionIndex, {
                      String? start,
                      String? end,
                      String? subjects,
                    }) {
                      _updateSession(
                        index,
                        sessionIndex,
                        start: start,
                        end: end,
                        subjects: subjects,
                      );
                    },
              );
            }
          },
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            await Timetabletodb().insertTimetable(Days);
           // print(Days[0].sessions[0].subjects[0]);
            Navigator.pop(context);
          },
          child: Text("submit"),
        ),
      ],
    );
  }
}

class DayWidget extends StatelessWidget {
  DayWidget({
    super.key,
    required this.data,
    required this.index,
    required this.sessionNumberChange,
    required this.onSessionUpdate,
    required this.toggleBreak,
  });

  final Day data;
  final int index;
  final void Function(int index, int count) sessionNumberChange;
  final void Function(bool value) toggleBreak;
  final void Function(
    int sessionIndex, {
    String? start,
    String? end,
    String? subjects,
  })
  onSessionUpdate;

  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      child: Column(
        children: [
          Text(data.day),
          Switch(value: data.isBreak, onChanged:(value) => toggleBreak(value)),
          Text("Number of sessions for the day"),
          data.isBreak ? Text('The day is a Break Day no studying'): TextField(
            onChanged: (value) => sessionNumberChange(index, int.parse(value)),
          ),
          ...List.generate(data.sessions.length, (index) {
            Session el = data.sessions[index];
            return SessionWidget(
              session: el,
              index: index,
              onSessionUpdate: ({end, start, subjects}) {
                onSessionUpdate(
                  index,
                  end: end,
                  start: start,
                  subjects: subjects,
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

class SessionWidget extends StatelessWidget {
  SessionWidget({
    super.key,
    required this.session,
    required this.index,
    required this.onSessionUpdate,
  });
  final Session session;
  final int index;
  final void Function({String? start, String? end, String? subjects})
  onSessionUpdate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Session ${index + 1}',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),

        // start time
        TextFormField(
          initialValue: session.start,
          decoration: const InputDecoration(labelText: 'Start time'),
          onChanged: (val) => onSessionUpdate(start: val),
        ),
        const SizedBox(height: 8),

        // end time
        TextFormField(
          initialValue: session.end,
          decoration: const InputDecoration(labelText: 'End time'),
          onChanged: (val) => onSessionUpdate(end: val),
        ),
        const SizedBox(height: 8),

        // subjects — comma separated same as your web version
        TextFormField(
          initialValue: session.subjects.join(', '),
          decoration: const InputDecoration(
            labelText: 'Subjects',
            hintText: 'Mathematics, Physics',
          ),
          onChanged: (val) => onSessionUpdate(subjects: val),
        ),
      ],
    );
  }
}

class Day {
  Day({required this.day});

  final String day;
  bool isBreak = false;
  int numberOfSessions = 2;
  List<Session> sessions = [];
}

class Session {
  Session({this.start, this.end});
  String? start;
  String? end;
  List<String> subjects = [];
}
