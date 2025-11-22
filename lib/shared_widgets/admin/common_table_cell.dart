import 'package:flutter/material.dart';

class CommonTableCell extends StatelessWidget {
  final dynamic content;
  final TextAlign align;
  final bool bold;
  final Color? color;
  final bool italic;

  const CommonTableCell(
    this.content, {
    super.key,
    this.align = TextAlign.left,
    this.bold = false,
    this.color,
    this.italic = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child:
          content is Widget
              ? content
              : Text(
                content.toString(),
                style: TextStyle(
                  fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
                  fontStyle: italic ? FontStyle.italic : FontStyle.normal,
                  color: color ?? Colors.black87,
                  fontSize: 14.5,
                ),
                textAlign: align,
              ),
    );
  }
}
