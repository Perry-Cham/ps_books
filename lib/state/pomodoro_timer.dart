import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ps_books/services/audio_player.dart';
import 'package:ps_books/services/notifications.dart';
import 'package:ps_books/state/reader_state.dart';

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
  factory PomodoroState.initial(int? workDuration) {
    return PomodoroState(
      secondsRemaining: workDuration ?? 40 * 60,
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
  final Notifications _notifications = Notifications();
  final AudioPlayerService _audioPlayer = AudioPlayerService();


  @override
  PomodoroState build() {
    // Automatically close any active timers when this provider is destroyed
    ref.onDispose(() {
      _timer?.cancel();
      _notifications.cancelOngoing();
      _audioPlayer.dispose();
    });
    _notifications.init();
    return PomodoroState.initial(null);
  }

  void init(int workDuration, int breakDuration, int cycles){
    if (state.isRunning) return;

    state = state.copyWith(
        workDuration: workDuration,
        breakDuration: breakDuration,
        cycles: cycles,
        currentCycle: 1,
        phase: PomodoroPhase.work,
        isRunning: false,
        secondsRemaining: workDuration * 60,
    );
  }

  void start() {
    if (state.isRunning) return;

    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _notifications.updateOngoing(state);
    ref.read(readerStateProvider.notifier).setShowPomodoroTrue();
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
    _notifications.updateOngoing(state);
  }

  void resume() {
    start();
  }

  void reset() {
    _timer?.cancel();
    _notifications.cancelOngoing();
    state = PomodoroState.initial(state.workDuration * 60);
  }

  void _tick() {
    if (state.secondsRemaining > 0) {
      state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
      _notifications.updateOngoing(state);
    } else {
      _handlePhaseTransition();
    }
  }

  void _handlePhaseTransition() {
    _timer?.cancel();
    final previousPhase = state.phase;
    _audioPlayer.playNotification();

    if (state.phase == PomodoroPhase.work) {
      // Transitioning from Work to Break
      state = state.copyWith(
        phase: PomodoroPhase.breakTime,
        secondsRemaining: state.breakDuration,
        isRunning: false,
      );
      _notifications.showPhaseTransition(previous: previousPhase, next: PomodoroPhase.breakTime);
    } else {
      // Transitioning from Break to Next Work Cycle
      if (state.currentCycle >= state.cycles) {
        // All cycles completed
        state = state.copyWith(
          isRunning: false,
          secondsRemaining: 0,
        );
        _notifications.cancelOngoing();
        _notifications.showSessionComplete();
        ref.read(readerStateProvider.notifier).setShowPomodoroFalse;
        return;
      }

      state = state.copyWith(
        phase: PomodoroPhase.work,
        secondsRemaining: state.workDuration,
        currentCycle: state.currentCycle + 1,
        isRunning: false,
      );
      _notifications.showPhaseTransition(previous: previousPhase, next: PomodoroPhase.work);
    }
    
    _notifications.updateOngoing(state);
  }
}

// Expose the global provider
final pomodoroProvider =
    NotifierProvider<PomodoroNotifier, PomodoroState>(
      PomodoroNotifier.new,
    );
