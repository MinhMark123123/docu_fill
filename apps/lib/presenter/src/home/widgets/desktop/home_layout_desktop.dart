import 'package:docu_fill/presenter/src/home/widgets/fields_input_layout.dart';
import 'package:docu_fill/presenter/src/home/widgets/templates_collection.dart';
import 'package:flutter/material.dart';

class HomeLayoutDesktop extends StatelessWidget {
  const HomeLayoutDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: body());
  }

  Widget body() {
    return Row(
      children: [
        Expanded(flex: 1, child: TemplatesCollection()),
        Expanded(flex: 4, child: FieldsInputLayout()),
      ],
    );
  }
}
