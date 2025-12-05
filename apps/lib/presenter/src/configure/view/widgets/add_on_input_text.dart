import 'package:docu_fill/const/const.dart';
import 'package:docu_fill/ui/ui.dart';
import 'package:docu_fill/utils/utils.dart';
import 'package:flutter/material.dart';

class AddOnInputText extends StatefulWidget {
  final Function(List<String>)? onChanged;
  final List<String?>? initValue;

  const AddOnInputText({super.key, this.onChanged, this.initValue});

  @override
  State<AddOnInputText> createState() => _AddOnInputTextState();
}

class _AddOnInputTextState extends State<AddOnInputText> {
  int _count = 1;
  final List<String?> _values = [];
  final ScrollController _scrollController = ScrollController();
  final List<Widget> _listInput = [];
  double itemWidth = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initValue != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(Duration(milliseconds: 100));
        _values.addAll(widget.initValue!);
        for (var e in _values) {
          _count++;
          _listInput.add(
            buildInputAtIndex(
              width: itemWidth,
              index: _count - 1,
              initValue: e,
            ),
          );
          setState(() {});
        }
        await Future.delayed(Duration(milliseconds: 200));
        scrollToEnd();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        itemWidth = constraints.maxWidth - Dimens.size32;
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
      _listInput.add(buildInputAtIndex(width: itemWidth, index: _count - 1));
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
    if (_listInput.isEmpty && widget.initValue == null) {
      _listInput.add(buildInputAtIndex(width: width, index: 0));
      _values.add(null);
      return _listInput;
    }
    return _listInput;
  }

  Widget buildInputAtIndex({
    required double width,
    required int index,
    String? initValue,
  }) {
    return SizedBox(
      width: width,
      child: TextFormField(
        initialValue: initValue,
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
