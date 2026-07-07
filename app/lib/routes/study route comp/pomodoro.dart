import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ps_books/state/pomodoro_timer.dart';


class Pomodoro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text("Study Timer"),
     ),
     body: Page(),
   );
  }

}
class Page extends ConsumerStatefulWidget{

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return PageState();
  }
}

class PageState extends ConsumerState<Page>{
  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(pomodoroProvider);
    final notifier = ref.read(pomodoroProvider.notifier);

    String formatDuration(int seconds) {
      final minutes = (seconds / 60).floor();
      final remainingSeconds = seconds % 60;
      return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            timerState.phase == PomodoroPhase.work ? "Focus Time" : "Break Time",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: timerState.phase == PomodoroPhase.work ? Colors.redAccent : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 250,
                height: 250,
                child: CircularProgressIndicator(
                  value: timerState.secondsRemaining / 
                    (timerState.phase == PomodoroPhase.work ? timerState.workDuration : timerState.breakDuration),
                  strokeWidth: 10,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    timerState.phase == PomodoroPhase.work ? Colors.redAccent : Colors.green
                  ),
                ),
              ),
              Text(
                formatDuration(timerState.secondsRemaining),
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            "Cycle ${timerState.currentCycle} of ${timerState.cycles}",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: () => notifier.reset(),
                icon: const Icon(Icons.refresh, size: 32),
                tooltip: "Reset",
              ),
              const SizedBox(width: 20),
              FloatingActionButton.large(
                onPressed: () {
                  if (timerState.isRunning) {
                    notifier.pause();
                  } else {
                    notifier.start();
                  }
                },
                child: Icon(timerState.isRunning ? Icons.pause : Icons.play_arrow, size: 48),
              ),
              const SizedBox(width: 20),
              IconButton.filledTonal(
                onPressed: () async {
                   final data = await showDialog(context: context, builder: (_){
                    return PomodoroForm();
                  });
                  if(data != null){
                    notifier.init(
                      int.parse(data['workTime']), 
                      int.parse(data['breakTime']), 
                      int.parse(data['cycles'])
                    );
                  }
                },
                icon: const Icon(Icons.settings, size: 32),
                tooltip: "Settings",
              ),
            ],
          ),
        ],
      ),
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
  void initState() {
    super.initState();
    cycles = TextEditingController(text: '3');
    work_period = TextEditingController(text: '25');
    break_period = TextEditingController(text: '5');
  }

  @override
  void dispose() {
    cycles.dispose();
    work_period.dispose();
    break_period.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Up Timer'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: work_period,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '25',
                labelText: 'Work Time (minutes)'
              ),
            ),
            const SizedBox(height: 10,),
            TextFormField(
              controller: break_period,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '5',
                labelText: 'Break Time (minutes)'
              ),
            ),
            const SizedBox(height: 10,),
            TextFormField(
              controller: cycles,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '3',
                labelText: 'Cycles'
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null), 
          child: const Text('Cancel')
        ),
        ElevatedButton(
          onPressed: () {
            final data = {
              "workTime": work_period.text,
              "breakTime": break_period.text,
              "cycles": cycles.text
            };
            Navigator.pop(context, data);
          }, 
          child: const Text('Submit')
        )
      ],
    );
  }
}
