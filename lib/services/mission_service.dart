import '../models/mission_models.dart';

class HardcodedMissionService {
  // Singleton pattern
  static final HardcodedMissionService _instance = HardcodedMissionService._internal();
  factory HardcodedMissionService() => _instance;
  HardcodedMissionService._internal();

  Future<List<Mission>> getMissions() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return _missions;
  }

  Future<Mission> startMission(String missionId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final missionIndex = _missions.indexWhere((m) => m.id == missionId);
    if (missionIndex == -1) {
      throw Exception('Mission not found');
    }

    // Create a new mission with updated status
    final mission = _missions[missionIndex];
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

    // Update the mission in our list
    _missions[missionIndex] = updatedMission;

    return updatedMission;
  }

  static final List<Mission> _missions = [
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
      type: MissionType.scamSimulator,
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
          type: ChallengeType.workbench,
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

    // Mission 4: Terminal Investigation Challenge
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

    // Mission 5: Network Traffic Analysis Terminal Challenge
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
