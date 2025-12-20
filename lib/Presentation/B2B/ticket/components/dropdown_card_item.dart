import 'package:flutter/material.dart';

class DropdownCardItem {
  final int id;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? iconWidget;
  final Map<String, dynamic>? data;

  DropdownCardItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconWidget,
    this.data,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DropdownCardItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

