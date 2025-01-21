import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mind_map_app/data/db.dart';
import 'package:mind_map_app/data/node.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';



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

  // Método para obter a pasta de mapas mentais
  Future<Directory> mapsFolder() async {
    Directory directory = await getApplicationSupportDirectory();
    Directory directoryMindMaps = Directory('${directory.path}/mindMaps');
    if (!directoryMindMaps.existsSync()) {
      directoryMindMaps.createSync();
    }
    return directoryMindMaps;
  }

  // Método para carregar os mapas mentais do banco de dados
  Future<void> loadMindMaps() async {
    List<MindMap> dbMindMaps = await DB.loadMindMaps();
    listMindMap.value = dbMindMaps;
    listMindMap.notifyListeners();
  }

  // Método para salvar um mapa mental no banco de dados
  Future<void> saveMindMap(MindMap mindMap) async {
    await DB.saveMindMap(mindMap);
    // Atualiza a lista de mapas mentais após salvar
    await loadMindMaps();
  }

  // Obter o maior ID com base no tipo (Node ou Edge)
  int getMaxIdByType(Type T) {
    assert(T == Node || T == Edge, 'Type must be Node or Edge');
    int maxId = -1;

    List<dynamic> list = T == Node
        ? (mindMap.value?.nodes ?? [])
        : (mindMap.value?.edges ?? []);

    for (var item in list) {
      if (item.id > maxId) {
        maxId = item.id;
      }
    }
    return maxId + 1;
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
  // Método para deletar um nó e suas arestas associadas
  Future<void> deleteNode(Node deletedNode) async {
    final mindMapValue = mindMap.value;
    if (mindMapValue != null) {
      // Remove arestas conectadas ao nó
      mindMapValue.edges?.removeWhere((edge) =>
          edge.idSource == deletedNode.id || edge.idDestination == deletedNode.id);
      // Remove o nó
      mindMapValue.nodes?.remove(deletedNode);

      // Atualiza o banco de dados
      final db = await DB.getDatabase();
      await db.delete('edges', where: 'idSource = ? OR idDestination = ?', whereArgs: [deletedNode.id, deletedNode.id]);
      await db.delete('nodes', where: 'id = ?', whereArgs: [deletedNode.id]);

      // Notifica as alterações
      mindMap.value = mindMapValue;
      mindMap.notifyListeners();
    }
  }
  Future<void> deleteMindMap(int mindMapId) async {
  final db = await DB.getDatabase();

  try {
    // Exclui o mapa mental da tabela 'mindmaps' com base no id
    await db.delete(
      'mindmaps',
      where: 'id = ?',
      whereArgs: [mindMapId],
    );

    // Também pode ser necessário excluir os nós e arestas relacionados a este mapa mental
    await db.delete(
      'nodes',
      where: 'mindMapId = ?',
      whereArgs: [mindMapId],
    );
    
    await db.delete(
      'edges',
      where: 'mindMapId = ?',
      whereArgs: [mindMapId],
    );

    print('MindMap com id $mindMapId deletado com sucesso.');
    listMindMap.value.removeWhere((element) => element.id == mindMapId,);
    mindMap.value = null;
    listMindMap.notifyListeners();
    mindMap.notifyListeners();
  } catch (e) {
    print('Erro ao deletar o MindMap: $e');
  }
}
  // Método para adicionar um nó
  Future<void> addNode(Node node) async {
    final mindMapValue = mindMap.value;
    if (mindMapValue != null) {
      mindMapValue.nodes?.add(node);
      final db = await DB.getDatabase();

      await db.insert('nodes', node.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
      mindMap.value = mindMapValue;
      mindMap.notifyListeners();
    }
  }

  // Método para adicionar uma aresta
  Future<void> addEdge(Edge edge) async {
    final mindMapValue = mindMap.value;
    if (mindMapValue != null) {
      mindMapValue.edges?.add(edge);
      final db = await DB.getDatabase();
      await db.insert('edges', edge.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
      mindMap.value = mindMapValue;
      mindMap.notifyListeners();
    }
  }

  // Método para atualizar um nó
  Future<void> updateNode(Node node) async {
    final mindMapValue = mindMap.value;
    if (mindMapValue != null) {
      final index = mindMapValue.nodes?.indexWhere((n) => n.id == node.id);
      if (index != null && index >= 0) {
        mindMapValue.nodes?[index] = node;
        final db = await DB.getDatabase();
        await db.update('nodes', node.toJson(), where: 'id = ?', whereArgs: [node.id]);
        mindMap.value = mindMapValue;
        mindMap.notifyListeners();
      }
    }
  }

  // Método para atualizar uma aresta
  Future<void> updateEdge(Edge edge) async {
    final mindMapValue = mindMap.value;
    if (mindMapValue != null) {
      final index = mindMapValue.edges?.indexWhere((e) => e.id == edge.id);
      if (index != null && index >= 0) {
        mindMapValue.edges?[index] = edge;
        final db = await DB.getDatabase();
        await db.update('edges', edge.toJson(), where: 'id = ?', whereArgs: [edge.id]);
        mindMap.value = mindMapValue;
        mindMap.notifyListeners();
      }
    }
  }
}


NodesDataService nodesDataService = NodesDataService();
