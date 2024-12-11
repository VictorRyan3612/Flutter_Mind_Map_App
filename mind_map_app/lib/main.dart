import 'package:flutter/material.dart';
import 'package:flutter_vicr_widgets/flutter_vicr_widgets.dart';
import 'package:mind_map_app/data/nodes_data_service.dart';
import 'package:mind_map_app/screens/graph_screen.dart';

void main() {
  
  VicrMaterialApp.staticLoadSettings();
  nodesDataService.loadMindMaps();
  runApp(
    VicrMaterialApp(
      configWidget: ConfigWidgets(),
      materialApp: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (context) => MainApp(),
        }
      ),
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
          onPressed: (){
            if(nodesDataService.mindMap.value != null){
              nodesDataService.saveMindMap(nodesDataService.mindMap.value!);
            }
          }, 
          icon: Icon(Icons.add)
        ),
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () => Navigator.pushNamed(context, '/configs'),
        ),
      ],),
      body: GraphScreen()
    );
  }
}
