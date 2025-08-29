import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../utils/app_theme.dart';
import 'base_mission_screen.dart';

class PasswordLabScreen extends BaseMissionScreen {
  const PasswordLabScreen({super.key, required super.mission});

  @override
  ConsumerState<BaseMissionScreen> createStateImpl() => _PasswordLabScreenState();
}

class _PasswordLabScreenState extends BaseMissionScreenState<PasswordLabScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  
  bool _showPassword = false;

  
  // Password validation criteria
  final Map<String, bool> _criteria = {
    'length': false,
    'uppercase': false,
    'lowercase': false,
    'numbers': false,
    'specialChars': false,
    'noCommonPatterns': false,
  };
  
  final Map<String, String> _criteriaLabels = {
    'length': 'At least 12 characters',
    'uppercase': 'Contains uppercase letter (A-Z)',
    'lowercase': 'Contains lowercase letter (a-z)',
    'numbers': 'Contains number (0-9)',
    'specialChars': 'Contains special character (!@#\$%^&*)',
    'noCommonPatterns': 'No common patterns (123, abc, qwerty)',
  };

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final password = _passwordController.text;
    
    setState(() {
      _criteria['length'] = password.length >= 12;
      _criteria['uppercase'] = password.contains(RegExp(r'[A-Z]'));
      _criteria['lowercase'] = password.contains(RegExp(r'[a-z]'));
      _criteria['numbers'] = password.contains(RegExp(r'[0-9]'));
      _criteria['specialChars'] = password.contains(RegExp('[!@#\$%^&*()_+\\-=\\[\\]{};\':"\\\\|,.<>/?]'));
      _criteria['noCommonPatterns'] = !_hasCommonPatterns(password);
    });
  }

  bool _hasCommonPatterns(String password) {
    final commonPatterns = [
      '123', 'abc', 'qwerty', 'password', 'admin', 'letmein',
      'welcome', 'monkey', 'dragon', 'master', 'football'
    ];
    
    final lowerPassword = password.toLowerCase();
    return commonPatterns.any((pattern) => lowerPassword.contains(pattern));
  }

  bool get _isPasswordValid {
    return _criteria.values.every((criterion) => criterion);
  }

  void _generateStrongPassword() {
    const String uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const String numbers = '0123456789';
    const String special = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
    
    final random = Random();
    String password = '';
    
    // Ensure at least one of each required character type
    password += uppercase[random.nextInt(uppercase.length)];
    password += lowercase[random.nextInt(lowercase.length)];
    password += numbers[random.nextInt(numbers.length)];
    password += special[random.nextInt(special.length)];
    
    // Fill the rest randomly
    const allChars = uppercase + lowercase + numbers + special;
    for (int i = 4; i < 16; i++) {
      password += allChars[random.nextInt(allChars.length)];
    }
    
    // Shuffle the password
    final passwordList = password.split('');
    passwordList.shuffle(random);
    password = passwordList.join();
    
    setState(() {
      _passwordController.text = password;
    });
  }

  void _copyToClipboard() {
    if (_passwordController.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _passwordController.text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password copied to clipboard!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _submitPassword() {
    if (_isPasswordValid) {
      completeMission();
      showSuccessAndExit();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please meet all security criteria first!'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget buildMissionContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMissionHeader(),
          const SizedBox(height: 32),
          _buildPasswordInput(),
          const SizedBox(height: 24),
          _buildValidationCriteria(),
          const SizedBox(height: 32),
          _buildActionButtons(),
          const SizedBox(height: 32),
          _buildSecurityTips(),
        ],
      ),
    );
  }

  Widget _buildMissionHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🔐 Password Lab',
          style: AppTheme.getHeadlineMedium(isDark).copyWith(
            color: AppTheme.primaryPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.mission.description,
          style: AppTheme.getBodyLarge(isDark),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark 
                ? AppTheme.accentBlue.withOpacity(0.1)
                : AppTheme.accentBlue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark 
                  ? AppTheme.accentBlue.withOpacity(0.3)
                  : AppTheme.accentBlue.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.accentBlue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Create a password that meets all security criteria below. '
                  'Your password will be validated in real-time!',
                  style: TextStyle(color: AppTheme.accentBlue),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Your Password',
          style: AppTheme.getHeadlineSmall(isDark).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  hintText: 'Type your password here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                ),
                onChanged: (_) => _validatePassword(),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: _copyToClipboard,
              icon: const Icon(Icons.copy),
              tooltip: 'Copy to clipboard',
              style: IconButton.styleFrom(
                backgroundColor: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Strength: ',
              style: AppTheme.getBodySmall(isDark),
            ),
            Expanded(
              child: LinearProgressIndicator(
                value: _criteria.values.where((c) => c).length / _criteria.length,
                backgroundColor: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _isPasswordValid ? AppTheme.accentGreen : AppTheme.accentOrange,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${_criteria.values.where((c) => c).length}/${_criteria.length}',
              style: AppTheme.getBodySmall(isDark).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildValidationCriteria() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Security Criteria',
          style: AppTheme.getHeadlineSmall(isDark).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._criteria.entries.map((entry) {
          final isMet = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isMet ? AppTheme.accentGreen : (isDark ? AppTheme.dividerDark : AppTheme.dividerLight),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isMet ? Icons.check : Icons.close,
                    color: isMet ? Colors.white : (isDark ? AppTheme.textLightDark : AppTheme.textLight),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _criteriaLabels[entry.key]!,
                    style: TextStyle(
                      color: isMet ? AppTheme.accentGreen : (isDark ? AppTheme.textLightDark : AppTheme.textLight),
                      fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildActionButtons() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _generateStrongPassword,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate Strong Password'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isPasswordValid ? _submitPassword : null,
            icon: const Icon(Icons.security),
            label: const Text('Submit Password'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isPasswordValid ? AppTheme.accentGreen : (isDark ? AppTheme.dividerDark : AppTheme.dividerLight),
              foregroundColor: Colors.white,
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

  Widget _buildSecurityTips() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark 
            ? AppTheme.accentOrange.withOpacity(0.1)
            : AppTheme.accentOrange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
              ? AppTheme.accentOrange.withOpacity(0.3)
              : AppTheme.accentOrange.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppTheme.accentOrange),
              const SizedBox(width: 12),
              Text(
                'Security Tips',
                style: AppTheme.getHeadlineSmall(isDark).copyWith(
                  color: AppTheme.accentOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTip('Never reuse passwords across different accounts'),
          _buildTip('Consider using a password manager for better security'),
          _buildTip('Change passwords regularly, especially for critical accounts'),
          _buildTip('Enable two-factor authentication when available'),
        ],
      ),
    );
  }

  Widget _buildTip(String tip) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.arrow_right, color: AppTheme.accentOrange, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                color: AppTheme.accentOrange,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  double getProgressValue() {
    // Return progress based on how many criteria are met
    return _criteria.values.where((c) => c).length / _criteria.length;
  }
}
