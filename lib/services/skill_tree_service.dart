import 'package:flutter/material.dart';
import '../models/skill_tree_models.dart';

class SkillTreeService {
  static final SkillTreeService _instance = SkillTreeService._internal();
  factory SkillTreeService() => _instance;
  SkillTreeService._internal();

  // Get the complete skill tree
  List<SkillNode> getSkillTree() {
    return [
      SkillNode(
        id: 'basics',
        title: 'Cybersecurity Basics',
        description: 'Learn fundamental security concepts',
        icon: Icons.security,
        color: Colors.blue,
        xpRequired: 0,
        isUnlocked: true,
        isCompleted: false,
        children: [
          SkillNode(
            id: 'networking',
            title: 'Network Security',
            description: 'Understand network protocols and security',
            icon: Icons.wifi,
            color: Colors.green,
            xpRequired: 200,
            isUnlocked: false,
            isCompleted: false,
          ),
          SkillNode(
            id: 'cryptography',
            title: 'Cryptography',
            description: 'Learn encryption and decryption',
            icon: Icons.lock,
            color: Colors.purple,
            xpRequired: 300,
            isUnlocked: false,
            isCompleted: false,
          ),
        ],
      ),
      SkillNode(
        id: 'forensics',
        title: 'Digital Forensics',
        description: 'Investigate cyber incidents',
        icon: Icons.search,
        color: Colors.orange,
        xpRequired: 500,
        isUnlocked: false,
        isCompleted: false,
        children: [
          SkillNode(
            id: 'log_analysis',
            title: 'Log Analysis',
            description: 'Analyze system and security logs',
            icon: Icons.analytics,
            color: Colors.red,
            xpRequired: 700,
            isUnlocked: false,
            isCompleted: false,
          ),
          SkillNode(
            id: 'memory_analysis',
            title: 'Memory Analysis',
            description: 'Examine RAM for evidence',
            icon: Icons.memory,
            color: Colors.indigo,
            xpRequired: 800,
            isUnlocked: false,
            isCompleted: false,
          ),
        ],
      ),
      SkillNode(
        id: 'malware',
        title: 'Malware Analysis',
        description: 'Analyze malicious software',
        icon: Icons.bug_report,
        color: Colors.red,
        xpRequired: 1000,
        isUnlocked: false,
        isCompleted: false,
        children: [
          SkillNode(
            id: 'static_analysis',
            title: 'Static Analysis',
            description: 'Examine code without execution',
            icon: Icons.code,
            color: Colors.teal,
            xpRequired: 1200,
            isUnlocked: false,
            isCompleted: false,
          ),
          SkillNode(
            id: 'dynamic_analysis',
            title: 'Dynamic Analysis',
            description: 'Analyze behavior in sandbox',
            icon: Icons.play_circle,
            color: Colors.amber,
            xpRequired: 1400,
            isUnlocked: false,
            isCompleted: false,
          ),
        ],
      ),
      SkillNode(
        id: 'incident_response',
        title: 'Incident Response',
        description: 'Handle security incidents',
        icon: Icons.emergency,
        color: Colors.deepOrange,
        xpRequired: 1500,
        isUnlocked: false,
        isCompleted: false,
        children: [
          SkillNode(
            id: 'containment',
            title: 'Threat Containment',
            description: 'Isolate and contain threats',
            icon: Icons.block,
            color: Colors.deepPurple,
            xpRequired: 1700,
            isUnlocked: false,
            isCompleted: false,
          ),
          SkillNode(
            id: 'recovery',
            title: 'System Recovery',
            description: 'Restore systems after incidents',
            icon: Icons.restore,
            color: Colors.lightGreen,
            xpRequired: 1900,
            isUnlocked: false,
            isCompleted: false,
          ),
        ],
      ),
    ];
  }

  // Update skill tree based on user XP
  void updateSkillTree(List<SkillNode> skillTree, int userXp) {
    for (final skill in skillTree) {
      skill.isUnlocked = userXp >= skill.xpRequired;
      _updateSkillChildren(skill, userXp);
    }
  }

  void _updateSkillChildren(SkillNode skill, int userXp) {
    for (final child in skill.children) {
      child.isUnlocked = userXp >= child.xpRequired;
      _updateSkillChildren(child, userXp);
    }
  }

  // Get skill by ID
  SkillNode? getSkillById(String id, List<SkillNode> skillTree) {
    for (final skill in skillTree) {
      if (skill.id == id) return skill;
      final childSkill = _findSkillInChildren(skill, id);
      if (childSkill != null) return childSkill;
    }
    return null;
  }

  SkillNode? _findSkillInChildren(SkillNode parent, String id) {
    for (final child in parent.children) {
      if (child.id == id) return child;
      final grandChild = _findSkillInChildren(child, id);
      if (grandChild != null) return grandChild;
    }
    return null;
  }

  // Get next available skill
  SkillNode? getNextAvailableSkill(List<SkillNode> skillTree, int userXp) {
    for (final skill in skillTree) {
      if (userXp >= skill.xpRequired && !skill.isCompleted) {
        return skill;
      }
      final nextChild = _getNextAvailableChild(skill, userXp);
      if (nextChild != null) return nextChild;
    }
    return null;
  }

  SkillNode? _getNextAvailableChild(SkillNode parent, int userXp) {
    for (final child in parent.children) {
      if (userXp >= child.xpRequired && !child.isCompleted) {
        return child;
      }
      final nextGrandChild = _getNextAvailableChild(child, userXp);
      if (nextGrandChild != null) return nextGrandChild;
    }
    return null;
  }

  // Get total skills count
  int getTotalSkillsCount(List<SkillNode> skillTree) {
    int count = 0;
    for (final skill in skillTree) {
      count++;
      count += _getChildrenCount(skill);
    }
    return count;
  }

  int _getChildrenCount(SkillNode skill) {
    int count = 0;
    for (final child in skill.children) {
      count++;
      count += _getChildrenCount(child);
    }
    return count;
  }

  // Get unlocked skills count
  int getUnlockedSkillsCount(List<SkillNode> skillTree) {
    int count = 0;
    for (final skill in skillTree) {
      if (skill.isUnlocked) count++;
      count += _getUnlockedChildrenCount(skill);
    }
    return count;
  }

  int _getUnlockedChildrenCount(SkillNode skill) {
    int count = 0;
    for (final child in skill.children) {
      if (child.isUnlocked) count++;
      count += _getUnlockedChildrenCount(child);
    }
    return count;
  }
}
