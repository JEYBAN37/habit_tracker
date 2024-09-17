import 'package:flutter/material.dart';
import 'package:habit_tracker/components/homePageState.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomeTracker extends StatefulWidget {
  const HomeTracker({super.key, required this.title});
  final String title;

  @override
  State<HomeTracker> createState() => HomePageState();
}
