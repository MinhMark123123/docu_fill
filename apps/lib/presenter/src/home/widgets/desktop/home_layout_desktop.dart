import 'package:docu_fill/presenter/src/home/widgets/fields_input_layout.dart';
import 'package:docu_fill/presenter/src/home/widgets/templates_collection.dart';
import 'package:docu_fill/ui/ui.dart';
import 'package:flutter/material.dart';

class HomeLayoutDesktop extends StatelessWidget {
  const HomeLayoutDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.size40,
          vertical: Dimens.size20,
        ),
        child: body(),
      ),
    );
  }

  Widget body() {
    return Row(
      children: [
        Expanded(flex: 3, child: FieldsInputLayout()),
        Expanded(flex: 1, child: TemplatesCollection()),
      ],
    );
  }
}
