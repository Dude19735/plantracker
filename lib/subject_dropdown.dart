import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';

/// Flutter code sample for [DropdownMenu].

const List<String> list = <String>['One', 'Two', 'Three', 'Four'];

class SubjectDropdown extends StatefulWidget {
  final GlobalContext _globalContext;

  const SubjectDropdown(this._globalContext);

  @override
  State<SubjectDropdown> createState() => _SubjectDropdown();
}

class _SubjectDropdown extends State<SubjectDropdown> {
  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return DropdownMenu<String>(
        width: constraints.maxWidth,
        initialSelection: list.first,
        onSelected: (String? value) {
          // This is called when the user selects an item.
          setState(() {
            dropdownValue = value!;
          });
        },
        dropdownMenuEntries:
            list.map<DropdownMenuEntry<String>>((String value) {
          return DropdownMenuEntry<String>(value: value, label: value);
        }).toList(),
      );
    });
  }
}
