import 'package:flutter/material.dart';
import 'package:mind_map_app/data/nodes_data_service.dart';
import 'package:mind_map_app/widgets/new_name.dart';

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
      listIcons.add(
        IconButton(
          icon: Icon(Icons.save),
          onPressed: () {
            print(nodesDataService.mindMap.value?.toJson());
            
            nodesDataService.saveMindMap(nodesDataService.mindMap.value!);
          }, 
        )
      );
    } else {
      listIcons.add(
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () async {
            var controller = TextEditingController();
            
            await showDialog(context: context,
              builder: (context) {
                return NewItemAlertDialog(
                  nameController: controller, 
                  checkIfExists: (name) => 
                    nodesDataService.listMindMap.value.any((element) => element.name == name),
                  
                  onConfirm: (name) {
                    print('No confirm');
                    nodesDataService.mindMap.value = MindMap(name: controller.text);
                    List<MindMap> lista = nodesDataService.listMindMap.value;
                    lista.add(nodesDataService.mindMap.value!);
                    nodesDataService.listMindMap.value = List.from(lista);

                    nodesDataService.saveMindMap(nodesDataService.mindMap.value!);
                    
                  },
                );
              }); 
              
            Navigator.pushNamed(context, '/graphScreen');
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
