import 'package:flutter/material.dart';
import 'package:flutter_vicr_widgets/flutter_vicr_widgets.dart';
import 'package:mind_map_app/data/nodes_data_service.dart';
import 'package:mind_map_app/screens/graph_screen.dart';
import 'package:mind_map_app/screens/mindmap_list_screen.dart';

void main() {
  
  VicrMaterialApp.staticLoadSettings();
  nodesDataService.loadMindMaps();
  runApp(
    VicrMaterialApp(
      configWidget: ConfigWidgets(),
      materialApp: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (context) => MindMapListScreen(),
          '/graphScreen': (context) => GraphScreen()
        }
      ),
    )
  );
}


