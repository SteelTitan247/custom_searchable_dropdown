import 'package:flutter/material.dart';

import '../custom_searchable_drop_down_item.dart';
import '../custom_searchable_dropdown.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Custom Dropdown Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: SingleChildScrollView(
            child: Center(
              child: CustomSearchableDropDown(
                title: 'Items',
                originalList: const [
                  CustomSearchableDropDownItem(displayText: 'Item 1', key: 1),
                  CustomSearchableDropDownItem(displayText: 'Item 2', key: 2),
                  CustomSearchableDropDownItem(displayText: 'Item 3', key: 3),
                ],
                onChanged: (value) {
                  debugPrint('Selected item: $value');
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
