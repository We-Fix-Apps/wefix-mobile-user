import 'package:flutter/material.dart';

class UsageDetailsWidget extends StatefulWidget {
  final String title;
  final int value;
  final int total;
  final Color color;
  const UsageDetailsWidget(
      {super.key,
      required this.title,
      required this.value,
      required this.total,
      required this.color});

  @override
  State<UsageDetailsWidget> createState() => _UsageDetailsWidgetState();
}

class _UsageDetailsWidgetState extends State<UsageDetailsWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.title),
              Text("${widget.value} / ${widget.total}"),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: widget.value / widget.total,
            borderRadius: BorderRadius.circular(5),
            backgroundColor: Colors.grey[300],
            color: widget.color,
            minHeight: 6,
          ),
        ],
      ),
    );
    ;
  }
}
