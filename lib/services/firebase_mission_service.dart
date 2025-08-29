import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mission_models.dart';
import '../data/kenyan_cybersecurity_content.dart';
import 'progress_service.dart';

class FirebaseMissionService {
  // Singleton pattern
  static final FirebaseMissionService _instance = FirebaseMissionService._internal();
  factory FirebaseMissionService() => _instance;
  FirebaseMissionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProgressService _progressService = ProgressService();
  
  // Local cache of missions (Firebase + Kenyan)
  List<Mission> _cachedMissions = [];
  
  // Method to clear cache and force refresh
  void clearCache() {
    _cachedMissions.clear();
  }
  
  // Local Kenyan missions
  List<Mission> get _kenyanMissions => KenyanCybersecurityContent.getAllKenyanMissions();

  // Get all missions
  Future<List<Mission>> getMissions() async {
    try {
      // Check if we have cached missions
      if (_cachedMissions.isNotEmpty) {
        await _updateMissionStatusFromProgress(_cachedMissions);
        return _cachedMissions;
      }
      
      // Get missions from Firestore
      final snapshot = await _firestore.collection('missions').get();
      
      // Convert to Mission objects using safe parsing
      final firebaseMissions = snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          return Mission.fromJson({
            'id': doc.id,
            ...data,
            // Convert Timestamp to ISO string for proper parsing
            'unlockDate': data['unlockDate'] != null
                ? (data['unlockDate'] as Timestamp).toDate().toIso8601String()
                : null,
            'expiryDate': data['expiryDate'] != null
                ? (data['expiryDate'] as Timestamp).toDate().toIso8601String()
                : null,
          });
        } catch (e) {
          print('Error parsing mission ${doc.id}: $e');
          // Return null for failed missions, we'll filter them out
          return null;
        }
      }).whereType<Mission>().toList();
      
      // Combine Firebase missions with fallback missions and Kenyan missions
      final allMissions = [..._fallbackMissions, ...firebaseMissions, ..._kenyanMissions];
      
      // Cache missions
      _cachedMissions = allMissions;
      print('Loaded ${_fallbackMissions.length} fallback missions, ${firebaseMissions.length} Firebase missions and ${_kenyanMissions.length} Kenyan missions');
      print('Total missions: ${_cachedMissions.length}');
      
      // Debug: Print mission details
      for (final mission in allMissions) {
        print('Mission: ${mission.title} (${mission.type}) - ${mission.challenges.length} challenges');
        if (mission.challenges.isNotEmpty) {
          for (final challenge in mission.challenges) {
            print('  Challenge: ${challenge.title} (${challenge.type})');
            if (challenge.content.dataPayload.containsKey('questions')) {
              final questions = challenge.content.dataPayload['questions'] as List;
              print('    Questions: ${questions.length}');
            }
          }
        }
      }
      
      // Update mission status based on user progress
      await _updateMissionStatusFromProgress(_cachedMissions);
      
      return _cachedMissions;
    } catch (e) {
      print('Error getting missions: $e');
      
      // If Firebase fails, fall back to hardcoded missions + Kenyan missions
      print('Using fallback missions due to Firebase error');
      final fallbackMissions = [..._fallbackMissions, ..._kenyanMissions];
      _cachedMissions = fallbackMissions;
      print('Loaded ${_fallbackMissions.length} fallback missions and ${_kenyanMissions.length} Kenyan missions');
      return fallbackMissions;
    }
  }

  // Start a mission
  Future<Mission> startMission(String missionId) async {
    try {
      // Ensure missions are loaded
      if (_cachedMissions.isEmpty) {
        await getMissions();
      }
      
      // Get the mission
      final missionIndex = _cachedMissions.indexWhere((m) => m.id == missionId);
      if (missionIndex == -1) {
        throw Exception('Mission not found: $missionId. Available missions: ${_cachedMissions.map((m) => m.id).join(', ')}');
      }

      // Create a new mission with updated status
      final mission = _cachedMissions[missionIndex];
      final updatedMission = Mission(
        id: mission.id,
        title: mission.title,
        description: mission.description,
        type: mission.type,
        difficulty: mission.difficulty,
        category: mission.category,
        status: MissionStatus.inProgress,
        requiredLevel: mission.requiredLevel,
        xpReward: mission.xpReward,
        gemReward: mission.gemReward,
        challenges: mission.challenges,
        imageUrl: mission.imageUrl,
        unlockDate: mission.unlockDate,
        expiryDate: mission.expiryDate,
      );

      // Update the mission in our cache
      _cachedMissions[missionIndex] = updatedMission;

      // Update user progress in Firebase
      await _progressService.startMission(missionId);

      return updatedMission;
    } catch (e) {
      print('Error starting mission: $e');
      throw Exception('Failed to start mission');
    }
  }

  // Complete a mission
  Future<Mission> completeMission(String missionId) async {
    try {
      // Get the mission
      final missionIndex = _cachedMissions.indexWhere((m) => m.id == missionId);
      if (missionIndex == -1) {
        throw Exception('Mission not found');
      }

      // Create a new mission with updated status
      final mission = _cachedMissions[missionIndex];
      final updatedMission = Mission(
        id: mission.id,
        title: mission.title,
        description: mission.description,
        type: mission.type,
        difficulty: mission.difficulty,
        category: mission.category,
        status: MissionStatus.completed,
        requiredLevel: mission.requiredLevel,
        xpReward: mission.xpReward,
        gemReward: mission.gemReward,
        challenges: mission.challenges,
        imageUrl: mission.imageUrl,
        unlockDate: mission.unlockDate,
        expiryDate: mission.expiryDate,
      );

      // Update the mission in our cache
      _cachedMissions[missionIndex] = updatedMission;

      // Update user progress in Firebase
      await _progressService.completeMission(missionId, mission);

      return updatedMission;
    } catch (e) {
      print('Error completing mission: $e');
      throw Exception('Failed to complete mission');
    }
  }

  // Update mission progress
  Future<void> updateMissionProgress(String missionId, int progress) async {
    try {
      await _progressService.updateMissionProgress(missionId, progress);
    } catch (e) {
      print('Error updating mission progress: $e');
      throw Exception('Failed to update mission progress');
    }
  }

  // Get mission by ID
  Future<Mission> getMissionById(String missionId) async {
    try {
      // Check if we have cached missions
      if (_cachedMissions.isNotEmpty) {
        final mission = _cachedMissions.firstWhere(
          (m) => m.id == missionId,
          orElse: () => throw Exception('Mission not found'),
        );
        return mission;
      }
      
      // Get missions from Firestore
      final doc = await _firestore.collection('missions').doc(missionId).get();
      
      if (!doc.exists) {
        throw Exception('Mission not found');
      }
      
      final data = doc.data()!;
      return Mission(
        id: doc.id,
        title: data['title'] as String,
        description: data['description'] as String,
        type: MissionType.values.firstWhere(
          (e) => e.toString() == data['type'],
        ),
        difficulty: MissionDifficulty.values.firstWhere(
          (e) => e.toString() == data['difficulty'],
        ),
        category: MissionCategory.values.firstWhere(
          (e) => e.toString() == data['category'],
        ),
        status: MissionStatus.values.firstWhere(
          (e) => e.toString() == data['status'],
        ),
        requiredLevel: data['requiredLevel'] as int,
        xpReward: data['xpReward'] as int,
        gemReward: data['gemReward'] as int,
        challenges: (data['challenges'] as List)
            .map((c) => Challenge.fromJson(c as Map<String, dynamic>))
            .toList(),
        imageUrl: data['imageUrl'] as String?,
        unlockDate: data['unlockDate'] != null
            ? (data['unlockDate'] as Timestamp).toDate()
            : null,
        expiryDate: data['expiryDate'] != null
            ? (data['expiryDate'] as Timestamp).toDate()
            : null,
      );
    } catch (e) {
      print('Error getting mission by ID: $e');
      
      // If Firebase fails, fall back to hardcoded missions + Kenyan missions
      final allFallbackMissions = [..._fallbackMissions, ..._kenyanMissions];
      final mission = allFallbackMissions.firstWhere(
        (m) => m.id == missionId,
        orElse: () => throw Exception('Mission not found: $missionId. Available missions: ${allFallbackMissions.map((m) => m.id).join(', ')}'),
      );
      return mission;
    }
  }

  // Update mission status based on user progress
  Future<void> _updateMissionStatusFromProgress(List<Mission> missions) async {
    try {
      // Get user progress
      final userData = await _progressService.getUserProgress();
      if (userData == null) return;
      
      // Get completed missions
      final completedMissions = userData.missionProgress
          .where((m) => m.isCompleted)
          .map((m) => m.missionId)
          .toSet();
      
      // Get in-progress missions
      final inProgressMissions = userData.missionProgress
          .where((m) => !m.isCompleted)
          .map((m) => m.missionId)
          .toSet();
      
      // Update mission status
      for (var i = 0; i < missions.length; i++) {
        if (completedMissions.contains(missions[i].id)) {
          missions[i] = missions[i].copyWith(
            status: MissionStatus.completed,
          );
        } else if (inProgressMissions.contains(missions[i].id)) {
          missions[i] = missions[i].copyWith(
            status: MissionStatus.inProgress,
          );
        } else if (missions[i].requiredLevel > userData.level) {
          missions[i] = missions[i].copyWith(
            status: MissionStatus.locked,
          );
        } else {
          missions[i] = missions[i].copyWith(
            status: MissionStatus.available,
          );
        }
      }
    } catch (e) {
      print('Error updating mission status: $e');
    }
  }

  // Fallback missions if Firebase fails
  static final List<Mission> _fallbackMissions = [
    // Mission 1: Beginner Phishing Quiz
    Mission(
      id: 'M001',
      title: 'Spot the Phish',
      description: 'Test your skills at identifying phishing attempts in this interactive quiz. Can you spot the red flags?',
      type: MissionType.interactiveQuiz,
      difficulty: MissionDifficulty.beginner,
      category: MissionCategory.phishing,
      status: MissionStatus.available,
      requiredLevel: 1,
      xpReward: 100,
      gemReward: 50,
      challenges: [
        Challenge(
          id: 'C001',
          title: 'Email Analysis',
          description: 'Analyze suspicious emails and identify phishing indicators',
          type: ChallengeType.multipleChoice,
          content: ChallengeContent(
            dataType: 'quiz_questions',
            toolType: 'multiple_choice',
            solution: 'B,A,C,A,B',
            guidePoints: [
              'Check the sender\'s email address carefully',
              'Look for urgency or threatening language',
              'Examine links before clicking',
              'Watch for spelling and grammar errors',
            ],
            dataPayload: {
              'questions': [
                {
                  'question': 'Which of these is a sign of a phishing email?',
                  'options': [
                    'Professional greeting',
                    'Urgent demand for action',
                    'Company logo',
                    'Clear signature'
                  ],
                  'correct': 1
                }
              ]
            },
          ),
          xpReward: 100,
        ),
      ],
      imageUrl: 'assets/images/phishing.png',
    ),

    // Mission 2: Web Traffic Analysis
    Mission(
      id: 'M002',
      title: 'Web Traffic Detective',
      description: 'Analyze suspicious web traffic patterns and identify potential security threats using the Analyst\'s Workbench.',
      type: MissionType.scamSimulator,
      difficulty: MissionDifficulty.intermediate,
      category: MissionCategory.networkSecurity,
      status: MissionStatus.available,
      requiredLevel: 2,
      xpReward: 200,
      gemReward: 75,
      challenges: [
        Challenge(
          id: 'C002',
          title: 'Malicious Traffic Hunt',
          description: 'Use the web filter tool to analyze traffic logs and identify suspicious patterns',
          type: ChallengeType.workbench,
          content: ChallengeContent(
            dataType: 'web_traffic_logs',
            toolType: 'web_filter',
            solution: 'IP:192.168.1.45 PORT:8080',
            guidePoints: [
              'Look for unusual port numbers',
              'Check for known malicious IP addresses',
              'Identify suspicious data patterns',
              'Analyze request frequencies',
            ],
            dataPayload: {
              'logs': [
                {'timestamp': '2024-03-10 10:15:23', 'src_ip': '192.168.1.100', 'dst_ip': '8.8.8.8', 'port': '53', 'protocol': 'DNS', 'status': 'normal'},
                {'timestamp': '2024-03-10 10:15:24', 'src_ip': '192.168.1.45', 'dst_ip': '203.0.113.42', 'port': '8080', 'protocol': 'HTTP', 'status': 'suspicious'},
                {'timestamp': '2024-03-10 10:15:25', 'src_ip': '192.168.1.101', 'dst_ip': '8.8.4.4', 'port': '53', 'protocol': 'DNS', 'status': 'normal'},
                {'timestamp': '2024-03-10 10:15:26', 'src_ip': '192.168.1.45', 'dst_ip': '203.0.113.42', 'port': '8080', 'protocol': 'HTTP', 'status': 'suspicious'},
                {'timestamp': '2024-03-10 10:15:27', 'src_ip': '192.168.1.102', 'dst_ip': '172.217.3.110', 'port': '443', 'protocol': 'HTTPS', 'status': 'normal'},
              ]
            },
          ),
          xpReward: 200,
        ),
      ],
      imageUrl: 'assets/images/network.png',
    ),

    // Mission 3: Terminal Challenge
    Mission(
      id: 'M003',
      title: 'Rogue Process Hunter',
      description: 'Track down and eliminate a suspicious process in this advanced terminal simulation challenge.',
      type: MissionType.terminalChallenge,
      difficulty: MissionDifficulty.advanced,
      category: MissionCategory.forensics,
      status: MissionStatus.available,
      requiredLevel: 1,
      xpReward: 300,
      gemReward: 100,
      challenges: [
        Challenge(
          id: 'C003',
          title: 'Process Investigation',
          description: 'Use terminal commands to investigate and terminate a suspicious process',
          type: ChallengeType.terminal,
          content: ChallengeContent(
            dataType: 'terminal_output',
            toolType: 'terminal_commands',
            solution: 'kill -9 12345',
            guidePoints: [
              'Use ps command to list processes',
              'Check process details with top',
              'Investigate suspicious PIDs',
              'Use kill command safely',
            ],
            dataPayload: {
              'session': [
                {'type': 'command', 'content': 'ps aux | grep suspicious'},
                {'type': 'output', 'content': 'user    12345  99.0  5.0 123456 54321 ?    R    10:00   0:00 suspicious_process'},
                {'type': 'command', 'content': 'lsof -p 12345'},
                {'type': 'output', 'content': 'suspicious_process 12345 user  txt    REG   8,1    12345 /tmp/malicious'},
                {'type': 'command', 'content': 'netstat -tuln | grep 12345'},
                {'type': 'output', 'content': 'tcp    0    0 0.0.0.0:31337    0.0.0.0:*    LISTEN    12345/suspicious_p'},
              ]
            },
          ),
          xpReward: 300,
        ),
      ],
      imageUrl: 'assets/images/terminal.png',
    ),

    // Mission 4: Password Lab Challenge
    Mission(
      id: 'M004',
      title: 'The Password Lab',
      description: 'Your mission is to forge a password strong enough to meet all security protocols. Our system will validate your creation in real-time.',
      type: MissionType.passwordLab,
      difficulty: MissionDifficulty.beginner,
      category: MissionCategory.cryptography,
      status: MissionStatus.available,
      requiredLevel: 1,
      xpReward: 150,
      gemReward: 60,
      challenges: [
        Challenge(
          id: 'C004',
          title: 'Password Creation',
          description: 'Create a password that meets all security criteria and passes real-time validation',
          type: ChallengeType.passwordValidation,
          content: ChallengeContent(
            dataType: 'password_validation',
            toolType: 'password_lab',
            solution: 'STRONG_PASSWORD_123!@#',
            guidePoints: [
              'Use at least 12 characters',
              'Include uppercase and lowercase letters',
              'Add numbers and special characters',
              'Avoid common patterns and words',
              'Ensure uniqueness and complexity',
            ],
            dataPayload: {
              'criteria': [
                'length_12_plus',
                'uppercase_required',
                'lowercase_required',
                'numbers_required',
                'special_chars_required',
                'no_common_patterns'
              ]
            },
          ),
          xpReward: 150,
        ),
      ],
      imageUrl: 'assets/images/password.png',
    ),

    // Skill Tree: Network Security (Networking)
    Mission(
      id: 'M101',
      title: 'Network Fundamentals Quiz',
      description: 'Test core networking and security fundamentals: ports, protocols, and safe configurations.',
      type: MissionType.interactiveQuiz,
      difficulty: MissionDifficulty.beginner,
      category: MissionCategory.networkSecurity,
      status: MissionStatus.available,
      requiredLevel: 1,
      xpReward: 120,
      gemReward: 40,
      challenges: [
        Challenge(
          id: 'C101',
          title: 'Networking Basics',
          description: 'Identify secure protocols and best practices.',
          type: ChallengeType.multipleChoice,
          content: ChallengeContent(
            dataType: 'quiz_questions',
            toolType: 'multiple_choice',
            solution: '1,2,0',
            guidePoints: [
              'Prefer encrypted protocols over plaintext',
              'Know common secure ports (e.g., 443 for HTTPS)',
              'Disable unused services/ports',
            ],
            dataPayload: {
              'questions': [
                {
                  'question': 'Which protocol securely encrypts web traffic by default?',
                  'options': ['HTTP', 'HTTPS', 'FTP', 'Telnet'],
                  'correct': 1
                },
                {
                  'question': 'Which port is commonly used for HTTPS?',
                  'options': ['80', '21', '443', '25'],
                  'correct': 2
                },
                {
                  'question': 'Which is the best initial hardening step on a new server?',
                  'options': [
                    'Disable unused services and close unnecessary ports',
                    'Enable guest accounts',
                    'Use default credentials for simplicity',
                    'Expose SSH to the internet without keys'
                  ],
                  'correct': 0
                }
              ]
            },
          ),
          xpReward: 120,
        ),
      ],
      imageUrl: null,
    ),

    // Skill Tree: Cryptography
    Mission(
      id: 'M102',
      title: 'Cryptography Basics Quiz',
      description: 'Understand encryption at rest/in transit and identify strong practices.',
      type: MissionType.interactiveQuiz,
      difficulty: MissionDifficulty.beginner,
      category: MissionCategory.cryptography,
      status: MissionStatus.available,
      requiredLevel: 1,
      xpReward: 130,
      gemReward: 45,
      challenges: [
        Challenge(
          id: 'C102',
          title: 'Crypto Fundamentals',
          description: 'Choose correct cryptography concepts and controls.',
          type: ChallengeType.multipleChoice,
          content: ChallengeContent(
            dataType: 'quiz_questions',
            toolType: 'multiple_choice',
            solution: '2,1,1',
            guidePoints: [
              'Prefer modern algorithms (AES, TLS 1.2+)',
              'Use hashing for integrity, not confidentiality',
              'Rotate keys periodically',
            ],
            dataPayload: {
              'questions': [
                {
                  'question': 'Which algorithm is recommended for symmetric encryption today?',
                  'options': ['DES', 'RC4', 'AES', 'MD5'],
                  'correct': 2
                },
                {
                  'question': 'What is hashing primarily used for?',
                  'options': ['Confidentiality', 'Integrity verification', 'Key exchange', 'Compression'],
                  'correct': 1
                },
                {
                  'question': 'Which is a good key management practice?',
                  'options': ['Share private keys via email', 'Rotate keys regularly', 'Hardcode keys in apps', 'Use weak passphrases'],
                  'correct': 1
                }
              ]
            },
          ),
          xpReward: 130,
        ),
      ],
      imageUrl: null,
    ),

    // Skill Tree: Digital Forensics → Log Analysis
    Mission(
      id: 'M201',
      title: 'Log Analysis Basics',
      description: 'Identify suspicious events in system and security logs.',
      type: MissionType.interactiveQuiz,
      difficulty: MissionDifficulty.intermediate,
      category: MissionCategory.forensics,
      status: MissionStatus.available,
      requiredLevel: 2,
      xpReward: 180,
      gemReward: 60,
      challenges: [
        Challenge(
          id: 'C201',
          title: 'Spot the Anomaly',
          description: 'Recognize indicators of compromise in logs.',
          type: ChallengeType.multipleChoice,
          content: ChallengeContent(
            dataType: 'quiz_questions',
            toolType: 'multiple_choice',
            solution: '0,0,1',
            guidePoints: [
              'Look for repeated failed logins',
              'Unexpected privilege escalations are high-risk',
              'Off-hours admin actions are suspicious',
            ],
            dataPayload: {
              'questions': [
                {
                  'question': 'Which entry is most suspicious?',
                  'options': [
                    '50 failed SSH logins from the same IP',
                    'Daily successful cron jobs',
                    'Regular web server access logs',
                    'Periodic backup completion logs'
                  ],
                  'correct': 0
                },
                {
                  'question': 'What log pattern may indicate privilege escalation?',
                  'options': [
                    'User switching to root without sudo logs',
                    'User running a normal command',
                    'User logging out',
                    'Cron job started'
                  ],
                  'correct': 0
                },
                {
                  'question': 'Which timing pattern is suspicious for admin activity?',
                  'options': ['During business hours', 'Unusual off-hours activity', 'After a planned change window', 'During maintenance'],
                  'correct': 1
                }
              ]
            },
          ),
          xpReward: 180,
        ),
      ],
      imageUrl: null,
    ),

    // Skill Tree: Digital Forensics → Memory Analysis
    Mission(
      id: 'M202',
      title: 'Memory Analysis Fundamentals',
      description: 'Understand volatile memory artifacts and what they reveal.',
      type: MissionType.interactiveQuiz,
      difficulty: MissionDifficulty.intermediate,
      category: MissionCategory.forensics,
      status: MissionStatus.available,
      requiredLevel: 2,
      xpReward: 190,
      gemReward: 65,
      challenges: [
        Challenge(
          id: 'C202',
          title: 'Volatile Evidence',
          description: 'Choose correct interpretations of memory artifacts.',
          type: ChallengeType.multipleChoice,
          content: ChallengeContent(
            dataType: 'quiz_questions',
            toolType: 'multiple_choice',
            solution: '1,1,2',
            guidePoints: [
              'RAM holds running processes and decrypted data',
              'Order of volatility matters',
              'Look for injected DLLs and suspicious handles',
            ],
            dataPayload: {
              'questions': [
                {
                  'question': 'Which information is commonly found in RAM?',
                  'options': ['Disk slack space', 'Decrypted credentials in-use', 'Only logs', 'Only encrypted blobs'],
                  'correct': 1
                },
                {
                  'question': 'Order of volatility suggests analyzing:',
                  'options': ['Disk first, then memory', 'Memory first, then disk', 'Only logs', 'Only registry'],
                  'correct': 1
                },
                {
                  'question': 'Which may indicate code injection?',
                  'options': ['Signed driver', 'Normal process list', 'Suspicious DLL in a benign process', 'System uptime'],
                  'correct': 2
                }
              ]
            },
          ),
          xpReward: 190,
        ),
      ],
      imageUrl: null,
    ),

    // Skill Tree: Malware Analysis → Static Analysis
    Mission(
      id: 'M301',
      title: 'Static Malware Analysis',
      description: 'Identify capabilities from binaries without execution.',
      type: MissionType.interactiveQuiz,
      difficulty: MissionDifficulty.intermediate,
      category: MissionCategory.malware,
      status: MissionStatus.available,
      requiredLevel: 2,
      xpReward: 200,
      gemReward: 70,
      challenges: [
        Challenge(
          id: 'C301',
          title: 'Code Clues',
          description: 'Spot obfuscation and malicious capabilities statically.',
          type: ChallengeType.multipleChoice,
          content: ChallengeContent(
            dataType: 'quiz_questions',
            toolType: 'multiple_choice',
            solution: '2,1,2',
            guidePoints: [
              'Look for suspicious imports/strings',
              'Packing/obfuscation hints capabilities',
              'YARA-like indicators help triage',
            ],
            dataPayload: {
              'questions': [
                {
                  'question': 'Which string likely indicates C2 behavior?',
                  'options': ['/var/log', 'printf', 'hxxp://c2.bad.example', 'LICENSE'],
                  'correct': 2
                },
                {
                  'question': 'What does UPX packing often indicate?',
                  'options': ['Benign documentation', 'Possible obfuscation/compression', 'Signed driver', 'Normal debug info'],
                  'correct': 1
                },
                {
                  'question': 'A quick triage method includes:',
                  'options': ['Running it as admin', 'Submitting to random sites', 'String/section analysis and known IOC checks', 'Ignoring it'],
                  'correct': 2
                }
              ]
            },
          ),
          xpReward: 200,
        ),
      ],
      imageUrl: null,
    ),

    // Skill Tree: Malware Analysis → Dynamic Analysis
    Mission(
      id: 'M302',
      title: 'Dynamic Malware Analysis',
      description: 'Understand behavior under execution in a safe sandbox.',
      type: MissionType.interactiveQuiz,
      difficulty: MissionDifficulty.intermediate,
      category: MissionCategory.malware,
      status: MissionStatus.available,
      requiredLevel: 2,
      xpReward: 210,
      gemReward: 75,
      challenges: [
        Challenge(
          id: 'C302',
          title: 'Behavior Watch',
          description: 'Recognize malicious runtime patterns.',
          type: ChallengeType.multipleChoice,
          content: ChallengeContent(
            dataType: 'quiz_questions',
            toolType: 'multiple_choice',
            solution: '1,1,2',
            guidePoints: [
              'Monitor processes, registry, and network',
              'Prefer isolated sandboxes/VMs',
              'Check persistence and exfiltration',
            ],
            dataPayload: {
              'questions': [
                {
                  'question': 'Which is a safe environment for dynamic analysis?',
                  'options': ['Production server', 'Isolated VM/sandbox', 'Developer laptop', 'Cloud prod instance'],
                  'correct': 1
                },
                {
                  'question': 'Which indicates persistence creation?',
                  'options': ['Temporary file in /tmp', 'New Run key in registry', 'Browser cache update', 'Normal service start'],
                  'correct': 1
                },
                {
                  'question': 'Which behavior suggests data exfiltration?',
                  'options': ['Local IPC only', 'DNS queries only', 'Large outbound transfers to unknown hosts', 'No network activity'],
                  'correct': 2
                }
              ]
            },
          ),
          xpReward: 210,
        ),
      ],
      imageUrl: null,
    ),

    // Skill Tree: Incident Response → Containment
    Mission(
      id: 'M401',
      title: 'Incident Response: Containment',
      description: 'Decide on immediate actions to contain an ongoing incident.',
      type: MissionType.interactiveQuiz,
      difficulty: MissionDifficulty.intermediate,
      category: MissionCategory.forensics,
      status: MissionStatus.available,
      requiredLevel: 2,
      xpReward: 200,
      gemReward: 70,
      challenges: [
        Challenge(
          id: 'C401',
          title: 'Containment Decisions',
          description: 'Choose correct steps to isolate threats.',
          type: ChallengeType.multipleChoice,
          content: ChallengeContent(
            dataType: 'quiz_questions',
            toolType: 'multiple_choice',
            solution: '0,1,1',
            guidePoints: [
              'Isolate affected systems from the network',
              'Preserve evidence where possible',
              'Communicate with stakeholders',
            ],
            dataPayload: {
              'questions': [
                {
                  'question': 'First containment step for a compromised server?',
                  'options': ['Isolate from network', 'Delete logs', 'Announce publicly', 'Do nothing'],
                  'correct': 0
                },
                {
                  'question': 'Why avoid powering off immediately?',
                  'options': ['Wastes energy', 'May lose volatile evidence needed for forensics', 'No reason', 'Speeds up recovery'],
                  'correct': 1
                },
                {
                  'question': 'Whom should you coordinate with?',
                  'options': ['Only social media', 'Management/legal/security teams', 'Random forums', 'Attackers'],
                  'correct': 1
                }
              ]
            },
          ),
          xpReward: 200,
        ),
      ],
      imageUrl: null,
    ),

    // Skill Tree: Incident Response → Recovery
    Mission(
      id: 'M402',
      title: 'Incident Response: Recovery',
      description: 'Plan safe restoration and validation after containment/eradication.',
      type: MissionType.interactiveQuiz,
      difficulty: MissionDifficulty.intermediate,
      category: MissionCategory.forensics,
      status: MissionStatus.available,
      requiredLevel: 2,
      xpReward: 200,
      gemReward: 70,
      challenges: [
        Challenge(
          id: 'C402',
          title: 'Recovery Readiness',
          description: 'Pick correct recovery and validation steps.',
          type: ChallengeType.multipleChoice,
          content: ChallengeContent(
            dataType: 'quiz_questions',
            toolType: 'multiple_choice',
            solution: '2,1,2',
            guidePoints: [
              'Patch and harden before reconnecting',
              'Validate with monitoring after restoration',
              'Communicate completion and lessons learned',
            ],
            dataPayload: {
              'questions': [
                {
                  'question': 'Before reconnecting a system, ensure that:',
                  'options': ['Default creds are restored', 'It is unpatched', 'It is fully patched, hardened, and scanned clean', 'No backups exist'],
                  'correct': 2
                },
                {
                  'question': 'After recovery, what helps ensure stability?',
                  'options': ['Disable monitoring', 'Re-enable detailed logging/monitoring', 'Ignore alerts', 'Open all ports'],
                  'correct': 1
                },
                {
                  'question': 'A good post-incident step is:',
                  'options': ['Blame individuals', 'Skip documentation', 'Conduct a lessons-learned review', 'Delete evidence'],
                  'correct': 2
                }
              ]
            },
          ),
          xpReward: 200,
        ),
      ],
      imageUrl: null,
    ),

    // Mission 5: Terminal Investigation Challenge
    Mission(
      id: 'TERMINAL_001',
      title: 'Terminal Investigation: Suspicious Process',
      description: 'Investigate and terminate a suspicious process using terminal commands. This mission simulates real-world cybersecurity incident response.',
      type: MissionType.terminalChallenge,
      difficulty: MissionDifficulty.beginner,
      category: MissionCategory.forensics,
      status: MissionStatus.available,
      requiredLevel: 1,
      xpReward: 300,
      gemReward: 15,
      challenges: [
        Challenge(
          id: 'CHALLENGE_001',
          title: 'Terminal Investigation',
          description: 'Use terminal commands to investigate and stop a malicious process.',
          type: ChallengeType.terminal,
          content: ChallengeContent(
            dataType: 'terminal_session',
            toolType: 'terminal_simulation',
            solution: 'kill -9 5678',
            guidePoints: [
              'Use "ps" to list running processes',
              'Look for suspicious process names or high CPU usage',
              'Use "netstat" to check network connections',
              'Terminate the malicious process with "kill" command'
            ],
            dataPayload: {
              'session': [
                {
                  'type': 'command',
                  'content': 'ps aux'
                },
                {
                  'type': 'output',
                  'content': '''USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0  22540  1000 ?        Ss   10:00   0:00 /sbin/init
root       123  0.0  0.0  22540   800 ?        S    10:00   0:00 /sbin/udevd
root       456  0.0  0.0  22540   600 ?        S    10:00   0:00 /usr/sbin/sshd
root       789  0.0  0.0  22540   400 ?        S    10:00   0:00 /usr/sbin/cron
root      5678 85.2 12.1 102400 25600 ?        R    10:15   0:45 /tmp/.hidden/malware
root      9999  0.0  0.0  22540   300 ?        S    10:00   0:00 /usr/sbin/rsyslogd'''
                },
                {
                  'type': 'command',
                  'content': 'netstat -tuln'
                },
                {
                  'type': 'output',
                  'content': '''Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State
tcp        0      0 0.0.0.0:22             0.0.0.0:*              LISTEN
tcp        0      0 0.0.0.0:80             0.0.0.0:*              LISTEN
tcp        0      0 0.0.0.0:4444           0.0.0.0:*              LISTEN
tcp        0      0 0.0.0.0:8080           0.0.0.0:*              LISTEN'''
                },
                {
                  'type': 'command',
                  'content': 'lsof -p 5678'
                },
                {
                  'type': 'output',
                  'content': '''COMMAND  PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
malware  5678 root  cwd    DIR    8,1     4096    2 /
malware  5678 root  rtd    DIR    8,1     4096    2 /
malware  5678 root  txt    REG    8,1   256000  123 /tmp/.hidden/malware
malware  5678 root  mem    REG    8,1    12345  456 /lib/x86_64-linux-gnu/libc.so.6
malware  5678 root    0u   CHR    1,3      0t0    4 /dev/null
malware  5678 root    1u   CHR    1,3      0t0    4 /dev/null
malware  5678 root    2u   CHR    1,3      0t0    4 /dev/null
malware  5678 root    3u  IPv4  12345      0t0  TCP *:4444 (LISTEN)
malware  5678 root    4u  IPv4  12346      0t0  TCP *:8080 (LISTEN)'''
                }
              ]
            },
          ),
          xpReward: 300,
        ),
      ],
      imageUrl: 'assets/images/terminal_challenge.jpg',
    ),

    // Mission 6: Network Traffic Analysis Terminal Challenge
    Mission(
      id: 'TERMINAL_002',
      title: 'Network Traffic Analysis: Suspicious Connections',
      description: 'Analyze network traffic to identify and block suspicious connections using terminal commands. This mission focuses on network security monitoring.',
      type: MissionType.terminalChallenge,
      difficulty: MissionDifficulty.intermediate,
      category: MissionCategory.networkSecurity,
      status: MissionStatus.available,
      requiredLevel: 2,
      xpReward: 400,
      gemReward: 25,
      challenges: [
        Challenge(
          id: 'CHALLENGE_002',
          title: 'Network Traffic Analysis',
          description: 'Use terminal commands to analyze network traffic and block suspicious connections.',
          type: ChallengeType.terminal,
          content: ChallengeContent(
            dataType: 'terminal_session',
            toolType: 'terminal_simulation',
            solution: 'iptables -A INPUT -s 192.168.1.100 -j DROP',
            guidePoints: [
              'Use "netstat" to view active connections',
              'Use "tcpdump" to capture network packets',
              'Identify suspicious IP addresses',
              'Use "iptables" to block malicious traffic'
            ],
            dataPayload: {
              'session': [
                {
                  'type': 'command',
                  'content': 'netstat -tuln'
                },
                {
                  'type': 'output',
                  'content': '''Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State
tcp        0      0 0.0.0.0:22             0.0.0.0:*              LISTEN
tcp        0      0 0.0.0.0:80             0.0.0.0:*              LISTEN
tcp        0      0 0.0.0.0:443            0.0.0.0:*              LISTEN
tcp        0      0 0.0.0.0:8080           0.0.0.0:*              LISTEN
tcp        0      0 192.168.1.50:22        192.168.1.100:54321    ESTABLISHED'''
                },
                {
                  'type': 'command',
                  'content': 'tcpdump -i eth0 -n host 192.168.1.100'
                },
                {
                  'type': 'output',
                  'content': '''tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
10:15:23.123456 IP 192.168.1.100.54321 > 192.168.1.50.22: Flags [P], seq 123456:123789, ack 987654, win 65535, length 333
10:15:23.234567 IP 192.168.1.100.54322 > 192.168.1.50.22: Flags [S], seq 123456, win 65535, options [mss 1460], length 0
10:15:23.345678 IP 192.168.1.100.54323 > 192.168.1.50.22: Flags [S], seq 234567, win 65535, options [mss 1460], length 0'''
                },
                {
                  'type': 'command',
                  'content': 'whois 192.168.1.100'
                },
                {
                  'type': 'output',
                  'content': '''IP Address: 192.168.1.100
Country: Unknown
ISP: Suspicious Network Provider
ASN: AS12345
Description: Known malicious IP range'''
                }
              ]
            },
          ),
          xpReward: 400,
        ),
      ],
      imageUrl: 'assets/images/network_security.jpg',
    ),
  ];
}

// Extension to add copyWith to Mission
extension MissionExtension on Mission {
  Mission copyWith({
    String? id,
    String? title,
    String? description,
    MissionType? type,
    MissionDifficulty? difficulty,
    MissionCategory? category,
    MissionStatus? status,
    int? requiredLevel,
    int? xpReward,
    int? gemReward,
    List<Challenge>? challenges,
    String? imageUrl,
    DateTime? unlockDate,
    DateTime? expiryDate,
  }) {
    return Mission(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      status: status ?? this.status,
      requiredLevel: requiredLevel ?? this.requiredLevel,
      xpReward: xpReward ?? this.xpReward,
      gemReward: gemReward ?? this.gemReward,
      challenges: challenges ?? this.challenges,
      imageUrl: imageUrl ?? this.imageUrl,
      unlockDate: unlockDate ?? this.unlockDate,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }
}
