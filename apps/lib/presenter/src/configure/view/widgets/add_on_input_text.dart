import 'package:docu_fill/const/const.dart';
import 'package:docu_fill/ui/ui.dart';
import 'package:docu_fill/utils/utils.dart';
import 'package:flutter/material.dart';

class AddOnInputText extends StatefulWidget {
  final Function(List<String>)? onChanged;

  const AddOnInputText({super.key, this.onChanged});

  @override
  State<AddOnInputText> createState() => _AddOnInputTextState();
}

class _AddOnInputTextState extends State<AddOnInputText> {
  int _count = 1;
  final List<String?> _values = [];
  final ScrollController _scrollController = ScrollController();
  final List<Widget> _listInput = [];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final itemWidth = constraints.maxWidth - Dimens.size32;
        return SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ..._buildTextInputs(itemWidth),
              SizedBox(
                width: Dimens.size32,
                child: IconButton(
                  onPressed: () => addItem(itemWidth),
                  icon: Icon(Icons.add),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void addItem(double itemWidth) {
    setState(() {
      _count++;
      _listInput.add(buildInputAtIndex(itemWidth, _count - 1));
      _values.add(null);
    });
    scrollToEnd();
  }

  void removeItem(int index) {
    setState(() {
      if (_listInput.isNotEmpty) {
        _listInput.removeAt(index);
        _values.removeAt(index);
        _count = _listInput.length;
        notifyOutText();
      }
    });
    scrollToEnd();
  }

  void scrollToEnd() {
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 200),
        curve: Curves.linear,
      );
    });
  }

  List<Widget> _buildTextInputs(double width) {
    if (_listInput.isEmpty) {
      _listInput.add(buildInputAtIndex(width, 0));
      _values.add(null);
      return _listInput;
    }
    return _listInput;
  }

  Widget buildInputAtIndex(double width, int index) {
    return SizedBox(
      width: width,
      child: TextFormField(
        decoration: InputDecoration(
          hintText: AppLang.messagesInputTextHint.tr(),
          border: const OutlineInputBorder(),
          icon:
              index == 0
                  ? null
                  : IconButton(
                    onPressed: () {
                      removeItem(index);
                    },
                    icon: Icon(Icons.remove_circle),
                  ),
        ),
        onChanged: (value) {
          _values[index] = value;
          notifyOutText();
        },
      ),
    );
  }

  Future<void> notifyOutText() async {
    final nonNullValues = _values.where((e) => e != null).map(((e) => e!));
    widget.onChanged?.call(nonNullValues.toList());
  }
}
