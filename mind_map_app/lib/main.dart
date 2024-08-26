import 'package:flutter/material.dart';

import 'package:flutter_vicr_widgets/flutter_vicr_widgets.dart';

void main() {
  
  VictMaterialApp().loadSettings();
  runApp(
    VictMaterialApp(
      routes: {
        '/': (context) => MainApp(),
      }
    )
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () => Navigator.pushNamed(context, '/configs'),
        ),
      ],),
      body: Center(
        child: Text("Hello World!")
      ),
    );
  }
}
