import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mind_map_app/data/nodes_data_service.dart';

class GraphScreen extends StatelessWidget {
  const GraphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Timer? _debounce;

    return InteractiveViewer(
      child: GestureDetector(
        onDoubleTapDown: (details) {
          
          _debounce = Timer(const Duration(milliseconds: 500), () {
            if (nodesDataService.firstSelectedNode.value != null) {
              showContextMenu(context, positionOffset: details.localPosition);
            }
          });
        },
        onSecondaryTapDown: (details) {
          showContextMenu(context, positionOffset: details.localPosition);
        },
      ),
    );
  }
}
