import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:shared_core/shared_core.dart';
import 'services/missions_service.dart';
import 'services/tracks_service.dart';
import 'services/users_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CyberShujaa Admin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AdminAuthWrapper(),
    );
  }
}

class AdminAuthWrapper extends StatelessWidget {
  const AdminAuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          // Check if user has admin claim
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('admin')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, adminSnapshot) {
              if (adminSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              
              if (adminSnapshot.hasData && 
                  adminSnapshot.data!.exists && 
                  (adminSnapshot.data!.data() as Map<String, dynamic>?)?['role'] == 'admin') {
                return const AdminShell();
              } else {
                // User exists but not admin
                return const AdminLoginScreen(
                  errorMessage: 'Access denied. Admin privileges required.',
                );
              }
            },
          );
        }
        
        // No user logged in
        return const AdminLoginScreen();
      },
    );
  }
}

class AdminLoginScreen extends StatefulWidget {
  final String? errorMessage;
  
  const AdminLoginScreen({super.key, this.errorMessage});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _errorMessage = widget.errorMessage;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Authentication failed';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CyberShujaa Admin Login'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'CyberShujaa Admin Portal',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 32),
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade800),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Sign In'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  _AdminShellState createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);
    _tabController!.addListener(() {
      setState(() {
        _currentIndex = _tabController!.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: const [
              MissionsPage(),
              TracksPage(),
              UsersPage(),
              DashboardPage(),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).cardColor.withAlpha(220),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: const BoxDecoration(),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: Theme.of(context).colorScheme.primary,
                tabs: [
                  _buildTab(0, "Missions", Icons.assignment),
                  _buildTab(1, "Tracks", Icons.track_changes),
                  _buildTab(2, "Users", Icons.people),
                  _buildTab(3, "Dashboard", Icons.dashboard),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label, IconData icon) {
    final isSelected = _currentIndex == index;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: isSelected
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ],
            )
          : Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.onSurface,
            ),
    );
  }
}

class MissionsPage extends StatefulWidget {
  const MissionsPage({super.key});

  @override
  State<MissionsPage> createState() => _MissionsPageState();
}

class _MissionsPageState extends State<MissionsPage> {
  final AdminMissionsService _missionsService = AdminMissionsService();
  List<Mission> _missions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMissions();
  }

  Future<void> _loadMissions() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final missions = await _missionsService.getMissions();
      setState(() {
        _missions = missions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading missions: $e')),
        );
      }
    }
  }

  void _showMissionDialog([Mission? mission]) {
    showDialog(
      context: context,
      builder: (context) => MissionDialog(
        mission: mission,
        onSave: (mission) async {
          try {
            await _missionsService.saveMission(mission);
            if (mounted) {
              Navigator.of(context).pop();
              _loadMissions();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mission saved successfully!')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error saving mission: $e')),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Missions Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showMissionDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMissions,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _missions.isEmpty
              ? const Center(
                  child: Text('No missions found. Create your first mission!'),
                )
              : ListView.builder(
                  itemCount: _missions.length,
                  itemBuilder: (context, index) {
                    final mission = _missions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        title: Text(mission.title),
                        subtitle: Text(mission.description),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(
                              label: Text(mission.difficulty.toString().replaceAll('MissionDifficulty.', '')),
                              backgroundColor: _getDifficultyColor(mission.difficulty),
                            ),
                            const SizedBox(width: 8),
                            Switch(
                              value: mission.status == MissionStatus.available,
                              onChanged: (value) async {
                                try {
                                  final newStatus = value ? MissionStatus.available : MissionStatus.locked;
                                  final updatedMission = mission.copyWith(status: newStatus);
                                  await _missionsService.saveMission(updatedMission);
                                  _loadMissions();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Mission ${value ? 'published' : 'unpublished'} successfully!')),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error updating mission: $e')),
                                    );
                                  }
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteMissionDialog(mission),
                              tooltip: 'Delete Mission',
                            ),
                          ],
                        ),
                        onTap: () => _showMissionDialog(mission),
                      ),
                    );
                  },
                ),
    );
  }

  Color _getDifficultyColor(MissionDifficulty difficulty) {
    switch (difficulty) {
      case MissionDifficulty.beginner:
        return Colors.green.withOpacity(0.2);
      case MissionDifficulty.intermediate:
        return Colors.orange.withOpacity(0.2);
      case MissionDifficulty.advanced:
        return Colors.red.withOpacity(0.2);
      case MissionDifficulty.expert:
        return Colors.purple.withOpacity(0.2);
    }
  }

  void _showDeleteMissionDialog(Mission mission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Mission: ${mission.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚠️ Warning: This action cannot be undone!'),
            const SizedBox(height: 16),
            Text('Are you sure you want to delete "${mission.title}"?'),
            const SizedBox(height: 8),
            const Text('This will permanently remove the mission and all associated data.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _missionsService.deleteMission(mission.id);
                Navigator.of(context).pop();
                _loadMissions();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mission deleted successfully!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting mission: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Mission'),
          ),
        ],
      ),
    );
  }
}

