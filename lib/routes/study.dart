import 'package:flutter/material.dart';
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
    return Column(
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return TimeTableForm();
                  },
                );
              },
              child: Row(
                children: [
                  Icon(Icons.add),
                  Text('Create a new timetable')
                ],
              ),
            ),
          ],
        ),
        Container(child: Text('To be continued')),
      ],
    );
  }
}
