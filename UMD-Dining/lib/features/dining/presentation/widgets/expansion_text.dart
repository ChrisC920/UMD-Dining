import 'package:flutter/material.dart';

class ExpandableTextRow extends StatefulWidget {
  const ExpandableTextRow({super.key, required this.row, required this.dropdown});
  final Widget row;
  final Widget dropdown;

  @override
  _ExpandableTextRowState createState() => _ExpandableTextRowState();
}

class _ExpandableTextRowState extends State<ExpandableTextRow> {
  Widget get row => widget.row;
  Widget get dropdown => widget.dropdown;
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => isExpanded = !isExpanded),
          child: Container(
            color: Colors.transparent,
            child: Row(
              children: [
                Expanded(child: row),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: isExpanded ? 0 : 0.25, // 0.5 turn = 180 degrees
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.expand_more),
                ),
              ],
            ),
          ),
        ),
        // if (isExpanded) dropdown,
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.fastOutSlowIn,
          child: ConstrainedBox(
            constraints: isExpanded ? const BoxConstraints() : const BoxConstraints(maxHeight: 0),
            child: dropdown,
          ),
        ),
      ],
    );
  }
}