class MissionDialog extends StatefulWidget {
  final Mission? mission;
  final Function(Mission) onSave;

  const MissionDialog({
    super.key,
    this.mission,
    required this.onSave,
  });

  @override
  State<MissionDialog> createState() => _MissionDialogState();
}

class _MissionDialogState extends State<MissionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _requiredLevelController;
  late TextEditingController _xpRewardController;
  late TextEditingController _gemRewardController;
  
  MissionType _selectedType = MissionType.interactiveQuiz;
  MissionDifficulty _selectedDifficulty = MissionDifficulty.beginner;
  MissionCategory _selectedCategory = MissionCategory.educationYouth;
  MissionStatus _selectedStatus = MissionStatus.available;
  
  List<Challenge> _challenges = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.mission?.title ?? '');
    _descriptionController = TextEditingController(text: widget.mission?.description ?? '');
    _requiredLevelController = TextEditingController(text: '${widget.mission?.requiredLevel ?? 1}');
    _xpRewardController = TextEditingController(text: '${widget.mission?.xpReward ?? 100}');
    _gemRewardController = TextEditingController(text: '${widget.mission?.gemReward ?? 0}');
    
    if (widget.mission != null) {
      _selectedType = widget.mission!.type;
      _selectedDifficulty = widget.mission!.difficulty;
      _selectedCategory = widget.mission!.category;
      _selectedStatus = widget.mission!.status;
      _challenges = List.from(widget.mission!.challenges);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _requiredLevelController.dispose();
    _xpRewardController.dispose();
    _gemRewardController.dispose();
    super.dispose();
  }

  void _addQuizChallenge() {
    showDialog(
      context: context,
      builder: (context) => QuizChallengeDialog(
        onSave: (challenge) {
          setState(() {
            _challenges.add(challenge);
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _editQuizChallenge(int index) {
    showDialog(
      context: context,
      builder: (context) => QuizChallengeDialog(
        challenge: _challenges[index],
        onSave: (challenge) {
          setState(() {
            _challenges[index] = challenge;
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _removeQuizChallenge(int index) {
    setState(() {
      _challenges.removeAt(index);
    });
  }

  void _saveMission() {
    if (_formKey.currentState!.validate()) {
      final mission = Mission(
        id: widget.mission?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        type: _selectedType,
        difficulty: _selectedDifficulty,
        category: _selectedCategory,
        status: _selectedStatus,
        requiredLevel: int.parse(_requiredLevelController.text),
        xpReward: int.parse(_xpRewardController.text),
        gemReward: int.parse(_gemRewardController.text),
        challenges: _challenges,
      );
      
      widget.onSave(mission);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.mission == null ? 'Create Mission' : 'Edit Mission'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<MissionType>(
                        value: _selectedType,
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: MissionType.values.map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.toString().replaceAll('MissionType.', '')),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<MissionDifficulty>(
                        value: _selectedDifficulty,
                        decoration: const InputDecoration(labelText: 'Difficulty'),
                        items: MissionDifficulty.values.map((difficulty) => DropdownMenuItem(
                          value: difficulty,
                          child: Text(difficulty.toString().replaceAll('MissionDifficulty.', '')),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDifficulty = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<MissionCategory>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(labelText: 'Category'),
                        items: MissionCategory.values.map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category.toString().replaceAll('MissionCategory.', '')),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<MissionStatus>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: MissionStatus.values.map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.toString().replaceAll('MissionStatus.', '')),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _requiredLevelController,
                        decoration: const InputDecoration(labelText: 'Required Level'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter required level';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _xpRewardController,
                        decoration: const InputDecoration(labelText: 'XP Reward'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter XP reward';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _gemRewardController,
                        decoration: const InputDecoration(labelText: 'Gem Reward'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter gem reward';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                
                // Quiz Challenges Section (only show for interactive quiz missions)
                if (_selectedType == MissionType.interactiveQuiz) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quiz Challenges',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      ElevatedButton.icon(
                        onPressed: _addQuizChallenge,
                        icon: const Icon(Icons.quiz),
                        label: const Text('Add Quiz Challenge'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Display existing challenges
                  ...List.generate(_challenges.length, (index) {
                    final challenge = _challenges[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.quiz_outlined, color: Colors.blue),
                        title: Text(challenge.title),
                        subtitle: Text('${challenge.content.dataPayload['questions']?.length ?? 0} questions'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${challenge.xpReward} XP'),
                            IconButton(
                              onPressed: () => _editQuizChallenge(index),
                              icon: const Icon(Icons.edit),
                              tooltip: 'Edit Challenge',
                            ),
                            IconButton(
                              onPressed: () => _removeQuizChallenge(index),
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Remove Challenge',
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveMission,
          child: Text(widget.mission == null ? 'Create' : 'Save'),
        ),
      ],
    );
  }
}

class QuizChallengeDialog extends StatefulWidget {
  final Challenge? challenge;
  final Function(Challenge) onSave;

  const QuizChallengeDialog({
    super.key,
    this.challenge,
    required this.onSave,
  });

  @override
  State<QuizChallengeDialog> createState() => _QuizChallengeDialogState();
}

class _QuizChallengeDialogState extends State<QuizChallengeDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _xpRewardController;
  
  final List<Map<String, dynamic>> _questions = [];
  final List<TextEditingController> _questionControllers = [];
  final List<List<TextEditingController>> _optionControllers = [];
  final List<TextEditingController> _correctAnswerControllers = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.challenge?.title ?? '');
    _descriptionController = TextEditingController(text: widget.challenge?.description ?? '');
    _xpRewardController = TextEditingController(text: '${widget.challenge?.xpReward ?? 50}');
    
    // Load existing questions if editing
    if (widget.challenge != null && 
        widget.challenge!.content.dataPayload.containsKey('questions')) {
      final questions = widget.challenge!.content.dataPayload['questions'] as List;
      for (var question in questions) {
        _addQuestion(
          question: question['question'] as String,
          options: List<String>.from(question['options']),
          correct: question['correct'] as int,
        );
      }
    } else {
      // Add one default question
      _addQuestion();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _xpRewardController.dispose();
    for (var controller in _questionControllers) {
      controller.dispose();
    }
    for (var optionList in _optionControllers) {
      for (var controller in optionList) {
        controller.dispose();
      }
    }
    for (var controller in _correctAnswerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addQuestion({String? question, List<String>? options, int? correct}) {
    final questionController = TextEditingController(text: question ?? '');
    final optionControllers = <TextEditingController>[];
    final correctController = TextEditingController(text: '${correct ?? 0}');
    
    // Add 4 default options
    for (int i = 0; i < 4; i++) {
      optionControllers.add(TextEditingController(
        text: options != null && i < options.length ? options[i] : 'Option ${i + 1}'
      ));
    }
    
    setState(() {
      _questions.add({
        'question': question ?? '',
        'options': options ?? ['Option 1', 'Option 2', 'Option 3', 'Option 4'],
        'correct': correct ?? 0,
      });
      _questionControllers.add(questionController);
      _optionControllers.add(optionControllers);
      _correctAnswerControllers.add(correctController);
    });
  }

  void _removeQuestion(int index) {
    if (_questions.length > 1) {
      setState(() {
        _questions.removeAt(index);
        _questionControllers[index].dispose();
        _optionControllers[index].forEach((controller) => controller.dispose());
        _correctAnswerControllers[index].dispose();
        
        _questionControllers.removeAt(index);
        _optionControllers.removeAt(index);
        _correctAnswerControllers.removeAt(index);
      });
    }
  }

  void _saveChallenge() {
    if (_formKey.currentState!.validate()) {
      // Update questions from controllers
      for (int i = 0; i < _questions.length; i++) {
        _questions[i]['question'] = _questionControllers[i].text;
        _questions[i]['options'] = _optionControllers[i].map((c) => c.text).toList();
        _questions[i]['correct'] = int.parse(_correctAnswerControllers[i].text);
      }

      final challenge = Challenge(
        id: widget.challenge?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        type: ChallengeType.multipleChoice,
        content: ChallengeContent(
          dataType: 'quiz',
          toolType: 'multiple_choice',
          solution: 'Complete all questions correctly',
          guidePoints: ['Read each question carefully', 'Select the best answer'],
          dataPayload: {'questions': _questions},
        ),
        xpReward: int.parse(_xpRewardController.text),
      );
      
      widget.onSave(challenge);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.challenge == null ? 'Create Quiz Challenge' : 'Edit Quiz Challenge'),
      content: SizedBox(
        width: 600,
        height: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Challenge Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _xpRewardController,
                  decoration: const InputDecoration(labelText: 'XP Reward'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter XP reward';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Questions section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quiz Questions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _addQuestion(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Question'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Questions list
                ...List.generate(_questions.length, (questionIndex) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Question ${questionIndex + 1}',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              if (_questions.length > 1)
                                IconButton(
                                  onPressed: () => _removeQuestion(questionIndex),
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'Remove Question',
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _questionControllers[questionIndex],
                            decoration: const InputDecoration(
                              labelText: 'Question Text',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter question text';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Options
                          Text(
                            'Options:',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          ...List.generate(4, (optionIndex) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Radio<int>(
                                    value: optionIndex,
                                    groupValue: int.parse(_correctAnswerControllers[questionIndex].text),
                                    onChanged: (value) {
                                      setState(() {
                                        _correctAnswerControllers[questionIndex].text = value.toString();
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _optionControllers[questionIndex][optionIndex],
                                      decoration: InputDecoration(
                                        labelText: 'Option ${String.fromCharCode(65 + optionIndex)}',
                                        border: const OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter option text';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          
                          const SizedBox(height: 8),
                          Text(
                            'Correct Answer: Option ${String.fromCharCode(65 + int.parse(_correctAnswerControllers[questionIndex].text))}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveChallenge,
          child: Text(widget.challenge == null ? 'Create' : 'Save'),
        ),
      ],
    );
  }
}

class TrackDialog extends StatefulWidget {
  final Track? track;
  final Function(Track) onSave;

  const TrackDialog({
    super.key,
    this.track,
    required this.onSave,
  });

  @override
  State<TrackDialog> createState() => _TrackDialogState();
}

class _TrackDialogState extends State<TrackDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _orderController;
  String _selectedLocale = 'en';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.track?.name ?? '');
    _descriptionController = TextEditingController(text: widget.track?.description ?? '');
    _orderController = TextEditingController(text: '${widget.track?.order ?? 0}');
    _selectedLocale = widget.track?.locale ?? 'en';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  void _saveTrack() {
    if (_formKey.currentState!.validate()) {
      final track = Track(
        id: widget.track?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        order: int.parse(_orderController.text),
        locale: _selectedLocale,
        isPublished: widget.track?.isPublished ?? false,
        createdAt: widget.track?.createdAt,
      );
      
      widget.onSave(track);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.track == null ? 'Create Track' : 'Edit Track'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _orderController,
                      decoration: const InputDecoration(labelText: 'Order'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter order';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedLocale,
                      decoration: const InputDecoration(labelText: 'Locale'),
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'sw', child: Text('Swahili')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedLocale = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveTrack,
          child: Text(widget.track == null ? 'Create' : 'Save'),
        ),
      ],
    );
  }
}

class TracksPage extends StatefulWidget {
  const TracksPage({super.key});

  @override
  State<TracksPage> createState() => _TracksPageState();
}

class _TracksPageState extends State<TracksPage> {
  final AdminTracksService _tracksService = AdminTracksService();
  List<Track> _tracks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTracks();
  }

  Future<void> _loadTracks() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final tracks = await _tracksService.getTracks();
      setState(() {
        _tracks = tracks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tracks: $e')),
        );
      }
    }
  }

  void _showTrackDialog([Track? track]) {
    showDialog(
      context: context,
      builder: (context) => TrackDialog(
        track: track,
        onSave: (track) async {
          try {
            await _tracksService.saveTrack(track);
            if (mounted) {
              Navigator.of(context).pop();
              _loadTracks();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Track saved successfully!')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error saving track: $e')),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracks Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showTrackDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTracks,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tracks.isEmpty
              ? const Center(
                  child: Text('No tracks found. Create your first track!'),
                )
              : ReorderableListView.builder(
                  itemCount: _tracks.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final item = _tracks.removeAt(oldIndex);
                      _tracks.insert(newIndex, item);
                    });
                    
                    // Update order in Firestore
                    final trackIds = _tracks.map((t) => t.id).toList();
                    _tracksService.reorderTracks(trackIds);
                  },
                  itemBuilder: (context, index) {
                    final track = _tracks[index];
                    return Card(
                      key: ValueKey(track.id),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.drag_handle),
                        title: Text(track.name),
                        subtitle: Text(track.description),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(
                              label: Text('${track.order + 1}'),
                              backgroundColor: Colors.blue.withOpacity(0.2),
                            ),
                            const SizedBox(width: 8),
                            Switch(
                              value: track.isPublished,
                              onChanged: (value) async {
                                try {
                                  await _tracksService.toggleTrackPublish(track.id, value);
                                  _loadTracks();
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error updating track: $e')),
                                    );
                                  }
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteTrackDialog(track),
                              tooltip: 'Delete Track',
                            ),
                          ],
                        ),
                        onTap: () => _showTrackDialog(track),
                      ),
                    );
                  },
                ),
    );
  }

  void _showDeleteTrackDialog(Track track) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Track: ${track.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚠️ Warning: This action cannot be undone!'),
            const SizedBox(height: 16),
            Text('Are you sure you want to delete "${track.name}"?'),
            const SizedBox(height: 8),
            const Text('This will permanently remove the track and all associated data.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _tracksService.deleteTrack(track.id);
                Navigator.of(context).pop();
                _loadTracks();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Track deleted successfully!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting track: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Track'),
          ),
        ],
      ),
    );
  }
}

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final AdminUsersService _usersService = AdminUsersService();
  List<AppUser> _users = [];
  bool _isLoading = true;
  AppUser? _selectedUser;
  Map<String, dynamic>? _userStats;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final users = await _usersService.getUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e')),
        );
      }
    }
  }

  Future<void> _searchUsers(String query) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final users = await _usersService.searchUsers(query);
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching users: $e')),
        );
      }
    }
  }

  Future<void> _selectUser(AppUser user) async {
    setState(() {
      _selectedUser = user;
    });
    
    try {
      final stats = await _usersService.getUserStats(user.uid);
      setState(() {
        _userStats = stats;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user stats: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Row(
        children: [
          // Users list
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search users',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value.isEmpty) {
                        _loadUsers();
                      } else {
                        _searchUsers(value);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _users.isEmpty
                          ? const Center(
                              child: Text('No users found'),
                            )
                          : ListView.builder(
                              itemCount: _users.length,
                              itemBuilder: (context, index) {
                                final user = _users[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    child: Text(user.displayName[0].toUpperCase()),
                                  ),
                                  title: Text(user.displayName),
                                  subtitle: Text(user.email),
                                  trailing: Chip(
                                    label: Text('Level ${user.level}'),
                                    backgroundColor: Colors.blue.withOpacity(0.2),
                                  ),
                                  onTap: () => _selectUser(user),
                                  selected: _selectedUser?.uid == user.uid,
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
          // User details
          if (_selectedUser != null)
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedUser!.displayName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedUser!.email,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      if (_userStats != null) ...[
                        _buildStatCard('Level', '${_selectedUser!.level}'),
                        _buildStatCard('XP', '${_selectedUser!.xp}'),
                        _buildStatCard('Gems', '${_selectedUser!.gems}'),
                        _buildStatCard('Total Missions', '${_userStats!['totalMissions']}'),
                        _buildStatCard('Completed Missions', '${_userStats!['completedMissions']}'),
                        _buildStatCard('Achievements', '${_userStats!['unlockedAchievements']}/${_userStats!['totalAchievements']}'),
                      ],
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _showRoleManagementDialog(_selectedUser!),
                              child: const Text('Manage Role'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _showResetProgressDialog(_selectedUser!),
                              child: const Text('Reset Progress'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showRoleManagementDialog(AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Manage Role for ${user.displayName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Role: ${user.isAdmin ? 'Admin' : 'User'}'),
            const SizedBox(height: 16),
            const Text('Note: Role changes require a Cloud Function to update Firebase Auth custom claims.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final newRole = !user.isAdmin;
                await _usersService.updateUserRole(user.uid, newRole);
                Navigator.of(context).pop();
                _loadUsers();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('User role updated to ${newRole ? 'Admin' : 'User'}')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating user role: $e')),
                  );
                }
              }
            },
            child: Text('Make ${user.isAdmin ? 'User' : 'Admin'}'),
          ),
        ],
      ),
    );
  }

  void _showResetProgressDialog(AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Progress for ${user.displayName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚠️ Warning: This action cannot be undone!'),
            const SizedBox(height: 16),
            Text('This will reset:'),
            const SizedBox(height: 8),
            const Text('• User level back to 1'),
            const Text('• XP back to 0'),
            const Text('• All mission progress'),
            const Text('• Achievement progress'),
            const SizedBox(height: 16),
            const Text('Are you sure you want to continue?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _usersService.resetUserProgress(user.uid);
                Navigator.of(context).pop();
                _loadUsers();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User progress reset successfully!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error resetting user progress: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset Progress'),
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final AdminMissionsService _missionsService = AdminMissionsService();
  final AdminTracksService _tracksService = AdminTracksService();
  final AdminUsersService _usersService = AdminUsersService();
  
  List<Mission> _missions = [];
  List<Track> _tracks = [];
  List<AppUser> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final missions = await _missionsService.getMissions();
      final tracks = await _tracksService.getTracks();
      final users = await _usersService.getUsers();
      
      setState(() {
        _missions = missions;
        _tracks = tracks;
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dashboard data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overview',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  
                  // Stats cards
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Total Missions', '${_missions.length}', Icons.assignment, Colors.blue)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('Total Tracks', '${_tracks.length}', Icons.track_changes, Colors.green)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('Total Users', '${_users.length}', Icons.people, Colors.orange)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('Published Missions', '${_missions.where((m) => m.status == MissionStatus.available).length}', Icons.published_with_changes, Colors.purple)),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Recent activity
                  Text(
                    'Recent Activity',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      // Recent missions
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Recent Missions',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 16),
                                ..._missions.take(5).map((mission) => ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.assignment, size: 20),
                                  title: Text(mission.title, style: const TextStyle(fontSize: 14)),
                                  subtitle: Text(mission.difficulty.toString().replaceAll('MissionDifficulty.', ''), style: const TextStyle(fontSize: 12)),
                                  trailing: Chip(
                                    label: Text(mission.status.toString().replaceAll('MissionStatus.', '')),
                                    backgroundColor: _getStatusColor(mission.status).withOpacity(0.2),
                                    labelStyle: const TextStyle(fontSize: 10),
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Recent tracks
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Recent Tracks',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 16),
                                ..._tracks.take(5).map((track) => ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.track_changes, size: 20),
                                  title: Text(track.name, style: const TextStyle(fontSize: 14)),
                                  subtitle: Text('Order: ${track.order + 1}', style: const TextStyle(fontSize: 12)),
                                  trailing: Switch(
                                    value: track.isPublished,
                                    onChanged: (value) async {
                                      try {
                                        await _tracksService.toggleTrackPublish(track.id, value);
                                        _loadDashboardData();
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Error updating track: $e')),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Quick actions
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to missions page (index 0)
                            if (mounted) {
                              final adminShell = context.findAncestorStateOfType<_AdminShellState>();
                              adminShell?._tabController?.animateTo(0);
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Create Mission'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to tracks page (index 1)
                            if (mounted) {
                              final adminShell = context.findAncestorStateOfType<_AdminShellState>();
                              adminShell?._tabController?.animateTo(1);
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Create Track'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Export data
                          },
                          icon: const Icon(Icons.download),
                          label: const Text('Export Data'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(MissionStatus status) {
    switch (status) {
      case MissionStatus.available:
        return Colors.green;
      case MissionStatus.inProgress:
        return Colors.orange;
      case MissionStatus.completed:
        return Colors.blue;
      case MissionStatus.locked:
        return Colors.grey;
    }
  }
}
