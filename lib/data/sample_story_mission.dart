import '../models/mission_models.dart';

/// Sample story mission: "The Digital Breach Investigation"
/// This demonstrates how a story mission works with progressive scenarios
class SampleStoryMission {
  static StoryMission getDigitalBreachInvestigation() {
    return const StoryMission(
      id: 'STORY_001',
      title: 'The Digital Breach Investigation',
      description: 'Follow Sarah Chen, a cybersecurity analyst, as she investigates a sophisticated data breach at TechCorp Industries.',
      mainCharacter: 'Sarah Chen, Senior Cybersecurity Analyst',
      storyBackground: 'TechCorp Industries, a leading technology company, has reported unusual network activity and potential data exfiltration. As the lead investigator, you\'ll work alongside Sarah to uncover the truth behind this breach.',
      difficulty: MissionDifficulty.intermediate,
      category: MissionCategory.forensics,
      totalXpReward: 1500,
      totalGemReward: 75,
      imageUrl: 'assets/images/breach_investigation.jpg',
      scenarios: [
        // Scenario 1: Initial Alert
        StoryScenario(
          id: 'SCENARIO_001',
          title: 'The Alert',
          description: 'Review the initial security alert and understand the scope of the incident.',
          narrativeText: 'It\'s 3:47 AM when Sarah receives the urgent notification. The SIEM system has detected anomalous network traffic patterns. Multiple failed login attempts, unusual data transfers, and suspicious process executions have triggered a critical alert. "This doesn\'t look like our usual false positives," Sarah mutters as she begins her investigation.',
          challengeType: ChallengeType.multipleChoice,
          content: ChallengeContent(
            dataType: 'security_alert',
            toolType: 'siem_dashboard',
            solution: 'alert_analysis',
            guidePoints: [
              'Review the alert severity and confidence score',
              'Identify the affected systems and users',
              'Check for similar patterns in recent history',
              'Determine if this is a false positive or real threat'
            ],
            dataPayload: {
              'alert_id': 'ALERT_2024_001',
              'severity': 'critical',
              'confidence': 0.89,
              'affected_systems': ['web_server_01', 'database_02'],
              'suspicious_ips': ['192.168.1.100', '10.0.0.50']
            },
          ),
          xpReward: 200,
          isUnlocked: true,
          requiredPreviousScenarios: 0,
          characterName: 'Sarah Chen',
          incidentType: 'Security Alert',
        ),

        // Scenario 2: Terminal Investigation
        StoryScenario(
          id: 'SCENARIO_002',
          title: 'Terminal Investigation',
          description: 'Use terminal commands to investigate suspicious processes and network activity.',
          narrativeText: 'Sarah connects to the compromised server via SSH. The system feels sluggish, and she notices unusual network activity. "Time to dig deeper," she thinks as she opens her terminal. She needs to identify and stop the malicious processes before they can exfiltrate more data.',
          challengeType: ChallengeType.terminal,
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
          xpReward: 400,
          isUnlocked: true,
          requiredPreviousScenarios: 1,
          characterName: 'Sarah Chen',
          incidentType: 'Terminal Investigation',
        ),

        // Scenario 3: Network Traffic Analysis
        StoryScenario(
          id: 'SCENARIO_003',
          title: 'Following the Digital Trail',
          description: 'Examine network traffic to trace the attacker\'s communications and data exfiltration.',
          narrativeText: 'The network traffic analysis reveals the full scope of the breach. Sarah discovers that the attacker established multiple command-and-control channels and exfiltrated sensitive data over several days. "This is a professional operation," she notes, "not some script kiddie attack."',
          challengeType: ChallengeType.workbench,
          content: ChallengeContent(
            dataType: 'network_traffic',
            toolType: 'packet_analyzer',
            solution: 'traffic_analysis',
            guidePoints: [
              'Identify command-and-control traffic patterns',
              'Analyze data exfiltration channels',
              'Map the attacker\'s infrastructure',
              'Determine the volume of stolen data'
            ],
            dataPayload: {
              'log_files': ['system.log', 'security.log', 'application.log'],
              'time_range': '48_hours',
              'suspicious_events': [
                'process_injection',
                'privilege_escalation',
                'data_exfiltration'
              ]
            },
          ),
          xpReward: 300,
          isUnlocked: true,
          requiredPreviousScenarios: 2,
          characterName: 'Sarah Chen',
          incidentType: 'Log Analysis',
        ),

        // Scenario 4: Malware Analysis
        StoryScenario(
          id: 'SCENARIO_004',
          title: 'The Malware\'s Secrets',
          description: 'Analyze the malware samples to understand the attack methodology.',
          narrativeText: 'In the malware analysis lab, Sarah examines the sophisticated code that enabled this breach. The malware uses advanced obfuscation techniques and has multiple persistence mechanisms. "This is state-sponsored level sophistication," she concludes, realizing the implications for national security.',
          challengeType: ChallengeType.codeReview,
          content: ChallengeContent(
            dataType: 'malware_sample',
            toolType: 'malware_analyzer',
            solution: 'malware_analysis',
            guidePoints: [
              'Perform static analysis of the binary',
              'Identify obfuscation techniques',
              'Analyze the persistence mechanisms',
              'Determine the malware\'s capabilities'
            ],
            dataPayload: {
              'malware_samples': ['trojan.exe', 'loader.dll'],
              'file_hashes': ['sha256_hash_1', 'sha256_hash_2'],
              'obfuscation_techniques': ['string_encryption', 'code_packing', 'anti_debugging']
            },
          ),
          xpReward: 400,
          isUnlocked: true,
          requiredPreviousScenarios: 3,
          characterName: 'Sarah Chen',
          incidentType: 'Malware Analysis',
        ),

        // Scenario 5: Incident Response
        StoryScenario(
          id: 'SCENARIO_005',
          title: 'Containing the Threat',
          description: 'Execute incident response procedures to contain and eradicate the threat.',
          narrativeText: 'With the full picture now clear, Sarah coordinates the incident response team. She must balance the need for immediate containment with preserving evidence for law enforcement. "We need to act fast, but we also need to maintain the chain of custody," she tells her team.',
          challengeType: ChallengeType.terminal,
          content: ChallengeContent(
            dataType: 'incident_response',
            toolType: 'response_tools',
            solution: 'incident_containment',
            guidePoints: [
              'Isolate affected systems from the network',
              'Preserve evidence for forensic analysis',
              'Implement temporary security controls',
              'Coordinate with law enforcement'
            ],
            dataPayload: {
              'affected_systems': ['web_server_01', 'database_02', 'file_server'],
              'response_procedures': ['isolation', 'evidence_preservation', 'containment'],
              'stakeholders': ['management', 'legal', 'law_enforcement']
            },
          ),
          xpReward: 250,
          isUnlocked: true,
          requiredPreviousScenarios: 4,
          characterName: 'Sarah Chen',
          incidentType: 'Incident Response',
        ),
      ],
    );
  }

  /// Get a list of all available story missions
  static List<StoryMission> getAllStoryMissions() {
    return [
      getDigitalBreachInvestigation(),
      // Add more story missions here as they're created
    ];
  }
}

/// Standalone Terminal Mission for testing
class SampleTerminalMission {
  static Mission getTerminalChallenge() {
    return Mission(
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
      imageUrl: 'assets/images/terminal_challenge.jpg',
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
    );
  }
}

/// Additional Terminal Mission for Network Traffic Analysis
class SampleNetworkTerminalMission {
  static Mission getNetworkTerminalChallenge() {
    return Mission(
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
      imageUrl: 'assets/images/network_security.jpg',
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
    );
  }
}

/// Utility class to get all available terminal missions
class TerminalMissions {
  static List<Mission> getAllTerminalMissions() {
    return [
      SampleTerminalMission.getTerminalChallenge(),
      SampleNetworkTerminalMission.getNetworkTerminalChallenge(),
    ];
  }
}
