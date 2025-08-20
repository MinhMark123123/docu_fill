import 'package:docu_fill/const/const.dart';

class Dimensions {
  final double? width;
  final double? height;
  final String? unit;

  Dimensions({required this.width, required this.height, required this.unit});

  factory Dimensions.empty() {
    return Dimensions(width: null, height: null, unit: null);
  }

  String format() {
    var w = width?.toString() ?? "";
    var h = height?.toString() ?? "";
    var u = unit ?? "";
    return "$w;$h;$u";
  }

  static Dimensions? from(String? value) {
    if (value == null) return null;
    final values = value.split(";");
    if (values.length != 3) return null;
    if (values.toList().any((e) => e == AppConst.empty)) {
      return null;
    }
    return Dimensions(
      width: double.tryParse(values[0]),
      height: double.tryParse(values[1]),
      unit: values[2],
    );
  }

  Dimensions copyWith({double? width, double? height, String? unit}) {
    return Dimensions(
      width: width ?? this.width,
      height: height ?? this.height,
      unit: unit ?? this.unit,
    );
  }
}
