import 'package:data/data.dart';
import 'package:docu_fill/features/src/home/view_model/quick_image_input_view_model.dart';
import 'package:flutter/material.dart';

import 'quick_image_input_card.dart';

class QuickImageInputGrid extends StatefulWidget {
  final List<TemplateField> fields;
  final Map<String, String?> paths;
  final QuickImageInputViewModel viewModel;

  const QuickImageInputGrid({
    super.key,
    required this.fields,
    required this.paths,
    required this.viewModel,
  });

  @override
  State<QuickImageInputGrid> createState() => _QuickImageInputGridState();
}

class _QuickImageInputGridState extends State<QuickImageInputGrid> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.85,
      ),
      itemCount: widget.fields.length,
      itemBuilder: (context, index) {
        final field = widget.fields[index];
        final path = widget.paths[field.key];
        final isHovered = _hoveredIndex == index;

        return DragTarget<int>(
          onWillAcceptWithDetails: (details) => details.data != index,
          onAcceptWithDetails: (details) {
            final sourceIndex = details.data;
            widget.viewModel.swapImages(sourceIndex, index);
            setState(() {
              _hoveredIndex = null;
            });
          },
          onMove: (details) {
            if (_hoveredIndex != index) {
              setState(() {
                _hoveredIndex = index;
              });
            }
          },
          onLeave: (data) {
            if (_hoveredIndex == index) {
              setState(() {
                _hoveredIndex = null;
              });
            }
          },
          builder: (context, candidateData, rejectedData) {
            final cardContent = QuickImageInputCard(
              field: field,
              path: path,
              isTargetHovered: isHovered,
              viewModel: widget.viewModel,
            );

            if (path != null && path.isNotEmpty) {
              return Draggable<int>(
                data: index,
                feedback: Material(
                  color: Colors.transparent,
                  child: Opacity(
                    opacity: 0.85,
                    child: Transform.scale(
                      scale: 1.05,
                      child: SizedBox(
                        width: 180,
                        height: 210,
                        child: QuickImageInputCard(
                          field: field,
                          path: path,
                          isTargetHovered: false,
                          isFeedback: true,
                          viewModel: widget.viewModel,
                        ),
                      ),
                    ),
                  ),
                ),
                childWhenDragging: Opacity(opacity: 0.35, child: cardContent),
                child: cardContent,
              );
            } else {
              return cardContent;
            }
          },
        );
      },
    );
  }
}
