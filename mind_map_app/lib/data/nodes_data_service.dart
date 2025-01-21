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
      'color': color.value, 
      'size': size,
      'curvad': curvad ? 1 : 0, // Convertendo bool para INTEGER
      'arrow': arrow ? 1 : 0,   // Convertendo bool para INTEGER
    };
  }

  static Edge fromJson(Map<String, dynamic> json){
    return Edge(
      id: json['id'],
      idSource: json['idSource'], 
      idDestination: json['idDestination'],
      color: Color(json['color']),
      curvad: json['curvad'] == 1, // Convertendo INTEGER de volta para bool
      arrow: json['arrow'] == 1,   // Convertendo INTEGER de volta para bool
      size: json['size'],
    );
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
class MindMap {
  int id;
  String name;
  List<Node>? nodes = [];
  List<Edge>? edges = [];
  int weight; // Peso do arquivo (em bytes)
  DateTime createdAt; // Data de criação
  DateTime modifiedAt; // Data de modificação

  MindMap({
    this.id = 0,
    this.name = '',
    List<Node>? nodes,
    List<Edge>? edges,
    this.weight = 0,
    DateTime? createdAt,
    DateTime? modifiedAt,
  })  : nodes = nodes ?? [], // Se nodes for null, usa uma lista vazia
        edges = edges ?? [],   // Se edges for null, usa uma lista vazia
        createdAt = createdAt ?? DateTime.now(),
        modifiedAt = modifiedAt ?? DateTime.now();

  // Método para converter para JSON
  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> jsonNodes = [];
    nodes?.forEach((element) {
      jsonNodes.add(element.toJson());
    });
    List<Map<String, dynamic>> jsonEdges = [];
    edges?.forEach((element) {
      jsonEdges.add(element.toJson());
    });
    return {
      'id': id,
      'name': name,
      'nodes': jsonNodes,
      'edges': jsonEdges,
    };
  }
  Map<String, dynamic> toDatabaseJson() {
    return {
      'id': id,
      'name': name,
      'weight': weight,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
    };
  }

  // Método para criar a partir de JSON
  static MindMap fromjson(Map<String, dynamic> json,
      {int weight = 0, DateTime? createdAt, DateTime? modifiedAt}) {
    List<Node> nodes = (json['nodes'] as List<dynamic>? ?? [])
      .map((nodeJson) => Node.fromJson(nodeJson))
      .toList();

  // Garante que 'edges' seja uma lista ou uma lista vazia
  List<Edge> edges = (json['edges'] as List<dynamic>? ?? [])
      .map((edgeJson) => Edge.fromJson(edgeJson))
      .toList();
    // List<Edge> edges = [];
    // for (var element in json['edges']) {
    //   edges.add(Edge.fromJson(element));
    // }
    return MindMap(
      id: json['id'],
      name: json['name'],
      nodes: nodes,
      edges: edges,
      weight: weight,
      createdAt: createdAt ?? DateTime.now(),
      modifiedAt: modifiedAt ?? DateTime.now(),
    );
  }
}


class NodesDataService {
  ValueNotifier<MindMap?> mindMap = ValueNotifier(null);
  ValueNotifier<List<MindMap>> listMindMap = ValueNotifier([]);

  ValueNotifier<Node?> firstSelectedNode = ValueNotifier(null);
  ValueNotifier<Node?> secondSelectedNode = ValueNotifier(null);
  ValueNotifier<bool> isEditing = ValueNotifier(false);
  ValueNotifier<bool> isSelecting = ValueNotifier(false);

  // Retornar o Id mais alto possível dependendo do tipo node ou edge
  Future<Directory> mapsFolder() async {
    Directory directory = await getApplicationSupportDirectory();
    Directory directoryMindMaps = Directory('${directory.path}\\mindMaps');
    directoryMindMaps.createSync();
    return directoryMindMaps;
  }

  loadMindMaps() async {
    Directory folder = await mapsFolder();
    var arquivos = folder.listSync();
    List<MindMap> lista = [];

    for (var entity in arquivos) { // Substitui o forEach
      File file = File('${entity.path}');
      if (file.existsSync()) {
        String content = await file.readAsString();
        if (content.isNotEmpty) {
          Map<String, dynamic> jsonList = json.decode(content);
          lista.add(
            MindMap.fromjson(
              jsonList,
              weight: await file.length(),
              createdAt: file.statSync().changed,
              modifiedAt: file.statSync().modified,
            ),
          );
        }
      }
    }

    listMindMap.value = lista;
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
    List<dynamic> listfinal = [];

    if (T == Node) {
      listfinal = mindMap.value?.nodes ?? [];
    }
    if (T == Edge) {
      listfinal = mindMap.value?.edges ?? [];
    }

    if (listfinal.isNotEmpty) {
      for (var item in listfinal) {
        if (item.id > maxId) {
          maxId = item.id;
        }
      }
    }
    nextId = maxId + 1;
    return nextId;
  }

  deleteNode(Node deletedNode) {
    final mindMapValue = mindMap.value;
    if (mindMapValue != null) {
      mindMapValue.edges?.removeWhere((element) {
        return element.idSource == deletedNode.id || element.idDestination == deletedNode.id;
      });
      mindMapValue.nodes?.remove(deletedNode);
      mindMap.value = mindMapValue; // Atualiza o mindMap para notificar os listeners
      mindMap.notifyListeners();
    }
  }

  dynamic getFirstByType(Type T, int id) {
    assert(T == Node || T == Edge, 'Type must be node or edge');

    if (T == Node) {
      return mindMap.value?.nodes?.firstWhere((element) => element.id == id);
    } else if (T == Edge) {
      return mindMap.value?.edges?.firstWhere((element) => element.id == id);
    }
    return null;
  }

  // Método para adicionar um nó
  addNode(Node node) {
    final mindMapValue = mindMap.value;
    if (mindMapValue != null) {
      mindMapValue.nodes?.add(node);
      mindMap.value = mindMapValue; // Atualiza o mindMap
      mindMap.notifyListeners();

    }
  }

  // Método para adicionar uma aresta
  addEdge(Edge edge) {
    final mindMapValue = mindMap.value;
    if (mindMapValue != null) {
      mindMapValue.edges?.add(edge);
      mindMap.value = mindMapValue; // Atualiza o mindMap
      mindMap.notifyListeners();
    }
  }

  // Método para atualizar um nó
  updateNode(Node node) {
    final mindMapValue = mindMap.value;
    if (mindMapValue != null) {
      final index = mindMapValue.nodes?.indexWhere((n) => n.id == node.id);
      if (index != null && index >= 0) {
        mindMapValue.nodes?[index] = node;
        mindMap.value = mindMapValue; // Atualiza o mindMap
        mindMap.notifyListeners();
      }
    }
  }

  // Método para atualizar uma aresta
  updateEdge(Edge edge) {
    final mindMapValue = mindMap.value;
    if (mindMapValue != null) {
      final index = mindMapValue.edges?.indexWhere((e) => e.id == edge.id);
      if (index != null && index >= 0) {
        mindMapValue.edges?[index] = edge;
        mindMap.value = mindMapValue; // Atualiza o mindMap
        mindMap.notifyListeners();
      }
    }
  }
}

NodesDataService nodesDataService = NodesDataService();
