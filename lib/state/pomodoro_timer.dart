import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PomodoroPhase { work, breakTime }

class PomodoroState {
  final int secondsRemaining;
  final bool isRunning;
  final PomodoroPhase phase;
  final int currentCycle;
  final int workDuration;
  final int breakDuration;
  final int cycles;


  const PomodoroState({
    required this.secondsRemaining,
    required this.isRunning,
    required this.phase,
    required this.currentCycle,
    required this.workDuration,
    required this.breakDuration,
    required this.cycles,
  });

  // Ideal default initial state
  factory PomodoroState.initial(int workDuration) {
    return PomodoroState(
      secondsRemaining: workDuration,
      isRunning: false,
      phase: PomodoroPhase.work,
      currentCycle: 1,
      workDuration: 40,
      breakDuration: 20,
      cycles: 3,
    );
  }

  PomodoroState copyWith({
    int? secondsRemaining,
    bool? isRunning,
    PomodoroPhase? phase,
    int? currentCycle,
    int? workDuration,
    int? breakDuration,
    int? cycles,
  }) {
    return PomodoroState(
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      isRunning: isRunning ?? this.isRunning,
      phase: phase ?? this.phase,
      currentCycle: currentCycle ?? this.currentCycle,
      workDuration: workDuration ?? this.workDuration,
      breakDuration: breakDuration ?? this.breakDuration,
      cycles: cycles ?? this.cycles,
    );
  }
}

class PomodoroNotifier extends Notifier<PomodoroState> {
  Timer? _timer;

  // Configurations
  static const int workDuration = 25 * 60; // 25 minutes in seconds
  static const int breakDuration = 5 * 60; // 5 minutes in seconds

  @override
  PomodoroState build() {
    // Automatically close any active timers when this provider is destroyed
    ref.onDispose(() => _timer?.cancel());
    return PomodoroState.initial(workDuration);
  }

  void init(int workDuration, int breakDuration, int cycles){
    if (state.isRunning) return;

    state = state.copyWith(workDuration:workDuration * 60, breakDuration: breakDuration * 60, cycles:cycles);
  }

  void start() {
    if (state.isRunning) return;

    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void resume() {
    start();
  }

  void reset() {
    _timer?.cancel();
    state = PomodoroState.initial(workDuration);
  }

  void _tick() {
    if (state.secondsRemaining > 1) {
      state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
    } else {
      _handlePhaseTransition();
    }
  }

  void _handlePhaseTransition() {
    _timer?.cancel();

    if (state.phase == PomodoroPhase.work) {
      // Transitioning from Work to Break
      state = state.copyWith(
        phase: PomodoroPhase.breakTime,
        secondsRemaining: breakDuration,
        isRunning: false,
      );
    } else {
      // Transitioning from Break to Next Work Cycle
      state = state.copyWith(
        phase: PomodoroPhase.work,
        secondsRemaining: workDuration,
        currentCycle: state.currentCycle + 1,
        isRunning: false,
      );
    }

    // Optional: Auto-start the next phase immediately if desired:
    // start();
  }
}

// Expose the global provider
final pomodoroProvider =
    NotifierProvider.autoDispose<PomodoroNotifier, PomodoroState>(
      PomodoroNotifier.new,
    );
