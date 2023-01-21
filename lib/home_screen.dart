import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pertolo/app.dart';

import 'package:pertolo/components/pertolo_button.dart';
import 'package:pertolo/screen_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> players = [];

  @override
  Widget build(BuildContext context) {
    String textFieldValue = '';
    double width = max(200, MediaQuery.of(context).size.width - 100);
    double height = 60;

    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return ScreenContainer(
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Players',
            style: TextStyle(
              color: App.whiteColor,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: players.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(
                    players[index],
                    style: const TextStyle(
                      color: App.whiteColor,
                      fontSize: 18,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: App.whiteColor,
                    ),
                    onPressed: () {
                      setState(() {
                        players.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          SafeArea(
              child: SizedBox(
                  width: width,
                  height: height,
                  child: TextField(
                    style: const TextStyle(
                      color: App.whiteColor,
                      fontSize: 18,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Spieler hinzufügen',
                      hintStyle: TextStyle(
                        color: App.whiteColor,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: App.whiteColor,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: App.whiteColor,
                        ),
                      ),
                    ),
                    controller: TextEditingController(text: textFieldValue),
                    onSubmitted: (String value) {
                      setState(() {
                        players.add(value);
                        textFieldValue = '';
                      });
                    },
                  ))),
          const SizedBox(height: 24),
          PertoloButton(
            onPressed: () =>
                GoRouter.of(context).goNamed('categories', queryParams: {
              'players': players.join(","),
            }),
            text: 'Spielen!',
          ),
        ],
      )),
    );
  }
}
