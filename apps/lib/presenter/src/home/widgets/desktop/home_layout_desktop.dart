import 'package:docu_fill/presenter/src/home/widgets/templates_collection.dart';
import 'package:flutter/material.dart';

class HomeLayoutDesktop extends StatelessWidget {
  final Widget detailChild;
  const HomeLayoutDesktop({super.key, required this.detailChild});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: body());
  }

  Widget body() {
    return Row(
      children: [
        Expanded(flex: 1, child: TemplatesCollection()),
        Expanded(flex: 4, child: detailChild),
      ],
    );
  }
}
