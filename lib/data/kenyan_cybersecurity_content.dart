import '../models/mission_models.dart';

/// Kenyan Cybersecurity Content
/// This file contains Kenya-specific missions and story scenarios
class KenyanCybersecurityContent {
  
  // ============================================================================
  // UNIT 1: M-PESA MASTERY (The Foundation)
  // ============================================================================
  
  static Mission getMPesaAnatomyMission() {
    return const Mission(
      id: 'KENYA_MPESA_001',
      title: 'Anatomy of an M-PESA Message',
      description: 'Learn to identify the key parts of a real M-PESA confirmation SMS: the transaction code, the sender name ("M-PESA"), the date/time, and the balance.',
      type: MissionType.interactiveQuiz,
      difficulty: MissionDifficulty.beginner,
      category: MissionCategory.mPesaSecurity,
      status: MissionStatus.available,
      requiredLevel: 1,
      xpReward: 150,
      gemReward: 10,
      countryContext: 'Kenya',
      isLocalized: true,
      localizedTitle: {
        'sw': 'Muundo wa Ujumbe wa M-PESA',
        'en': 'Anatomy of an M-PESA Message'
      },
      localizedDescription: {
        'sw': 'Jifunze kutambua sehemu muhimu za ujumbe halisi wa uthibitisho wa M-PESA: msimbo wa muamala, jina la mtumaji ("M-PESA"), tarehe/saa, na salio.',
        'en': 'Learn to identify the key parts of a real M-PESA confirmation SMS: the transaction code, the sender name ("M-PESA"), the date/time, and the balance.'
      },
      challenges: [
        Challenge(
          id: 'MPESA_ANATOMY_CHALLENGE',
          title: 'Spot the Real M-PESA Message',
          description: 'Identify which SMS is a genuine M-PESA confirmation and which is fake.',
          type: ChallengeType.multipleChoice,
          content: ChallengeContent(
            dataType: 'quiz_questions',
            toolType: 'multiple_choice',
            solution: 'A,B,A',
            guidePoints: [
              'Look for the official "M-PESA" sender name',
              'Check for a valid transaction code (usually 10-12 digits)',
              'Verify the date and time format',
              'Confirm the balance format (KES X,XXX.XX)'
            ],
            dataPayload: {
              'questions': [
                {
                  'question': 'Which of these is a sign of a genuine M-PESA message?',
                  'options': [
                    'Sender name shows "M-PESA" (not "M-PESA-Support")',
                    'Contains urgent action words like "Click here"',
                    'Has a shortened URL (bit.ly)',
                    'Asks for personal information'
                  ],
                  'correct': 0
                },
                {
                  'question': 'What should you do if you receive a suspicious M-PESA message?',
                  'options': [
                    'Click the link to verify your account',
                    'Reply with your M-PESA PIN',
                    'Ignore it and delete the message',
                    'Forward it to friends to warn them'
                  ],
                  'correct': 2
                },
                {
                  'question': 'Which transaction detail is NOT typically included in a real M-PESA message?',
                  'options': [
                    'Transaction ID (MPESA followed by numbers)',
                    'Your current balance',
                    'Request for your bank account number',
                    'Sender/receiver phone number'
                  ],
                  'correct': 2
                }
              ]
            },
          ),
          xpReward: 150,
        ),
      ],
    );
  }

  /// Get all Kenyan missions
  static List<Mission> getAllKenyanMissions() {
    return [
      getMPesaAnatomyMission(),
      getWhatsAppImpersonatorMission(),
      getPayFirstScamMission(),
    ];
  }

  /// Get all Kenyan story missions
  static List<StoryMission> getAllKenyanStoryMissions() {
    return [
      getBodaBodaHustleStory(),
    ];
  }

  /// Get missions by category
  static List<Mission> getMissionsByCategory(MissionCategory category) {
    return getAllKenyanMissions().where((mission) => mission.category == category).toList();
  }

  /// Get missions by difficulty
  static List<Mission> getMissionsByDifficulty(MissionDifficulty difficulty) {
    return getAllKenyanMissions().where((mission) => mission.difficulty == difficulty).toList();
  }

  /// Get beginner-friendly missions (for onboarding)
  static List<Mission> getBeginnerMissions() {
    return getAllKenyanMissions().where((mission) => mission.difficulty == MissionDifficulty.beginner).toList();
  }

  /// Get M-PESA specific missions
  static List<Mission> getMPesaMissions() {
    return getMissionsByCategory(MissionCategory.mPesaSecurity);
  }

  /// Get WhatsApp specific missions
  static List<Mission> getWhatsAppMissions() {
    return getMissionsByCategory(MissionCategory.whatsappSecurity);
  }

  /// Get marketplace specific missions
  static List<Mission> getMarketplaceMissions() {
    return getMissionsByCategory(MissionCategory.onlineMarketplace);
  }

