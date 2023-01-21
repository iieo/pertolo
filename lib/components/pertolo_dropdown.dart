import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pertolo/app.dart';

class PertoloDropdown<T> extends StatefulWidget {
  final List<DropdownMenuItem<T>>? items;
  final T value;
  final Function(T) onChanged;

  const PertoloDropdown(
      {super.key,
      required this.items,
      required this.value,
      required this.onChanged});

  @override
  State<PertoloDropdown> createState() => _PertoloDropdownState<T>();
}

class _PertoloDropdownState<T> extends State<PertoloDropdown> {
  @override
  Widget build(BuildContext context) {
    double width = max(200, MediaQuery.of(context).size.width - 100);
    double height = 60;
    return SizedBox(
        width: width,
        height: height,
        child: DropdownButton(
            value: widget.value,
            style: ThemeData.dark().textTheme.button,
            dropdownColor: App.secondaryColor,
            items: widget.items,
            onChanged: (var val) => widget.onChanged(val)));
  }
}
