import 'package:flutter/material.dart';

class AddressTypeWidget extends StatelessWidget {
  final IconData icon;
  final String label;

  const AddressTypeWidget({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey[200],
          child: Icon(icon, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
    ;
  }
}
