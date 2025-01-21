import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_vicr_widgets/flutter_vicr_widgets.dart';
import 'package:mind_map_app/data/node.dart';
import 'package:file_picker/file_picker.dart';
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
        // nodesDataService.firstSelectedNode.value = null;
        nodesDataService.deleteNode(nodesDataService.firstSelectedNode.value!);
        // nodesDataService.deleteNode(
        //   nodesDataService.mindMap.value!.nodes!.firstWhere((element) => element == nodesDataService.firstSelectedNode.value,)
        //   );
        nodesDataService.mindMap.notifyListeners();
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
          nodesDataService.updateNode(nodesDataService.firstSelectedNode.value!);
          nodesDataService.mindMap.notifyListeners();
          
        }
        Navigator.pop(context);
      },
    ),
    ListTile(
      title: Text('Adicionar Imagem'),
      onTap: () async{
        var result = await FilePicker.platform.pickFiles(type: FileType.image);
        if (result != null && result.files.single.path != null) {
          var image = File(result.files.single.path!);
          nodesDataService.firstSelectedNode.value!.image = image.path;
          nodesDataService.updateNode(nodesDataService.firstSelectedNode.value!);
          // nodesDataService.firstSelectedNode.value!.image = Image.file(image);
          // print(nodesDataService.firstSelectedNode.value!.image);
        }
        
      },
    )
  ];
  return listtiles;
}
List<ListTile> functionListTileGraph(BuildContext context, Offset position){
  List<ListTile> listtiles = [
    ListTile(
      title: Text("Criar Node"),
      onTap: () {
        nodesDataService.addNode(Node(id:nodesDataService.getMaxIdByType(Node), position: position));
        // nodesDataService.nodes.value.add();

        nodesDataService.mindMap.notifyListeners();
        Navigator.pop(context);
      },
    ),
  ];
  return listtiles;
}
List<ListTile> functionListTileMaps(BuildContext context, Offset position){
  List<ListTile> listtiles = [
    ListTile(
      title: Text("Excluir"),
      onTap: () async{
        Navigator.pop(context);
        showDialog(context: context, builder: (context) {
          return AlertDialog(
            title: Text('Confirmar exclusão?'),
            actions: [
              TextButton(
                onPressed: () {
                Navigator.pop(context);
                }, 
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  nodesDataService.deleteMindMap(nodesDataService.mindMap.value!.id);
                  Navigator.pop(context);
                  
                }, 
                child: Text('Confirmar'),
              ),
              
            ],
          );
        },
        
        );
        nodesDataService.mindMap.notifyListeners();
      },
      
    ),
  ];
  return listtiles;
}