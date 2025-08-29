import 'package:flutter/material.dart';

class SkillNode {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int xpRequired;
  bool isUnlocked;
  bool isCompleted;
  final List<SkillNode> children;

  SkillNode({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.xpRequired,
    required this.isUnlocked,
    required this.isCompleted,
    this.children = const [],
  });

  // Create a copy of this skill node with updated properties
  SkillNode copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    Color? color,
    int? xpRequired,
    bool? isUnlocked,
    bool? isCompleted,
    List<SkillNode>? children,
  }) {
    return SkillNode(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      xpRequired: xpRequired ?? this.xpRequired,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      children: children ?? this.children,
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon.codePoint,
      'color': color.value,
      'xpRequired': xpRequired,
      'isUnlocked': isUnlocked,
      'isCompleted': isCompleted,
      'children': children.map((child) => child.toJson()).toList(),
    };
  }

  // Create from JSON
  factory SkillNode.fromJson(Map<String, dynamic> json) {
    return SkillNode(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
      color: Color(json['color'] as int),
      xpRequired: json['xpRequired'] as int,
      isUnlocked: json['isUnlocked'] as bool,
      isCompleted: json['isCompleted'] as bool,
      children: (json['children'] as List<dynamic>)
          .map((child) => SkillNode.fromJson(child as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  String toString() {
    return 'SkillNode(id: $id, title: $title, isUnlocked: $isUnlocked, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SkillNode && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
