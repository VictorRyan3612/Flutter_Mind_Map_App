import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class Node {
  int? id;
  String text;
  Color color;
  RelativeRect position;
  double width;
  double height;
  BorderRadiusGeometry borderRadius;

  Node({
    this.id,
    this.text = '',
    RelativeRect? position,
    this.color = Colors.red,
    double? width,
    double? height,

    BorderRadiusGeometry? borderRadius,
  })  : width = width ?? 20,
        height = height ?? 20,
        borderRadius = borderRadius ?? BorderRadius.circular(20),
        position = position ?? RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0);



}

class Edge{
  int id;
  int idSouce;
  int idDestination;
  Color color;
  double size;
  bool curvad;
  bool arrow;

  Edge({
    this.id = 0,
    required this.idSouce,
    required this.idDestination,
    this.color = Colors.black,
    this.size = 5.0,
    this.arrow = false,
    this.curvad = false
  });

}


void showContextMenu(BuildContext context, Offset position, 
    {List<ListTile>? listTiles}) {
  
  var positionFinal = RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy);
  var itemsFinal = [];

  if (listTiles != null && listTiles.isNotEmpty) {
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

class NodesDataService {
  ValueNotifier<List<Node>> nodes = ValueNotifier([]);
  ValueNotifier<List<Edge>> edges = ValueNotifier([]);
  ValueNotifier<Node?> firstSelectedNode = ValueNotifier(null);
  ValueNotifier<Node?> secondSelectedNode = ValueNotifier(null);


  // Função para adicionar um novo node com o ID mais alto possível
  void addNode(Node node) {
    int nextId = 0;

    if (nodes.value.isNotEmpty) {
      int maxId = 0;

      nodes.value.forEach((n) {
        if ((n.id ?? 0) > maxId) {
          maxId = n.id ?? 0;
        }
      });
      nextId = maxId + 1;
    }

    node.id = nextId;
    nodes.value = [...nodes.value, node];
  }
}

NodesDataService nodesDataService = NodesDataService();
