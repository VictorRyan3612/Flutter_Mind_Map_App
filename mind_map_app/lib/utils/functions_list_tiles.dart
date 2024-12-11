import 'package:flutter/material.dart';
import 'package:flutter_vicr_widgets/flutter_vicr_widgets.dart';
import 'package:mind_map_app/data/node.dart';
import 'package:mind_map_app/data/nodes_data_service.dart';

List<ListTile> functionListTileNode(BuildContext context, Offset position){
  var listtiles = [
    ListTile(
      title: Text("Conectar"),
      onTap: () {
        nodesDataService.isSelecting.value = true;
        Navigator.pop(context);
      },
    ),
    ListTile(
      title: Text("Excluir"),
      onTap: () {
        nodesDataService.firstSelectedNode.value = null;
        nodesDataService.deleteNode(nodesDataService.firstSelectedNode.value!);
        Navigator.pop(context);
      },
    ),
    ListTile(
      title: Text('Mudar cor'),
      onTap: ()async {
        
        var color = await showDialog(context: context, builder: (context) {
          return AlertDialog(
            content: VicrColorSelector(),
          );
        }); 
        if (color is Color) {
          nodesDataService.firstSelectedNode.value!.color = color;
          nodesDataService.nodes.notifyListeners();
          
        }
        Navigator.pop(context);
      },
    ),
  ];
  return listtiles;
}
List<ListTile> functionListTileGraph(BuildContext context, Offset position){
  List<ListTile> listtiles = [
    ListTile(
      title: Text("Criar Node"),
      onTap: () {
        nodesDataService.nodes.value.add(Node(id:nodesDataService.getMaxIdByType(Node), position: position));

        nodesDataService.nodes.notifyListeners();
        Navigator.pop(context);
      },
    ),
  ];
  return listtiles;
}
