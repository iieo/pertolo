import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pertolo/app.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:ota_update/ota_update.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //checkOs
  if (kIsWeb) {
    runApp(App());
  } else {
    runApp(const OTAUpdate());
  }
}

class OTAUpdate extends StatefulWidget {
  const OTAUpdate({super.key});

  @override
  State<OTAUpdate> createState() => _OTAUpdateState();
}

class _OTAUpdateState extends State<OTAUpdate> {
  OtaEvent? currentEvent;

  @override
  void initState() {
    super.initState();
    tryOtaUpdate();
  }

  Future<bool> _isUpToDate() async {
    final res = await http.get(
        Uri.parse('https://pertolo-f3c7a.web.app/config_pertolo.json'),
        headers: {
          "Accept": "application/json",
        });

    if (res.statusCode != 200) {
      return true;
    }

    //parse json
    Map<String, dynamic> json = jsonDecode(res.body);
    String version = json['version'];

    //get current version
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;
    return !isCurrentVersionOlder(currentVersion, version);
  }

  bool isCurrentVersionOlder(String currentVersion, String newVersion) {
    List<String> currentVersionParts = currentVersion.split('.');
    List<String> newVersionParts = newVersion.split('.');

    for (int i = 0; i < currentVersionParts.length; i++) {
      int currentVersionPart = int.parse(currentVersionParts[i]);
      int newVersionPart = int.parse(newVersionParts[i]);

      if (currentVersionPart < newVersionPart) {
        return true;
      } else if (currentVersionPart > newVersionPart) {
        return false;
      }
    }
    return false;
  }

  Future<void> tryOtaUpdate() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (!result.isNotEmpty || !result[0].rawAddress.isNotEmpty) {
        return;
      }
    } on SocketException catch (_) {
      return;
    }
    try {
      if (await _isUpToDate()) {
        setState(() {
          currentEvent = OtaEvent(OtaStatus.INSTALLING, "No update available");
        });
        return;
      }

      //LINK CONTAINS APK OF FLUTTER HELLO WORLD FROM FLUTTER SDK EXAMPLES
      OtaUpdate()
          .execute(
        'https://pertolo-f3c7a.web.app/pertolo.apk',
        destinationFilename: 'pertolo.apk',
        //FOR NOW ANDROID ONLY - ABILITY TO VALIDATE CHECKSUM OF FILE:
        //sha256checksum:
        //  'd6da28451a1e15cf7a75f2c3f151befad3b80ad0bb232ab15c20897e54f21478',
      )
          .listen(
        (OtaEvent event) {
          setState(() => currentEvent = event);
        },
      );
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      print('Failed to make OTA update. Details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentEvent == null) {
      return Container();
    }
    if (currentEvent!.status == OtaStatus.DOWNLOADING) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: App.primaryColor,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Downloading update: ${currentEvent!.value}%',
                    style: const TextStyle(color: App.whiteColor)),
                const SizedBox(height: 20),
                //LinearProgressIndicator(value: currentEvent!.value / 100),
              ],
            ),
          ),
        ),
      );
    }
    return App();
  }
}