  /// Get localized content for a specific language
  static String getLocalizedText(Map<String, String>? localizedMap, String language, String fallback) {
    if (localizedMap == null) return fallback;
    return localizedMap[language] ?? fallback;
  }

  /// Check if content is available in a specific language
  static bool isContentLocalized(Map<String, String>? localizedMap, String language) {
    if (localizedMap == null) return false;
    return localizedMap.containsKey(language);
  }

  static StoryMission getBodaBodaHustleStory() {
    return const StoryMission(
      id: 'KENYA_STORY_001',
      title: 'The Boda Boda Hustle',
      description: 'Follow Alex Kiptoo, a university student and boda boda rider, as he faces a sophisticated mobile money scam that threatens his livelihood.',
      mainCharacter: 'Alex Kiptoo, University Student & Boda Boda Rider',
      storyBackground: 'Alex uses a popular local app to get clients for his boda boda business. When strange deductions appear in his mobile money account and his client app malfunctions, he realizes he\'s been targeted by cybercriminals. His livelihood is at risk, and he must use his cybersecurity knowledge to fight back.',
      difficulty: MissionDifficulty.intermediate,
      category: MissionCategory.mobileMoney,
      totalXpReward: 2000,
      totalGemReward: 100,
      countryContext: 'Kenya',
      imageUrl: 'assets/images/boda_boda_story.jpg',
      scenarios: [
        // Scene 1: The Phishing Lure
        StoryScenario(
          id: 'BODA_SCENE_001',
          title: 'The Phishing Lure',
          description: 'Alex receives a convincing SMS about his BodaGo app account being suspended.',
          narrativeText: 'It\'s 7:30 AM on a Monday morning, and Alex is getting ready for another day of classes and boda boda work. His phone buzzes with an urgent SMS: "Your BodaGo app account has been suspended due to new regulations. Verify your details now to continue working: [bit.ly/BodaGo-Verify]". Worried about losing his main source of income, Alex clicks the link without thinking twice.',
          challengeType: ChallengeType.workbench,
          content: ChallengeContent(
            dataType: 'fake_login_page',
            toolType: 'url_analyzer',
            solution: 'identify_fake_domain',
            guidePoints: [
              'Check the URL domain carefully',
              'Look for spelling mistakes or extra characters',
              'Verify the official BodaGo website',
              'Never enter credentials on suspicious pages'
            ],
            dataPayload: {
              'fake_url': 'https://boda-go-verify.xyz/login',
              'real_url': 'https://bodago.co.ke/login',
              'page_content': 'BodaGo Login - Enter your credentials to restore access',
              'suspicious_elements': ['bit.ly link', 'urgent language', 'suspension threat']
            },
          ),
          xpReward: 300,
          isUnlocked: true,
          requiredPreviousScenarios: 0,
          characterName: 'Alex Kiptoo',
          incidentType: 'Phishing Attack',
        ),

        // Scene 2: The Malware Infection
        StoryScenario(
          id: 'BODA_SCENE_002',
          title: 'The Malware Infection',
          description: 'After entering his details, Alex\'s phone starts acting strangely. Help him investigate.',
          narrativeText: 'After entering his BodaGo credentials on the fake page, Alex notices his phone behaving oddly. Apps are opening and closing by themselves, and he\'s getting strange pop-up messages. "Something\'s not right," he thinks. He needs to investigate what\'s happening to his device.',
          challengeType: ChallengeType.terminal,
          content: ChallengeContent(
            dataType: 'android_debug',
            toolType: 'permission_analyzer',
            solution: 'detect_suspicious_permissions',
            guidePoints: [
              'Check app permissions for unusual access',
              'Look for apps with excessive permissions',
              'Identify recently installed suspicious apps',
              'Monitor for unusual background activity'
            ],
            dataPayload: {
              'installed_apps': [
                {'name': 'BodaGo', 'permissions': ['Location', 'Camera', 'Read SMS', 'Draw over other apps']},
                {'name': 'WhatsApp', 'permissions': ['Location', 'Camera', 'Microphone']},
                {'name': 'M-PESA', 'permissions': ['Read SMS', 'Send SMS']}
              ],
              'suspicious_permissions': ['Read SMS', 'Draw over other apps', 'Accessibility']
            },
          ),
          xpReward: 400,
          isUnlocked: true,
          requiredPreviousScenarios: 1,
          characterName: 'Alex Kiptoo',
          incidentType: 'Malware Infection',
        ),

        // Scene 3: The Investigation
        StoryScenario(
          id: 'BODA_SCENE_003',
          title: 'The Investigation',
          description: 'Alex realizes the fake app is reading his M-PESA messages to steal money. Help him trace the scammer.',
          narrativeText: 'Alex discovers that the fake BodaGo app has been reading his M-PESA confirmation messages. He realizes this is how the scammers are stealing his money - they\'re intercepting his transaction notifications and using the information to drain his account. Now he needs to find out who\'s behind this attack.',
          challengeType: ChallengeType.workbench,
          content: ChallengeContent(
            dataType: 'mpesa_statement',
            toolType: 'transaction_analyzer',
            solution: 'identify_recurring_scammer',
            guidePoints: [
              'Look for recurring phone numbers',
              'Identify unusual transaction patterns',
              'Check for transactions to unknown recipients',
              'Document all suspicious activity'
            ],
            dataPayload: {
              'transactions': [
                {'date': '2024-12-01', 'amount': -2000, 'recipient': '254700999999', 'type': 'Send Money'},
                {'date': '2024-12-01', 'amount': -1500, 'recipient': '254700999999', 'type': 'Send Money'},
                {'date': '2024-12-01', 'amount': -3000, 'recipient': '254700999999', 'type': 'Send Money'}
              ],
              'suspicious_patterns': ['recurring recipient', 'multiple small amounts', 'unknown number']
            },
          ),
          xpReward: 500,
          isUnlocked: true,
          requiredPreviousScenarios: 2,
          characterName: 'Alex Kiptoo',
          incidentType: 'Financial Fraud',
        ),

        // Scene 4: The Takedown
        StoryScenario(
          id: 'BODA_SCENE_004',
          title: 'The Takedown',
          description: 'With the scammer\'s number identified, Alex must choose the best course of action.',
          narrativeText: 'Alex has successfully identified the scammer\'s phone number and gathered evidence of the fraud. Now he faces a critical decision: how should he proceed to bring the criminals to justice and recover his stolen money?',
          challengeType: ChallengeType.multipleChoice,
          content: ChallengeContent(
            dataType: 'action_choice',
            toolType: 'decision_maker',
            solution: 'report_to_authorities',
            guidePoints: [
              'Never confront scammers directly',
              'Avoid sharing information on social media',
              'Report to official channels and authorities',
              'Keep evidence for law enforcement'
            ],
            dataPayload: {
              'choices': [
                {
                  'text': 'Call the number and threaten the scammer',
                  'consequence': 'Dangerous - could lead to retaliation',
                  'isCorrect': false
                },
                {
                  'text': 'Post the number on Twitter and ask for help',
                  'consequence': 'Risky - could spread misinformation',
                  'isCorrect': false
                },
                {
                  'text': 'Report the number and evidence to Safaricom and DCI Cybercrime Unit',
                  'consequence': 'Correct - official channels ensure proper investigation',
                  'isCorrect': true
                }
              ]
            },
          ),
          xpReward: 400,
          isUnlocked: true,
          requiredPreviousScenarios: 3,
          characterName: 'Alex Kiptoo',
          incidentType: 'Legal Action',
        ),

        // Scene 5: The Resolution
        StoryScenario(
          id: 'BODA_SCENE_005',
          title: 'The Resolution',
          description: 'The final scene shows the successful outcome of Alex\'s cybersecurity investigation.',
          narrativeText: 'Thanks to Alex\'s quick thinking and cybersecurity knowledge, the scam has been successfully reported and investigated. The authorities have taken action, and Alex\'s story serves as a powerful example of how ordinary Kenyans can fight back against cybercrime.',
          challengeType: ChallengeType.storyScenario,
          content: ChallengeContent(
            dataType: 'news_article',
            toolType: 'achievement_unlocker',
            solution: 'story_completion',
            guidePoints: [
              'Congratulations on completing the story!',
              'You\'ve learned valuable cybersecurity skills',
              'Your actions helped bring criminals to justice',
              'You\'re now a CyberShujaa!'
            ],
            dataPayload: {
              'news_headline': 'DCI detectives arrest suspect in sophisticated mobile money scam',
              'news_content': 'A youthful suspect has been arrested in connection with a sophisticated mobile money scam targeting boda boda riders...',
              'achievement': 'Boda Boda Hero',
              'reward_xp': 400,
              'reward_gems': 25
            },
          ),
          xpReward: 400,
          isUnlocked: true,
          requiredPreviousScenarios: 4,
          characterName: 'Alex Kiptoo',
          incidentType: 'Resolution',
        ),
      ],
    );
  }

