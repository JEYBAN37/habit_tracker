import 'package:flutter/material.dart';
import 'package:habit_tracker/components/homeTracker.dart';

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const HomeTracker(title: 'Habit Tracker'),
    );
  }
}
