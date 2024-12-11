import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mind_map_app/data/node.dart';
import 'package:path_provider/path_provider.dart';



class Edge{
  int id;
  int idSource;
  int idDestination;
  Color color;
  double size;
  bool curvad;
  bool arrow;

  Edge({
    this.id = 0,
    required this.idSource,
    required this.idDestination,
    this.color = Colors.red,
    this.size = 5.0,
    this.arrow = false,
    this.curvad = false
  }){
    assert(idSource != idDestination, "idSource and idDestination must be different");
    assert(idSource >= 0, "idSource must be greater than or equal to 0");
    assert(idDestination >= 0, "idDestination must be greater than or equal to 0");
     // Avisar se a cor é preta ou branca
    if (isBlackOrWhite(color)) {
      print("Warning: Using black or white color for edges is not recommended because background themes.");
    }
  }

  // Método para verificar se a cor é preta ou branca
  static bool isBlackOrWhite(Color color) {
    return color == Colors.black || color == Colors.white;
  }


  static Color determineEdgeColor(context, Color color) {
    if (color != Colors.transparent) {
      // Se o nó tiver uma cor definida, usa a cor do nó
      return color;
    }
    // Caso contrário, usa a cor com base no tema (tema claro = preto, tema escuro = branco)
    return Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
  }

  @override
  String toString() {
    return 'Edge(id: $id, idSource: $idSource, idDestination: $idDestination, color: $color, size: $size, arrow: $arrow, curvad: $curvad)';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idSource': idSource,
      'idDestination': idDestination,
      'color': color, 
      'size': size,
      'curvad': curvad,
      'arrow': arrow,
    };
  }
  
  // Example of creation using determineEdgeColor:
  // Edge(idSouce: 0, idDestination: 1, color: Edge.determineEdgeColor(context, nodesDataService.firstSelectedNode.value!.color));
} 


void showContextMenu(BuildContext context, 
    {List<ListTile>? listTiles, Offset? positionOffset, RelativeRect? positionRelativeRect}) {
    assert(positionOffset != null || positionRelativeRect != null, 'One parameter must be provided, but not both.');
    assert(!(positionOffset != null && positionRelativeRect != null), 'Both parameters cannot be provided');
  
  var itemsFinal = [];

  if (listTiles != null && listTiles.isNotEmpty) {
    late RelativeRect positionFinal;

    if(positionOffset != null){
      positionFinal = RelativeRect.fromLTRB(positionOffset.dx, positionOffset.dy, positionOffset.dx, positionOffset.dy);
    }
    if (positionRelativeRect != null) {
      positionFinal = positionRelativeRect;
    }

    itemsFinal = List.generate(listTiles.length, (index) {
      return PopupMenuItem(
        value: index,
        child: listTiles[index]
      );
    });

    showMenu(
      context: context,
      position: positionFinal,
      elevation: 8.0,
      items: List.from(itemsFinal)
    );
  }   
}
class MindMap{
  String name; 
  List<Node>? nodes = [];
  List<Edge>? edges = [];

  MindMap({required this.name, this.nodes, this.edges});

  Map<String, dynamic> toJson(){
    return {
      'name': name,
      'nodes': nodes,
      'edges': edges
    };
  }
}

class NodesDataService {
  ValueNotifier<MindMap?> mindMap= ValueNotifier(null);
  List<MindMap> listMindMap = []; 

  ValueNotifier<List<Node>> nodes = ValueNotifier([]);
  ValueNotifier<List<Edge>> edges = ValueNotifier([]);
  ValueNotifier<Node?> firstSelectedNode = ValueNotifier(null);
  ValueNotifier<Node?> secondSelectedNode = ValueNotifier(null);
  ValueNotifier<bool> isEditing = ValueNotifier(false);
  ValueNotifier<bool> isSelecting = ValueNotifier(false);

  // Retornar o Id mais alto possível dependendo do tipo node ou edge

  Future<Directory> mapsFolder()async {
    Directory directory = await getApplicationSupportDirectory();
    Directory directoryMindMaps = Directory('${directory.path}\\mindMaps');
    directoryMindMaps.createSync();
    return directoryMindMaps;
  }

  loadMindMaps() async{
    Directory folder = await mapsFolder();
    var arquivos = folder.listSync();

    arquivos.forEach((entity) async {
      // print(entity.path);
      File file = File('${entity.path}');
      if (file.existsSync()){
        String content = await file.readAsString();
        if (content != '') {
          Map<String, dynamic> jsonList = json.decode(content);
          // print(jsonList);
          MindMap mindMap = MindMap(
            name: jsonList['name'],
            nodes: jsonList['nodes'],
            edges: jsonList['edges']
          );
          listMindMap.add(mindMap);
          // print(listMindMap);
        }
      }
    });
  }

  saveMindMap(MindMap mindMap) async {
    var folder = await mapsFolder();
    File file = File('${folder.path}/${mindMap.name}.dat');
    String content = json.encode(mindMap.toJson());
    file.writeAsString(content);
    file.createSync();
  }

  int getMaxIdByType(Type T) {
    assert(T == Node || T == Edge, 'Type must be node or edge');

    int nextId = 0;
    int maxId = -1;
    var listfinal = [];

    if (T == Node) {
      listfinal = nodes.value;
    }
    if (T == Edge) {
      listfinal = edges.value;
    }

    if (listfinal.isNotEmpty) {
      listfinal.forEach((n) {
        if (n.id > maxId) {
          maxId = n.id;
        }
      });
      
    }
    nextId = maxId + 1;
    return  nextId;
  }

  deleteNode(Node deletedNode){
    edges.value.removeWhere((element) {
      return element.idSource == deletedNode.id || element.idDestination == deletedNode.id;
    });
    nodes.value.remove(deletedNode);
    nodes.notifyListeners();
    edges.notifyListeners();
  }
  dynamic getFirstByType(Type T, int id){
    assert(T == Node || T == Edge, 'Type must be node or edge');
    
    if (T == Node) {
      return nodes.value.firstWhere((element) => element.id == id);
    } 
    else if(T == Edge){
      return edges.value.firstWhere((element) => element.id == id);
    }
  }
}

NodesDataService nodesDataService = NodesDataService();
