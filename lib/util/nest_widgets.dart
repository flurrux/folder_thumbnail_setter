
import 'package:flutter/material.dart';

Widget nestWidgets(
  List<Widget Function(Widget)> wrappers,
  Widget leaf,
){
  Widget result = leaf;
  for (int i = wrappers.length - 1; i >= 0; i--){
    result = wrappers[i](result);
  }
  return result;
}
