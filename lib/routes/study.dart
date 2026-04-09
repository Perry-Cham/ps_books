import 'package:flutter/material.dart';
import 'package:ps_books/routes/study%20route%20comp/display.dart';
import 'package:ps_books/routes/study%20route%20comp/targets.dart';
import './study route comp/timetable.dart';

//Finish session logic

class StudyPage extends StatelessWidget {
  const StudyPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text('Study Page')),
      body: Page(),
    );
  }
}

class Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [Expanded(child: _TabbedPage())]);
  }
}

class _TabbedPage extends StatefulWidget {
  const _TabbedPage({super.key});

  @override
  State<_TabbedPage> createState() => _TabbedPageState();
}

class _TabbedPageState extends State<_TabbedPage>
    with TickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _controller,
          tabs: [
            Tab(text: "Timetable"),
            Tab(text: "Targets"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _controller,
            children: [TimetableDisplay(), Targets()],
          ),
        ),
      ],
    );
  }
}
