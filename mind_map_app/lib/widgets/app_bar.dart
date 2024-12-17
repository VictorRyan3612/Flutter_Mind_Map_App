import 'package:flutter/material.dart';
import 'package:mind_map_app/data/nodes_data_service.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget{
  String title;
  bool modeMindMap;
  MyAppBar({super.key, this.title ='', required this.modeMindMap});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    List<Widget> listIcons = [];
    if (modeMindMap) {
      
    } else {
      listIcons.add(
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            if(nodesDataService.mindMap.value != null){
              nodesDataService.saveMindMap(nodesDataService.mindMap.value!);
            }
          }
        ),
      );
    }
    return AppBar(
      title: Text(title),
      actions: [
        ...listIcons,
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () => Navigator.pushNamed(context, '/configs'),
        ),
      ],
    );
  }
}
