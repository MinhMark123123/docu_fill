import 'package:adaptive_layout/adaptive_layout.dart';
import 'package:docu_fill/presenter/src/home/widgets/desktop/templates_collection_desktop.dart';
import 'package:docu_fill/presenter/src/home/widgets/mobile/templates_collection_mobile.dart';
import 'package:flutter/material.dart';

class TemplatesCollection extends StatelessWidget {
  const TemplatesCollection({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      smallLayout: TemplatesCollectionMobile(),
      mediumLayout: TemplatesCollectionDesktop(),
    );
  }
}
