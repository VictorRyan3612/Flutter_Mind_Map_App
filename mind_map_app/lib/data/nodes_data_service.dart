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
