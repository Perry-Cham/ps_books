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
  List<TimeTable> timetable;

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
      ],
    );
  }
}

class _DayPanel extends StatelessWidget {
  final TimetableDay day;
  final List<TimetableSession> sessions;

  const _DayPanel({required this.day, required this.sessions});

  @override
  Widget build(BuildContext context) {
    if (day.isBreakDay) {
      return const Center(child: Text('Break day — no sessions scheduled'));
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
