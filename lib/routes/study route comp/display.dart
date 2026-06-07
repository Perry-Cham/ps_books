import 'package:flutter/material.dart';
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/routes/study%20route%20comp/pomodoro.dart';
import 'package:ps_books/routes/study%20route%20comp/timetable.dart';
import 'package:ps_books/services/DB%20services/timetableToDB.dart';
import 'package:ps_books/routes/study route comp/forms.dart';

class TimetableDisplay extends StatelessWidget {
  const TimetableDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return StreamBuilder(
      stream: TimetableToDb().getTimeTable(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          print(snapshot.error);
          return Center(
            child: Text("You haven't created any study TimeTables Yet"),
          );
        }

        //Rework this logic to add error handling
        final data = snapshot.data;
        if (data == null || data.isEmpty) {
          return Stack(
            children: [

                Center(
                  child: Text("You haven't created any study TimeTables Yet"),
                ),

              Positioned(
                bottom: 10,
                right:10,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton.filled(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Pomodoro()),
                        );
                      },
                      icon: Icon(Icons.timer),
                    ),

                    IconButton.filled(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return TimeTableForm();
                          },
                        );
                      },
                      icon: Icon(Icons.add),

                    ),
                  ],
                ),
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
  const Display({super.key, required this.timetable});

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
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;

    Widget content = Column(
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
        if (!isAndroid)
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 10,
                  children: [
                    // Break Day Toggle Switch
                    Row(
                      children: [
                        Text('Break Day'),
                        SizedBox(width: 8),
                        Switch(
                          value: widget
                              .timetable[_controller.index]
                              .day
                              .isBreakDay,
                          onChanged: (value) async {
                            await TimetableToDb().toggleBreakDay(
                              widget.timetable[_controller.index].day.id,
                            );
                          },
                        ),
                      ],
                    ),

                    ElevatedButton.icon(
                      onPressed:
                          widget.timetable[_controller.index].day.isBreakDay
                          ? null
                          : () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AddSessionForm(
                                    dayId: widget
                                        .timetable[_controller.index]
                                        .day
                                        .id,
                                  );
                                },
                              );
                            },
                      icon: Icon(Icons.add),
                      label: Text("Add Session"),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Pomodoro()),
                        );
                      },
                      icon: Icon(Icons.timer),
                      label: Text("Study Timer"),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await TimetableToDb().deleteTimetable();
                      },
                      icon: Icon(Icons.delete),
                      label: Text("Delete Timetable"),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );

    if (isAndroid) {
      return Scaffold(
        appBar: AppBar(
          actions: [
            ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                return _TimetableAndroidMenu(
                  timetable: widget.timetable,
                  controller: _controller,
                );
              },
            ),
          ],
        ),
        body: content,
      );
    }

    return content;
  }
}

class _TimetableAndroidMenu extends StatefulWidget {
  _TimetableAndroidMenu({required this.timetable, required this.controller});

  final List<TimeTable> timetable;
  final TabController controller;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TimetableAndroidMenuState();
  }
}

class _TimetableAndroidMenuState extends State<_TimetableAndroidMenu> {
  @override
  Widget build(BuildContext context) {
    final currentDayId = widget.timetable[widget.controller.index].day.id;
    final isBreakDay = widget.timetable[widget.controller.index].day.isBreakDay;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) async {
        if (value == 'add') {
          showDialog(
            context: context,
            builder: (context) => AddSessionForm(dayId: currentDayId),
          );
        } else if (value == 'delete') {
          await TimetableToDb().deleteTimetable();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: StreamBuilder<bool>(
            stream: TimetableToDb().getTimeTable().map((timetables) {
              final day = timetables.firstWhere(
                (t) => t.day.id == currentDayId,
                orElse: () => TimeTable(
                  day: TimetableDay(id: 0, day: '', isBreakDay: false),
                  session: [],
                ),
              );
              return day.day.isBreakDay;
            }),
            builder: (context, snapshot) {
              final breakDay = snapshot.data ?? isBreakDay;
              return Row(
                children: [
                  const Text('Break Day'),
                  const Spacer(),
                  Switch(
                    value: breakDay,
                    onChanged: (value) async {
                      await TimetableToDb().toggleBreakDay(currentDayId);
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          ),
        ),
        PopupMenuItem(
          value: 'add',
          enabled: !isBreakDay,
          child: const Row(
            children: [
              Icon(Icons.add),
              SizedBox(width: 8),
              Text("Add Session"),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete),
              SizedBox(width: 8),
              Text("Delete Timetable"),
            ],
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.beach_access,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 16),
            Text(
              'Break day — no sessions scheduled',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 16),
            Text(
              'No sessions added yet - Add a new one',
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
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                        return EditSessionForm(
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
                    await TimetableToDb().deleteSession(session.id);
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
