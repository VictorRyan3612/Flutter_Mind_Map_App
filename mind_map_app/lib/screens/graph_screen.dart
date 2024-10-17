import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mind_map_app/data/nodes_data_service.dart';
import 'package:mind_map_app/utils/functions_list_tiles.dart';
import 'package:mind_map_app/widgets/chart_painter.dart';
import 'package:mind_map_app/widgets/edges_painter.dart';
import 'package:mind_map_app/widgets/node_widget.dart';


class GraphScreen extends HookWidget {
  const GraphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    // Posições usando useState
    final chartOffset = useState(Offset(0, 0));
    final displayedCoordinates = useState(Offset(0, 0));

    return InteractiveViewer(
      child: ValueListenableBuilder(
        valueListenable: nodesDataService.nodes,
        builder: (context, nodesValue, child) {
          return Stack(
            children: [
              GestureDetector(
                onPanUpdate: (details) {
                  chartOffset.value = Offset(
                    chartOffset.value.dx + details.delta.dx,
                    chartOffset.value.dy + details.delta.dy,
                  );

                    // Atualiza a posição de cada nó com base no deslocamento
                  for (var node in nodesValue) {
                    node.position = Offset(
                      node.position.dx + details.delta.dx,
                      node.position.dy + details.delta.dy,
                    );
                  }
                  // Notifica os listeners após atualizar as posições dos nós
                  nodesDataService.nodes.notifyListeners();
                },
                onTapDown: (details) {
                  nodesDataService.isEditing.value = false;
                  nodesDataService.firstSelectedNode.value = null;
                  nodesDataService.secondSelectedNode.value = null;
                  nodesDataService.isSelecting.value = false;

                  displayedCoordinates.value = Offset(
                    (details.localPosition.dx - chartOffset.value.dx) -
                        (MediaQuery.of(context).size.width / 2),
                    (details.localPosition.dy - chartOffset.value.dy) -
                        (MediaQuery.of(context).size.height / 2),
                  );
                  
                },
                onDoubleTapDown: (details) {
                  if (nodesDataService.firstSelectedNode.value == null) {
                    nodesDataService.isSelecting.value = false;
                    nodesDataService.isEditing.value = false;

                    showContextMenu(context, positionOffset: details.localPosition, listTiles: functionListTileGraph(context, details.localPosition));
                  }
                },
                onSecondaryTapDown: (details) {
                  nodesDataService.isEditing.value = false;
                  nodesDataService.firstSelectedNode.value = null;
                  nodesDataService.isSelecting.value = false;

                  showContextMenu(context, positionOffset: details.localPosition, listTiles: functionListTileGraph(context, details.localPosition));
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
                              // Recalcular a cor da aresta conforme o tema
                              return edge;
                            }).toList(),
                          ),
                        );
                      }
                    ),
                    CustomPaint(
                      size: Size(double.infinity, double.infinity),
                      painter: ChartPainter(chartOffset.value),
                    ),
                    for (int i = 0; i < nodesValue.length; i++)
                    Positioned(
                      left: nodesValue[i].position.dx,
                      top: nodesValue[i].position.dy,
                      child: GestureDetector(
                        onDoubleTapDown: (details) {
                          nodesDataService.isEditing.value = true;
                          nodesDataService.firstSelectedNode.value = nodesValue[i];
                          nodesDataService.secondSelectedNode.value = null;
                          nodesDataService.isSelecting.value = false;
                        },
                        onTapDown: (details) {
                          if (nodesDataService.isSelecting.value == false) {
                            nodesDataService.firstSelectedNode.value = nodesValue[i];
                            nodesDataService.secondSelectedNode.value = null;
                            
                          } else {
                            nodesDataService.secondSelectedNode.value = nodesValue[i];

                            nodesDataService.edges.value.add(Edge(idSource: nodesDataService.firstSelectedNode.value!.id, idDestination: nodesDataService.secondSelectedNode.value!.id, color: nodesDataService.firstSelectedNode.value!.color));

                            nodesDataService.edges.notifyListeners();
                          }
                        },
                        onSecondaryTapDown: (details) {
                          nodesDataService.firstSelectedNode.value = nodesValue[i];

                          showContextMenu(context, positionOffset: details.globalPosition, listTiles: functionListTileNode(context, details.localPosition));
                          
                          nodesDataService.isEditing.value = false;
                          nodesDataService.firstSelectedNode.value = nodesValue[i];
                          nodesDataService.secondSelectedNode.value = null;
                        },
                        onPanUpdate: (details) {
                          nodesValue[i].position = Offset(
                            nodesValue[i].position.dx + details.delta.dx,
                            nodesValue[i].position.dy + details.delta.dy,
                          );
                          nodesDataService.nodes.notifyListeners();
                          
                        },
                        child: NodeWidget(
                          node: nodesValue[i],
                        ),
                      ),
                    ),
                    
                  ],
                ),
              ),
              
              Positioned(
                top: 16,
                left: 16,
                child: Text(
                  'Coordenadas: (${displayedCoordinates.value.dx.toStringAsFixed(1)}, ${displayedCoordinates.value.dy.toStringAsFixed(1)})',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}
