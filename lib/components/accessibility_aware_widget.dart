import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../utils/app_theme.dart';

class AccessibilityAwareWidget extends ConsumerWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isEnabled;

  const AccessibilityAwareWidget({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeService = ref.watch(themeServiceProvider);

    // Get accessibility-aware styling
    final textScaleFactor = themeService.textScaleFactor;
    final isHighContrast = themeService.isHighContrast;

    return Card(
          elevation: isHighContrast ? 4 : 2,
          shadowColor: isHighContrast 
            ? AppTheme.highContrastAccent.withOpacity(0.5)
            : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            side: isHighContrast 
              ? const BorderSide(color: AppTheme.highContrastAccent, width: 2)
              : BorderSide.none,
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spaceMedium),
              child: Row(
                children: [
                  // Icon with accessibility
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spaceSmall),
                    decoration: BoxDecoration(
                      color: isHighContrast 
                        ? AppTheme.highContrastAccent
                        : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Icon(
                      icon,
                      color: isHighContrast 
                        ? Colors.black
                        : Theme.of(context).colorScheme.primary,
                      size: 24 * textScaleFactor,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceMedium),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: (Theme.of(context).textTheme.titleMedium?.fontSize ?? 16) * textScaleFactor,
                            fontWeight: FontWeight.w600,
                            color: isHighContrast 
                              ? AppTheme.highContrastText
                              : null,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceSmall),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) * textScaleFactor,
                            color: isHighContrast 
                              ? AppTheme.highContrastText
                              : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status indicator
                  const SizedBox(width: AppTheme.spaceSmall),
                  Container(
                    width: 12 * textScaleFactor,
                    height: 12 * textScaleFactor,
                    decoration: BoxDecoration(
                      color: isEnabled 
                        ? (isHighContrast ? AppTheme.highContrastSuccess : AppTheme.semanticSuccess)
                        : (isHighContrast ? AppTheme.highContrastError : AppTheme.semanticError),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
  }
}

/// Accessibility-aware button with enhanced features
class AccessibilityAwareButton extends ConsumerWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool isLoading;

  const AccessibilityAwareButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeService = ref.watch(themeServiceProvider);

    final textScaleFactor = themeService.textScaleFactor;
    final isHighContrast = themeService.isHighContrast;

    // Get animation duration based on accessibility settings
    final animationDuration = const Duration(milliseconds: 200);

    return AnimatedContainer(
          duration: animationDuration,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isHighContrast 
                ? AppTheme.highContrastAccent
                : (isPrimary ? null : Theme.of(context).colorScheme.secondary),
              foregroundColor: isHighContrast 
                ? Colors.black
                : null,
              elevation: isHighContrast ? 4 : 2,
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spaceLarge * textScaleFactor,
                vertical: AppTheme.spaceMedium * textScaleFactor,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                side: isHighContrast 
                  ? const BorderSide(color: AppTheme.highContrastAccent, width: 2)
                  : BorderSide.none,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 16 * textScaleFactor,
                    height: 16 * textScaleFactor,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isHighContrast ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: AppTheme.spaceSmall * textScaleFactor),
                ],
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 18 * textScaleFactor,
                  ),
                  SizedBox(width: AppTheme.spaceSmall * textScaleFactor),
                ],
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16 * textScaleFactor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
  }
}

