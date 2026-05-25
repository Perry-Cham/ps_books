import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:ps_books/state/pomodoro_timer.dart';
import '';


class Pomodoro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text("Timer"),
     ),
     body: Page(),
   );
  }

}
class Page extends ConsumerStatefulWidget{

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    // TODO: implement createState
    return PageState();
  }
}

class PageState extends ConsumerState<Page>{
  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(pomodoroProvider);
    return Column(
      children: [
        ElevatedButton(onPressed: () async {
          final data = await showDialog(context: context, builder: (_){
            return PomodoroForm();
          });
          if(data != null){
            ref.read(pomodoroProvider.notifier).init(data['workTime'], data['breakTime'], data['cycles']);
          }
        }, child: Text("Set Up Timer")),

      ],
    );
  }
}

class PomodoroForm extends StatefulWidget {
  const PomodoroForm({super.key});

  @override
  State<PomodoroForm> createState() => _PomodoroFormState();
}

class _PomodoroFormState extends State<PomodoroForm> {
  late TextEditingController cycles;
  late TextEditingController work_period;
  late TextEditingController break_period;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Set Up Timer'),
        content: Column(
        children: [
          TextFormField(
            controller: work_period,
            decoration: InputDecoration(
              hint: Text('40',),
              label: Text('Work Time')
            ),
          ),
          SizedBox(height: 10,),
          TextFormField(
            controller: break_period,
            decoration: InputDecoration(
                hint: Text('20',),
                label: Text('Break Time')
            ),
          ),
          SizedBox(height: 10,),
          TextFormField(
            controller: cycles,
            decoration: InputDecoration(
                hint: Text('3',),
                label: Text('Cycles')
            ),
          ),
          SizedBox(height: 15,),
          Row(
            children: [
              ElevatedButton(onPressed: (){
                Navigator.pop(context, null);
              }, child: Text('Cancel')),
              ElevatedButton(onPressed: (){
                final data = {
                  "workTime":work_period.text,
                  "breakTime":break_period.text,
                  "cycles":cycles.text
                };
                Navigator.pop(context,data);
              }, child: Text('Submit'))
            ],
          )
        ],
      ),
    );
  }
}
