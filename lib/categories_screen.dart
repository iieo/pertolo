import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pertolo/app.dart';
import 'package:pertolo/screen_container.dart';

class CategoriesScreen extends StatefulWidget {
  final List<String> players;
  const CategoriesScreen({super.key, required this.players});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  Future<List<String>?> _loadCategories() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('game').get();
      return snapshot.docs.map((doc) => doc.id).toList();
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
                    "Could not load categories",
                    style: TextStyle(
                      color: App.secondaryColor,
                      decoration: TextDecoration.none,
                      fontSize: 24,
                    ),
                  ));
                }
                return CategoriesList(
                    categories: snapshot.data, players: widget.players);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
            future: _loadCategories()));
  }
}

class CategoriesList extends StatelessWidget {
  final List<String> categories;
  final List<String> players;
  const CategoriesList(
      {super.key, required this.categories, required this.players});

  @override
  Widget build(BuildContext context) {
    double width = max(200, MediaQuery.of(context).size.width - 100);

    return SizedBox(
        width: width,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: categories.length,
          physics: const ClampingScrollPhysics(),
          itemBuilder: ((context, index) => ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                tileColor: App.secondaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                title: Text(
                  categories[index],
                  style: const TextStyle(
                    color: App.whiteColor,
                    fontSize: 18,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: App.whiteColor,
                ),
                onTap: () => GoRouter.of(context).goNamed('game', queryParams: {
                  'category': categories[index],
                  'players': players.join(',')
                }),
              )),
          separatorBuilder: ((context, index) => const Divider(
                color: App.whiteColor,
                height: 30,
              )),
        ));
  }
}
