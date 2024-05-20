import 'package:flutter/material.dart';

import 'custom_searchable_drop_down_item.dart';

extension GlobalKeyExtension on GlobalKey {
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      final offset = Offset(translation.x, translation.y);
      return renderObject!.paintBounds.shift(offset);
    } else {
      return null;
    }
  }
}

class CustomSearchableDropDown extends StatefulWidget {
  final List<CustomSearchableDropDownItem> originalList;
  final String? title;
  final TextOverflow? textOverflow;
  final void Function(dynamic) onChanged;
  final bool? autoInitialize;
  final String? loadingText;
  final CustomSearchableDropDownItem? initialValue;
  final TextStyle? textStyle;

  const CustomSearchableDropDown({
    super.key,
    required this.originalList,
    required this.onChanged,
    this.textOverflow,
    this.autoInitialize,
    required this.title,
    this.loadingText,
    this.initialValue,
    this.textStyle
  });

  @override
  State<CustomSearchableDropDown> createState() =>
      _CustomSearchableDropDownState();
}

class _CustomSearchableDropDownState<T>
    extends State<CustomSearchableDropDown> {
  TextEditingController controller = TextEditingController();
  ValueNotifier<List<CustomSearchableDropDownItem>> list = ValueNotifier([]);
  CustomSearchableDropDownItem? _selectedData;
  OverlayEntry? _overlayEntry;
  final GlobalKey _key = GlobalKey();
  ScrollController scrollController = ScrollController();

  ValueNotifier<bool> show = ValueNotifier(false);

  @override
  void initState() {
    list.value = widget.originalList;
    if (widget.autoInitialize == true && widget.originalList.isNotEmpty) {
      // _selectedData = widget.originalList[0];
    } else if (widget.initialValue != null) {
      for (var v in widget.originalList) {
        if (v == widget.initialValue) {
          _selectedData = widget.initialValue;
        }
      }
    }

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _overlayEntry = _createOverlayEntry();
        if (_overlayEntry != null) {
          Overlay.of(context).insert(_overlayEntry!);
        }
      } else {
        _overlayEntry?.remove();
        show.value = false;
      }
    });

    super.initState();
  }

  @override
  void didUpdateWidget(covariant CustomSearchableDropDown oldWidget) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (oldWidget.originalList != widget.originalList) {
        list.value = widget.originalList;
      }
    });
    super.didUpdateWidget(oldWidget);
  }

  double getHeight(entries) {
    if (entries == 0) {
      return 20;
    } else if (entries == 1) {
      return 50;
    } else if (entries == 2) {
      return 100;
    } else if (entries == 3) {
      return 140;
    } else if (entries == 4) {
      return 180;
    } else {
      return 224;
    }
  }

  OverlayEntry _createOverlayEntry() {
    Rect? bounds = _key.globalPaintBounds;

    return OverlayEntry(
      builder: (context) => Positioned(
        left: bounds?.left,
        top: (bounds?.top ?? 0) + 48 + 3,
        width: bounds?.width,
        child: TapRegion(
          onTapOutside: (tap) {
            _overlayEntry?.remove();
            show.value = false;
            controller.clear();
          },
          child: Material(
            elevation: 4.0,
            child: SizedBox(
              child: ValueListenableBuilder(
                valueListenable: list,
                builder: (context, myList, child) {
                  return SizedBox(
                    height: getHeight(myList.length),
                    child: Scrollbar(
                      controller: scrollController,
                      thumbVisibility: true,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        controller: scrollController,
                        itemCount: myList.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              _selectedData = myList[index];
                              show.value = false;
                              _overlayEntry?.remove();
                              widget.onChanged(
                                myList[index],
                              );
                              controller.clear();
                              list.value = widget.originalList;
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 12),
                              child: Text(
                                myList[index].displayText,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _filterResults(String query) {
    List<CustomSearchableDropDownItem> duplicateItems = [];
    duplicateItems = widget.originalList.where((item) {
      if(item.displayText.toLowerCase().contains(query.toLowerCase())) {
        return true;
      }
      return false;
    }).toList();
    list.value = duplicateItems;
  }

  final FocusNode _focusNode = FocusNode();

  String getDisplayText() {
    if (widget.loadingText != null) {
      return widget.loadingText ?? 'Loading...';
    }
    if (widget.originalList.isEmpty) {
      return "Select ${widget.title}";
    }

    return _selectedData?.displayText??'Select ${widget.title}';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: show,
      builder: (context, val, child) {
        return val == false
            ? InkWell(
          onTap: () {
            show.value = true;
          },
          child: SizedBox(
            height: 48,
            width: double.infinity,
            child: InputDecorator(
              decoration: InputDecoration(
                label: Text(
                  widget.title ?? '',
                  style: const TextStyle(color: Colors.black),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
                suffixIcon: _selectedData != null
                    ? Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedData = null;
                      });
                      widget.onChanged(null);
                    },
                    child: const Icon(
                      Icons.cancel,
                      size: 20,
                    ),
                  ),
                )
                    : const Icon(
                  Icons.arrow_drop_down,
                ),
                prefix: Padding(
                  padding: const EdgeInsets.only(top: 2, right: 16),
                  child: Text(
                    getDisplayText(),
                    style: widget.textStyle,
                    overflow:
                    widget.textOverflow ?? TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        )
            : SizedBox(
          height: 48,
          width: double.infinity,
          child: TextField(
            key: _key,
            controller: controller,
            focusNode: _focusNode,
            autofocus: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(bottom: 4, left: 12),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Colors.blue)),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Colors.blue)),
              labelText: widget.title,
            ),
            onChanged: (value) {
              _filterResults(value);
            },
            onSubmitted: (value) {
              show.value = false;
            },
          ),
        );
      },
    );
  }
}
