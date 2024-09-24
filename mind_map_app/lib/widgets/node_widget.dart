import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mind_map_app/data/nodes_data_service.dart';

class NodeWidget extends HookWidget {
  final Node node;
  const NodeWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        // width: sizeNotifier.value.width,
        // height: sizeNotifier.value.height,
        decoration: BoxDecoration(
          color: node.color,
          borderRadius: node.borderRadius,
          
        ),
        child: Center(
          child: GestureDetector(
            onTap: () {
              
            },
          ),
        ),
      )
    );
  }
}
