import 'package:flutter/material.dart';
import 'package:pertolo/app.dart';

class ScreenContainer extends StatelessWidget {
  final Widget child;
  const ScreenContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: App.primaryColor,
        body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
            child: child));
  }
}
