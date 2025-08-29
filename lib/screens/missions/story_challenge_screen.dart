import 'package:flutter/material.dart';
import '../../models/mission_models.dart';

class StoryChallengeScreen extends StatefulWidget {
  final StoryScenario scenario;
  final Function(String)? onScenarioCompleted;
  
  const StoryChallengeScreen({
    super.key,
    required this.scenario,
    this.onScenarioCompleted,
  });

  @override
  State<StoryChallengeScreen> createState() => _StoryChallengeScreenState();
}

class _StoryChallengeScreenState extends State<StoryChallengeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isCompleted = false;
  int _currentStoryStep = 0;
  List<String> _userChoices = [];
  bool _showHint = false;
  bool _showSolution = false;

  // Progressive story timeline data
  late List<StoryStep> _storySteps;
  late List<List<StoryStep>> _storyChapters;
  int _currentChapter = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeStorySteps();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  void _initializeStorySteps() {
    // Create progressive story chapters based on scenario type
    _storyChapters = _createStoryChapters();
    _storySteps = _storyChapters[_currentChapter];
  }

  List<List<StoryStep>> _createStoryChapters() {
    switch (widget.scenario.challengeType) {
      case ChallengeType.storyScenario:
        return _createCybersecurityStoryChapters();
      case ChallengeType.networkSecurity:
        return _createNetworkSecurityStoryChapters();
      default:
        return _createDefaultStoryChapters();
    }
  }

  List<List<StoryStep>> _createCybersecurityStoryChapters() {
    return [
      // Chapter 1: The Initial Incident
      [
        StoryStep(
          id: 'intro',
          title: 'The Digital Threat',
          description: 'You\'re a cybersecurity analyst at a major bank. A suspicious email has been reported by an employee.',
          narrative: 'The morning starts like any other at CyberBank. Your colleague Sarah approaches your desk with concern in her eyes. "I think I clicked on something I shouldn\'t have," she says, showing you an email.',
          choices: [
            StoryChoice(
              id: 'investigate',
              text: 'Investigate the email immediately',
              isCorrect: true,
              feedback: 'Good choice! Quick response is crucial in cybersecurity incidents.',
              nextStep: 'email_analysis'
            ),
            StoryChoice(
              id: 'wait',
              text: 'Wait and see if anything happens',
              isCorrect: false,
              feedback: 'Delaying could allow malware to spread. Always investigate suspicious activity promptly.',
              nextStep: 'email_analysis'
            ),
          ],
        ),
        StoryStep(
          id: 'email_analysis',
          title: 'Analyzing the Threat',
          description: 'You examine the suspicious email for signs of phishing or malware.',
          narrative: 'You open the email and notice several red flags: poor grammar, urgent language, and a suspicious attachment. The sender address looks legitimate but something feels off.',
          choices: [
            StoryChoice(
              id: 'isolate',
              text: 'Isolate the affected computer from the network',
              isCorrect: true,
              feedback: 'Excellent! Network isolation prevents malware from spreading to other systems.',
              nextStep: 'malware_scan'
            ),
            StoryChoice(
              id: 'delete',
              text: 'Just delete the email and move on',
              isCorrect: false,
              feedback: 'Deleting alone isn\'t enough. The attachment may have already executed malware.',
              nextStep: 'malware_scan'
            ),
          ],
        ),
        StoryStep(
          id: 'malware_scan',
          title: 'Running Security Scans',
          description: 'You initiate comprehensive security scans to identify any threats.',
          narrative: 'Your security tools detect suspicious activity. The email attachment contained a keylogger that\'s been collecting keystrokes for the past hour.',
          choices: [
            StoryChoice(
              id: 'contain',
              text: 'Contain the threat and document everything',
              isCorrect: true,
              feedback: 'Perfect! Proper containment and documentation are essential for incident response.',
              nextStep: 'incident_response'
            ),
            StoryChoice(
              id: 'panic',
              text: 'Panic and call everyone immediately',
              isCorrect: false,
              feedback: 'While urgency is important, following proper incident response procedures is crucial.',
              nextStep: 'incident_response'
            ),
          ],
        ),
        StoryStep(
          id: 'incident_response',
          title: 'Incident Response Protocol',
          description: 'You follow the bank\'s incident response procedures.',
          narrative: 'Following your training, you activate the incident response team, notify management, and begin the containment process. The keylogger is successfully removed.',
          choices: [
            StoryChoice(
              id: 'learn',
              text: 'Use this as a learning opportunity for the team',
              isCorrect: true,
              feedback: 'Excellent! Every incident is an opportunity to improve security awareness and procedures.',
              nextStep: 'end'
            ),
            StoryChoice(
              id: 'forget',
              text: 'Hope it never happens again',
              isCorrect: false,
              feedback: 'Proactive security measures and continuous improvement are key to preventing future incidents.',
              nextStep: 'end'
            ),
          ],
        ),
      ],
      
      // Chapter 2: The Aftermath - New Threats Emerge
      [
        StoryStep(
          id: 'chapter2_intro',
          title: 'The Aftermath',
          description: 'Two weeks later, new security threats emerge that seem connected to the previous incident.',
          narrative: 'Just when you thought the incident was behind you, the security team discovers unusual network patterns. It appears the attackers weren\'t just after Sarah\'s computer - they were mapping the entire bank\'s infrastructure.',
          choices: [
            StoryChoice(
              id: 'investigate_deeper',
              text: 'Launch a comprehensive network investigation',
              isCorrect: true,
              feedback: 'Excellent! The previous incident was just the beginning. You need to understand the full scope.',
              nextStep: 'infrastructure_mapping'
            ),
            StoryChoice(
              id: 'assume_isolated',
              text: 'Assume it\'s an isolated incident',
              isCorrect: false,
              feedback: 'Never assume incidents are isolated. Attackers often use small breaches to gather intelligence for larger attacks.',
              nextStep: 'infrastructure_mapping'
            ),
          ],
        ),
        StoryStep(
          id: 'infrastructure_mapping',
          title: 'Infrastructure Mapping',
          description: 'You discover the attackers have been mapping your network infrastructure.',
          narrative: 'Your investigation reveals sophisticated reconnaissance activities. The attackers have been systematically mapping network topology, identifying critical systems, and cataloging potential vulnerabilities.',
          choices: [
            StoryChoice(
              id: 'enhance_monitoring',
              text: 'Enhance network monitoring and deploy honeypots',
              isCorrect: true,
              feedback: 'Perfect! Enhanced monitoring will help detect future attacks, and honeypots can mislead attackers.',
              nextStep: 'threat_hunting'
            ),
            StoryChoice(
              id: 'panic_mode',
              text: 'Go into panic mode and shut everything down',
              isCorrect: false,
              feedback: 'While the threat is serious, shutting everything down would disrupt business operations unnecessarily.',
              nextStep: 'threat_hunting'
            ),
          ],
        ),
        StoryStep(
          id: 'threat_hunting',
          title: 'Active Threat Hunting',
          description: 'You initiate proactive threat hunting to find any remaining attackers.',
          narrative: 'Working with the threat intelligence team, you begin active threat hunting. You\'re looking for any remaining persistence mechanisms, backdoors, or compromised accounts.',
          choices: [
            StoryChoice(
              id: 'systematic_approach',
              text: 'Use systematic threat hunting methodology',
              isCorrect: true,
              feedback: 'Excellent! Systematic approaches are more effective than random searching.',
              nextStep: 'advanced_persistent_threat'
            ),
            StoryChoice(
              id: 'random_search',
              text: 'Search randomly for threats',
              isCorrect: false,
              feedback: 'Random searching is inefficient and can miss sophisticated threats.',
              nextStep: 'advanced_persistent_threat'
            ),
          ],
        ),
        StoryStep(
          id: 'advanced_persistent_threat',
          title: 'Advanced Persistent Threat',
          description: 'You discover evidence of an advanced persistent threat (APT) group.',
          narrative: 'Your threat hunting reveals sophisticated malware that has been hiding in your systems for months. This is no random attack - it\'s a coordinated campaign by a professional cybercrime group.',
          choices: [
            StoryChoice(
              id: 'coordinate_response',
              text: 'Coordinate with law enforcement and cybersecurity firms',
              isCorrect: true,
              feedback: 'Perfect! APT groups require coordinated response with external expertise.',
              nextStep: 'end'
            ),
            StoryChoice(
              id: 'handle_internally',
              text: 'Try to handle this internally',
              isCorrect: false,
              feedback: 'APT groups are beyond the scope of internal teams. External expertise is essential.',
              nextStep: 'end'
            ),
          ],
        ),
      ],
      
      // Chapter 3: The Recovery and Lessons Learned
      [
        StoryStep(
          id: 'chapter3_intro',
          title: 'Building Resilience',
          description: 'Six months later, you\'re leading the bank\'s cybersecurity transformation.',
          narrative: 'The APT incident has transformed how CyberBank approaches cybersecurity. You\'ve been promoted to lead the security transformation initiative, implementing lessons learned from the attacks.',
          choices: [
            StoryChoice(
              id: 'zero_trust',
              text: 'Implement zero-trust architecture',
              isCorrect: true,
              feedback: 'Excellent! Zero-trust is the future of cybersecurity, assuming nothing can be trusted.',
              nextStep: 'security_culture'
            ),
            StoryChoice(
              id: 'traditional_security',
              text: 'Stick with traditional security approaches',
              isCorrect: false,
              feedback: 'Traditional approaches failed against the APT. You need modern, adaptive security.',
              nextStep: 'security_culture'
            ),
          ],
        ),
        StoryStep(
          id: 'security_culture',
          title: 'Security Culture Transformation',
          description: 'You focus on transforming the bank\'s security culture.',
          narrative: 'You realize that technology alone isn\'t enough. The human element is crucial. You need to build a security-first culture where every employee understands their role in protecting the bank.',
          choices: [
            StoryChoice(
              id: 'comprehensive_training',
              text: 'Implement comprehensive security awareness training',
              isCorrect: true,
              feedback: 'Perfect! Security awareness training is the foundation of a strong security culture.',
              nextStep: 'future_threats'
            ),
            StoryChoice(
              id: 'basic_training',
              text: 'Provide basic security training only',
              isCorrect: false,
              feedback: 'Basic training isn\'t enough. You need comprehensive, ongoing security education.',
              nextStep: 'future_threats'
            ),
          ],
        ),
        StoryStep(
          id: 'future_threats',
          title: 'Preparing for Future Threats',
          description: 'You develop strategies to prepare for emerging cyber threats.',
          narrative: 'As you build the bank\'s cybersecurity capabilities, you also need to prepare for future threats. AI-powered attacks, quantum computing threats, and supply chain attacks are on the horizon.',
          choices: [
            StoryChoice(
              id: 'innovative_defense',
              text: 'Invest in innovative defense technologies and threat intelligence',
              isCorrect: true,
              feedback: 'Excellent! Staying ahead of threats requires continuous innovation and intelligence.',
              nextStep: 'end'
            ),
            StoryChoice(
              id: 'reactive_approach',
              text: 'Take a reactive approach to new threats',
              isCorrect: false,
              feedback: 'Reactive approaches leave you vulnerable. Proactive, innovative defense is essential.',
              nextStep: 'end'
            ),
          ],
        ),
      ],
    ];
  }






  List<List<StoryStep>> _createNetworkSecurityStoryChapters() {
    return [
      // Chapter 1: Initial Network Breach
      [
        StoryStep(
          id: 'network_intro',
          title: 'Network Defense Mission',
          description: 'Protect the corporate network from advanced persistent threats.',
          narrative: 'You\'re the lead network security engineer at TechCorp. The security operations center has detected unusual network traffic patterns that suggest a potential breach.',
          choices: [
            StoryChoice(
              id: 'start_network',
              text: 'Begin network security investigation',
              isCorrect: true,
              feedback: 'Let\'s secure the network!',
              nextStep: 'traffic_analysis'
            ),
          ],
        ),
      StoryStep(
        id: 'traffic_analysis',
        title: 'Traffic Pattern Analysis',
        description: 'Analyze network traffic to identify suspicious activity.',
        narrative: 'Your network monitoring tools show unusual data flows to external servers. There\'s also an increase in failed authentication attempts from multiple internal IP addresses.',
        choices: [
          StoryChoice(
            id: 'deep_analysis',
            text: 'Perform deep packet inspection',
            isCorrect: true,
            feedback: 'Excellent! Deep packet inspection will reveal the true nature of the traffic.',
            nextStep: 'threat_identification'
          ),
          StoryChoice(
            id: 'block_external',
            text: 'Block all external connections immediately',
            isCorrect: false,
            feedback: 'While blocking external connections might seem safe, it could disrupt legitimate business operations. Analysis first is better.',
            nextStep: 'threat_identification'
          ),
        ],
      ),
      StoryStep(
        id: 'threat_identification',
        title: 'Threat Identification',
        description: 'Identify the type and scope of the network threat.',
        narrative: 'Your analysis reveals a sophisticated malware campaign using encrypted channels to exfiltrate data. The malware has spread to multiple workstations and is attempting to establish command and control connections.',
        choices: [
          StoryChoice(
            id: 'isolate_infected',
            text: 'Isolate infected workstations from the network',
            isCorrect: true,
            feedback: 'Perfect! Network segmentation prevents malware from spreading further.',
            nextStep: 'incident_response'
          ),
          StoryChoice(
            id: 'shutdown_network',
            text: 'Shut down the entire network',
            isCorrect: false,
            feedback: 'Complete network shutdown would disrupt all business operations. Targeted isolation is more effective.',
            nextStep: 'incident_response'
          ),
        ],
      ),
      StoryStep(
        id: 'incident_response',
        title: 'Incident Response',
        description: 'Execute incident response procedures to contain and eradicate the threat.',
        narrative: 'With infected systems isolated, you need to coordinate with the incident response team to remove the malware, restore clean systems, and implement additional security measures.',
        choices: [
          StoryChoice(
            id: 'coordinated_response',
            text: 'Coordinate with incident response team',
            isCorrect: true,
            feedback: 'Excellent! Coordinated response ensures comprehensive threat eradication.',
            nextStep: 'recovery_planning'
          ),
          StoryChoice(
            id: 'handle_solo',
            text: 'Handle the incident yourself',
            isCorrect: false,
            feedback: 'Complex incidents require team coordination. Don\'t hesitate to involve the incident response team.',
            nextStep: 'recovery_planning'
          ),
        ],
      ),
      StoryStep(
        id: 'recovery_planning',
        title: 'Recovery Planning',
        description: 'Plan and execute network recovery and security hardening.',
        narrative: 'The threat has been contained. Now you need to restore affected systems, implement additional security controls, and develop a plan to prevent similar incidents.',
        choices: [
          StoryChoice(
            id: 'comprehensive_recovery',
            text: 'Implement comprehensive recovery and security hardening',
            isCorrect: true,
            feedback: 'Perfect! Comprehensive recovery ensures the network is more secure than before.',
            nextStep: 'end'
          ),
          StoryChoice(
            id: 'quick_restore',
            text: 'Quickly restore systems and move on',
            isCorrect: false,
            feedback: 'Quick restoration without security hardening leaves the network vulnerable to similar attacks.',
            nextStep: 'end'
          ),
        ],
      )],
    ];
  }





  List<List<StoryStep>> _createDefaultStoryChapters() {
    return [
      [
        StoryStep(
          id: 'default_intro',
          title: 'Cybersecurity Challenge',
          description: 'Complete this cybersecurity scenario to test your skills.',
          narrative: 'You\'re facing a cybersecurity challenge that will test your knowledge and decision-making abilities.',
          choices: [
            StoryChoice(
              id: 'start_default',
              text: 'Begin the challenge',
              isCorrect: true,
              feedback: 'Let\'s start the cybersecurity challenge!',
              nextStep: 'end'
            ),
          ],
        ),
      ],
    ];
  }

  void _makeChoice(String choiceId) {
    final currentStep = _storySteps[_currentStoryStep];
    final choice = currentStep.choices.firstWhere((c) => c.id == choiceId);
    
    setState(() {
      _userChoices.add(choiceId);
    });

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(choice.feedback),
        backgroundColor: choice.isCorrect ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );

    // Move to next step
    if (choice.nextStep != 'end') {
      final nextStepIndex = _storySteps.indexWhere((step) => step.id == choice.nextStep);
      if (nextStepIndex != -1) {
        setState(() {
          _currentStoryStep = nextStepIndex;
        });
      }
    } else {
      // Chapter complete - check if there are more chapters
      if (_currentChapter + 1 < _storyChapters.length) {
        // Move to next chapter
        setState(() {
          _currentChapter++;
          _currentStoryStep = 0;
          _storySteps = _storyChapters[_currentChapter];
        });
        
        // Show chapter completion dialog
        _showChapterCompletionDialog();
      } else {
        // All chapters complete
        setState(() {
          _isCompleted = true;
        });
        
        // Show final completion dialog
        _showCompletionDialog();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scenario.title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStoryHeader(),
                const SizedBox(height: 24),
                _buildCurrentStoryStep(),
                const SizedBox(height: 24),
                _buildStoryProgress(),
                const SizedBox(height: 24),
                _buildGuidePoints(),
                const SizedBox(height: 32),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoryHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getChallengeIcon(),
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Challenge Type',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      _getChallengeTypeName(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Scenario',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.scenario.title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
            ),
          ),
          if (widget.scenario.characterName != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Character: ${widget.scenario.characterName}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrentStoryStep() {
    final currentStep = _storySteps[_currentStoryStep];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${_currentStoryStep + 1}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  currentStep.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            currentStep.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Story Context',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  currentStep.narrative,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'What would you do?',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ...currentStep.choices.map((choice) => _buildChoiceButton(choice)),
        ],
      ),
    );
  }

  Widget _buildChoiceButton(StoryChoice choice) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _makeChoice(choice.id),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          choice.text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  Widget _buildStoryProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline,
                color: Theme.of(context).colorScheme.secondary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Story Progress',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Chapter progress
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.book,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Chapter ${_currentChapter + 1} of ${_storyChapters.length}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Step progress within chapter
          LinearProgressIndicator(
            value: (_currentStoryStep + 1) / _storySteps.length,
            backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Step ${_currentStoryStep + 1} of ${_storySteps.length} in Chapter ${_currentChapter + 1}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidePoints() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Tips & Hints',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildHintItem(
            icon: Icons.psychology,
            title: 'Think Strategically',
            description: 'Consider the cybersecurity context and think about what would be the most secure approach.',
          ),
          const SizedBox(height: 12),
          _buildHintItem(
            icon: Icons.security,
            title: 'Security First',
            description: 'Always prioritize security best practices over convenience.',
          ),
          const SizedBox(height: 12),
          _buildHintItem(
            icon: Icons.analytics,
            title: 'Analyze the Context',
            description: 'Look at the narrative and understand the scenario before making decisions.',
          ),
        ],
      ),
    );
  }

  Widget _buildHintItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showHint ? null : _toggleHint,
            icon: const Icon(Icons.lightbulb),
            label: Text(_showHint ? 'Hint Shown' : 'Show Hint'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.secondary,
              side: BorderSide(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showSolution ? null : _toggleSolution,
            icon: const Icon(Icons.help_outline),
            label: Text(_showSolution ? 'Solution Shown' : 'Show Solution'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _toggleHint() {
    setState(() {
      _showHint = !_showHint;
    });
  }

  void _toggleSolution() {
    setState(() {
      _showSolution = !_showSolution;
    });
  }

  IconData _getChallengeIcon() {
    switch (widget.scenario.challengeType) {
      case ChallengeType.multipleChoice:
        return Icons.quiz;
      case ChallengeType.terminal:
        return Icons.terminal;
      case ChallengeType.workbench:
        return Icons.work;
      case ChallengeType.codeReview:
        return Icons.code;
      case ChallengeType.passwordValidation:
        return Icons.lock;
      case ChallengeType.storyScenario:
        return Icons.auto_stories;
      default:
        return Icons.help;
    }
  }

  String _getChallengeTypeName() {
    switch (widget.scenario.challengeType) {
      case ChallengeType.multipleChoice:
        return 'Multiple Choice Quiz';
      case ChallengeType.terminal:
        return 'Terminal Challenge';
      case ChallengeType.workbench:
        return 'Workbench Analysis';
      case ChallengeType.codeReview:
        return 'Code Review';
      case ChallengeType.passwordValidation:
        return 'Password Validation';
      case ChallengeType.storyScenario:
        return 'Story Scenario';
      default:
        return 'Challenge';
    }
  }

  void _showChapterCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.auto_stories,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text('Chapter ${_currentChapter} Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Excellent work! You\'ve completed Chapter ${_currentChapter} of the story.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Story Progress',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chapter ${_currentChapter + 1} of ${_storyChapters.length} unlocked!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'The story continues with new challenges and deeper cybersecurity scenarios. Ready for the next chapter?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog and continue to next chapter
            },
            child: const Text('Continue Story'),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    final dataPayload = widget.scenario.content.dataPayload;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Scenario Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Congratulations! You\'ve completed "${widget.scenario.title}"'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '+${widget.scenario.xpReward} XP Earned!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (dataPayload['explanation'] != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explanation:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dataPayload['explanation'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Great job! You\'re making progress through the story.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Call the callback to mark scenario as completed
              widget.onScenarioCompleted?.call(widget.scenario.id);
              Navigator.pop(context); // Return to story screen
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

// Story progression models
class StoryStep {
  final String id;
  final String title;
  final String description;
  final String narrative;
  final List<StoryChoice> choices;

  StoryStep({
    required this.id,
    required this.title,
    required this.description,
    required this.narrative,
    required this.choices,
  });
}

class StoryChoice {
  final String id;
  final String text;
  final bool isCorrect;
  final String feedback;
  final String nextStep;

  StoryChoice({
    required this.id,
    required this.text,
    required this.isCorrect,
    required this.feedback,
    required this.nextStep,
  });
}


