import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:pertolo/app.dart';
import 'package:pertolo/categories_screen.dart';
import 'package:pertolo/screen_container.dart';

class GameScreen extends StatelessWidget {
  final String category;
  final List<String> players;
  const GameScreen({super.key, required this.category, required this.players});

  String _getContentFromDoc(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return data["content"];
  }

  Future<List<String>?> _loadTasks() async {
    try {
      List<String> categoryTasks = [];
      if (category != "normal") {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('game')
            .doc(category)
            .collection("task")
            .get();
        categoryTasks =
            snapshot.docs.map((doc) => _getContentFromDoc(doc)).toList();
      }
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('game')
          .doc("normal")
          .collection("task")
          .get();
      List<String> normalTasks =
          snapshot.docs.map((doc) => _getContentFromDoc(doc)).toList();

      normalTasks.addAll(categoryTasks);
      return normalTasks;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
        child: FutureBuilder(
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data == null) {
                  return const Center(
                      child: Text(
                    "Could not load tasks",
                    style: TextStyle(
                      color: App.secondaryColor,
                      decoration: TextDecoration.none,
                      fontSize: 24,
                    ),
                  ));
                }
                return Game(tasks: snapshot.data, players: players);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
            future: _loadTasks()));
  }
}

class Game extends StatefulWidget {
  final List<String> tasks;
  final List<String> players;
  const Game({super.key, required this.tasks, required this.players});

  @override
  State<Game> createState() => GameState();
}

class GameState extends State<Game> {
  late List<String> tasks;
  String currentTask = "Tap to play!";
  @override
  void initState() {
    super.initState();
    tasks = widget.tasks;
    setLandscape();
    //TODO: filer tasks with two character '_'
  }

  Future setLandscape() async {
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  String getNextTask() {
    //get random task
    String task = getRandomTask();
    //replace '_' with random player
    while (task.contains("_")) {
      String player = getRandomPlayer();
      for (int i = 0; i < 10; i++) {
        if (task.contains(player)) {
          player = getRandomPlayer();
        }
      }
      task = task.replaceFirst("_", player);
    }
    return task;
  }

  String getRandomTask() {
    if (tasks.isEmpty) {
      return "No more tasks";
    }
    int index = Random().nextInt(tasks.length);
    String task = tasks[index];
    tasks.removeAt(index);
    return task;
  }

  String getRandomPlayer() {
    return widget.players[Random().nextInt(widget.players.length)];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          String nextTask = getNextTask();
          setState(() {
            currentTask = nextTask;
          });
        },
        child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
                child: Text(
              currentTask,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: App.secondaryColor,
                decoration: TextDecoration.none,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ))));
  }
}
