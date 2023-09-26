import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';

/// Flutter code sample for [DropdownMenu].

const List<String> list = <String>['One', 'Two', 'Three', 'Four'];

class SubjectDropdown extends StatefulWidget {
  @override
  State<SubjectDropdown> createState() => _SubjectDropdown();
}

class _SubjectDropdown extends State<SubjectDropdown> {
  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return DropdownButtonHideUnderline(
        child: DropdownButton<String>(
            value: dropdownValue,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            style: const TextStyle(color: Colors.deepPurple),
            isExpanded: true,
            // underline: Container(
            //   height: 2,
            //   color: Colors.deepPurpleAccent,
            // ),
            onChanged: (String? value) {
              // This is called when the user selects an item.
              setState(() {
                dropdownValue = value!;
              });
            },
            items: list.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(value),
                ),
              );
            }).toList()),
      );
    });
  }
}
