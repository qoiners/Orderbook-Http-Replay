import 'package:flutter/material.dart';
import 'package:orderbook_replay_flutter/screens/main_screen.dart';

import 'global_variables.dart';

void main() {
  // setPathUrlStrategy();
  String baseUrl = Uri.base.origin.toString();
  String? paramFromTs = Uri.base.queryParameters["from_ts"];
  String? paramToTs = Uri.base.queryParameters["to_ts"];
  String? paramTicker = Uri.base.queryParameters["ticker"];

  kBaseUrl = baseUrl;
  if (paramFromTs != null) {
    kFromTimestamp = int.parse(paramFromTs);
  }
  if (paramToTs != null) {
    kToTimestamp = int.parse(paramToTs);
  }
  if (paramTicker != null) {
    kTicker = paramTicker;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