  static Mission getWhatsAppImpersonatorMission() {
    return const Mission(
      id: 'KENYA_WHATSAPP_001',
      title: 'Spot the Impersonator',
      description: 'Learn to identify fake WhatsApp profiles and avoid impersonation scams.',
      type: MissionType.interactiveQuiz,
      difficulty: MissionDifficulty.beginner,
      category: MissionCategory.whatsappSecurity,
      status: MissionStatus.available,
      requiredLevel: 1,
      xpReward: 150,
      gemReward: 10,
      countryContext: 'Kenya',
      isLocalized: true,
      localizedTitle: {
        'sw': 'Tambua Mtu wa Uongo',
        'en': 'Spot the Impersonator'
      },
      localizedDescription: {
        'sw': 'Jifunze kutambua wasifu wa uongo wa WhatsApp na kuepuka udanganyifu wa kujifanya mtu mwingine.',
        'en': 'Learn to identify fake WhatsApp profiles and avoid impersonation scams.'
      },
      challenges: [
        Challenge(
          id: 'WHATSAPP_IMPERSONATOR_CHALLENGE',
          title: 'Identify Fake WhatsApp Profiles',
          description: 'Spot the differences between real and fake WhatsApp profiles.',
          type: ChallengeType.multipleChoice,
          content: ChallengeContent(
            dataType: 'quiz_questions',
            toolType: 'multiple_choice',
            solution: 'B,A,C',
            guidePoints: [
              'Check profile picture quality and consistency',
              'Look for suspicious "About" section content',
              'Verify contact information',
              'Be wary of urgent requests for money'
            ],
            dataPayload: {
              'questions': [
                {
                  'question': 'Which of these is a red flag for a fake WhatsApp profile?',
                  'options': [
                    'Clear, high-quality profile picture',
                    'Blurry or pixelated profile picture',
                    'Normal "About" section text',
                    'Consistent contact information'
                  ],
                  'correct': 1
                },
                {
                  'question': 'What should you do if someone claiming to be a family member asks for money urgently?',
                  'options': [
                    'Send the money immediately',
                    'Call the family member on their known number',
                    'Ignore the message completely',
                    'Ask for their bank account details'
                  ],
                  'correct': 1
                },
                {
                  'question': 'Which "About" section content is suspicious?',
                  'options': [
                    'Normal personal description',
                    'Urgent requests for help or money',
                    'Professional job title',
                    'Hobby or interest description'
                  ],
                  'correct': 1
                }
              ]
            },
          ),
          xpReward: 150,
        ),
      ],
    );
  }

