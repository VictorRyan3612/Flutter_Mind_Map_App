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

    return InteractiveViewer(
      child: ValueListenableBuilder(
        valueListenable: nodesDataService.nodes,
        builder: (context, nodesValue, child) {
          
          return GestureDetector(
            onTap: () {
              nodesDataService.firstSelectedNode.value = null;

            },
            onDoubleTapDown: (details) {
              _debounce = Timer(const Duration(milliseconds: 500), () {
                if (nodesDataService.firstSelectedNode.value == null) {


                  showContextMenu(context, positionOffset: details.localPosition);
                }
              });
            },
            onSecondaryTapDown: (details) {
              nodesDataService.firstSelectedNode.value = null;
              nodesValue.add(Node(color: Colors.red));
              nodesDataService.nodes.notifyListeners();
              showContextMenu(context, positionOffset: details.localPosition);
            },
            child: Stack(
              children: [
                ValueListenableBuilder(
                  valueListenable: nodesDataService.edges,
                  builder: (context, edgesValue, child) {
                    return CustomPaint(
                      size: Size.infinite,
                      painter: EdgesPainter([]),
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
