import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_node.dart';
import '../providers/gamification_provider.dart';

class PomodoroScreen extends ConsumerStatefulWidget {
  final TodoNode taskNode;

  const PomodoroScreen({super.key, required this.taskNode});

  @override
  ConsumerState<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends ConsumerState<PomodoroScreen> {
  static const int focusDurationMinutes = 25;
  int _secondsRemaining = focusDurationMinutes * 60;
  Timer? _timer;
  bool _isRunning = false;
  bool _isFinished = false;

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _completeTimer();
      }
    });
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
    });
    _timer?.cancel();
  }

  void _completeTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isFinished = true;
    });
    // Award XP for completing a focus session
    ref.read(gamificationProvider.notifier).addXP(50);
    ref.read(gamificationProvider.notifier).updateStreak();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Mode'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Focusing on:',
              style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColor.withOpacity(0.7)),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.taskNode.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 60),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 250,
                  height: 250,
                  child: CircularProgressIndicator(
                    value: _secondsRemaining / (focusDurationMinutes * 60),
                    strokeWidth: 12,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    color: _isFinished ? Colors.green : Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  _isFinished ? 'Done!' : _formattedTime,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: _isFinished ? Colors.green : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            if (!_isFinished) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton.large(
                    heroTag: 'play_pause',
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    onPressed: _isRunning ? _pauseTimer : _startTimer,
                    child: Icon(
                      _isRunning ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 20),
                  FloatingActionButton(
                    heroTag: 'stop',
                    backgroundColor: Colors.redAccent,
                    onPressed: () {
                      _pauseTimer();
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.stop, color: Colors.white),
                  ),
                ],
              ),
            ] else ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Collect 50 XP & Return',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