  static Mission getPayFirstScamMission() {
    return const Mission(
      id: 'KENYA_MARKETPLACE_001',
      title: 'The Pay First Scam',
      description: 'Learn to identify and avoid online marketplace scams where sellers demand payment before meeting.',
      type: MissionType.interactiveQuiz,
      difficulty: MissionDifficulty.intermediate,
      category: MissionCategory.onlineMarketplace,
      status: MissionStatus.available,
      requiredLevel: 2,
      xpReward: 200,
      gemReward: 15,
      countryContext: 'Kenya',
      isLocalized: true,
      localizedTitle: {
        'sw': 'Udanganyifu wa Kulipa Kwanza',
        'en': 'The Pay First Scam'
      },
      localizedDescription: {
        'sw': 'Jifunze kutambua na kuepuka udanganyifu wa soko la mtandaoni ambapo wauzaji wanadai malipo kabla ya kukutana.',
        'en': 'Learn to identify and avoid online marketplace scams where sellers demand payment before meeting.'
      },
      challenges: [
        Challenge(
          id: 'MARKETPLACE_SCAM_CHALLENGE',
          title: 'Avoid the Pay First Scam',
          description: 'Learn to identify red flags in online marketplace transactions.',
          type: ChallengeType.multipleChoice,
          content: ChallengeContent(
            dataType: 'quiz_questions',
            toolType: 'multiple_choice',
            solution: 'C,A,B',
            guidePoints: [
              'Never pay before seeing the item in person',
              'Meet in safe, public locations',
              'Be suspicious of urgent payment requests',
              'Use secure payment methods'
            ],
            dataPayload: {
              'questions': [
                {
                  'question': 'A seller on Jiji insists you pay a deposit via M-PESA before meeting. What should you do?',
                  'options': [
                    'Send the deposit immediately',
                    'Ask for their bank account number',
                    'Insist on meeting in person first',
                    'Block the seller immediately'
                  ],
                  'correct': 2
                },
                {
                  'question': 'Which meeting location is safest for online marketplace transactions?',
                  'options': [
                    'A busy shopping mall during business hours',
                    'A quiet street corner at night',
                    'The seller\'s private residence',
                    'A secluded parking lot'
                  ],
                  'correct': 0
                },
                {
                  'question': 'What is a red flag when buying electronics online?',
                  'options': [
                    'Seller provides detailed product photos',
                    'Seller demands payment before showing the item',
                    'Seller offers a reasonable price',
                    'Seller responds quickly to messages'
                  ],
                  'correct': 1
                }
              ]
            },
          ),
          xpReward: 200,
        ),
      ],
    );
  }
}
