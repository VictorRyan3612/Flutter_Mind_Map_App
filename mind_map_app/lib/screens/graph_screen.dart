import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mind_map_app/data/nodes_data_service.dart';
import 'package:mind_map_app/widgets/edges_painter.dart';
import 'package:mind_map_app/widgets/node_widget.dart';

class GraphScreen extends StatelessWidget {
  const GraphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Timer? _debounce;

    List<ListTile> listtiles = [
      ListTile(
        title: Text("Criar Node"),
        onTap: () {
          nodesDataService.nodes.value.add(Node(color: Colors.red));
          nodesDataService.nodes.notifyListeners();
          Navigator.pop(context);
        },
      ),
      ListTile(
        title: Text("Criar Edge"),
        onTap: () {
          nodesDataService.nodes.value.add(Node(id: 0, color: Colors.red, position: Offset(50, 50)));
          nodesDataService.nodes.value.add(Node(id: 1, color: Colors.blue, position: Offset(100, 100)));
          nodesDataService.edges.value.add(Edge(idSource: 0, idDestination: 1, color: Colors.orange, curvad: true, arrow: true));
          nodesDataService.nodes.notifyListeners();
          nodesDataService.edges.notifyListeners();
          Navigator.pop(context);
        },
      )
    ];
    return InteractiveViewer(
      child: ValueListenableBuilder(
        valueListenable: nodesDataService.nodes,
        builder: (context, nodesValue, child) {
          
          return GestureDetector(
            onTap: () {
              nodesDataService.firstSelectedNode.value = null;
              nodesDataService.secondSelectedNode.value = null;

            },
            onDoubleTapDown: (details) {
              _debounce = Timer(const Duration(milliseconds: 500), () {
                if (nodesDataService.firstSelectedNode.value == null) {


                  showContextMenu(context, positionOffset: details.localPosition, listTiles: listtiles);
                }
              });
            },
            onSecondaryTapDown: (details) {
              nodesDataService.firstSelectedNode.value = null;
              showContextMenu(context, positionOffset: details.localPosition, listTiles: listtiles);
            },
            child: Stack(
              children: [
                ValueListenableBuilder(
                  valueListenable: nodesDataService.edges,
                  builder: (context, edgesValue, child) {
                    return CustomPaint(
                      size: Size.infinite,
                      painter: EdgesPainter(
                        edgesValue.map((edge) {
                          edge.color = Edge.determineEdgeColor(context, edge.color);
                          return edge;
                        }).toList()
                      ),
                    );
                  },
                ),
                for (int i = 0; i < nodesValue.length; i++)
                Positioned(
                  left: nodesValue[i].position.dx,
                  top: nodesValue[i].position.dy,
                  child: GestureDetector(
                    onDoubleTapDown: (details) {
                      nodesDataService.isEditing.value = true;
                      nodesDataService.firstSelectedNode.value = nodesValue[i];
                    },
                    onTapDown: (details) {
                      nodesDataService.firstSelectedNode.value = nodesValue[i];
                      
                    },
                    onSecondaryTapDown: (details) {
                      nodesDataService.firstSelectedNode.value = nodesValue[i];
                    },
                    onPanUpdate: (details) {
                      nodesValue[i].position += details.delta;
                      nodesDataService.nodes.notifyListeners();
                    },
                    child: NodeWidget(
                      node: nodesValue[i],
                    ),
                  ),
                )
              ],
            ),
          );
        }
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  final Offset chartOffset; // deslocamento do gráfico

  ChartPainter(this.chartOffset);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4;

    // Desenhar o ponto na origem (0, 0) considerando o deslocamento do gráfico
    Offset adjustedPointPosition = Offset(size.width / 2 + chartOffset.dx, size.height / 2 + chartOffset.dy);

    // Desenhar o ponto no gráfico
    canvas.drawCircle(adjustedPointPosition, 10, paint);

    // Desenhar eixos do gráfico
    final axisPaint = Paint()
      ..color = Colors.transparent
      ..strokeWidth = 2;

    // Eixo X
    canvas.drawLine(
      Offset(0, size.height / 2) + chartOffset,
      Offset(size.width, size.height / 2) + chartOffset,
      axisPaint,
    );

    // Eixo Y
    canvas.drawLine(
      Offset(size.width / 2, 0) + chartOffset,
      Offset(size.width / 2, size.height) + chartOffset,
      axisPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
