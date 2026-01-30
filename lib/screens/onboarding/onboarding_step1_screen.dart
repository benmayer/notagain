// Onboarding Step 1 - Name Input
// User enters their full name (required, not skippable)

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';
import '../../providers/auth_provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../services/supabase_service.dart';

class OnboardingStep1Screen extends StatefulWidget {
  const OnboardingStep1Screen({super.key});

  @override
  State<OnboardingStep1Screen> createState() => _OnboardingStep1ScreenState();
}

class _OnboardingStep1ScreenState extends State<OnboardingStep1Screen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    
    // Initialize provider and prefill name if available
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<OnboardingProvider>();
      final authProvider = context.read<AuthProvider>();
      
      await provider.init();
      
      // Prefill name from provider or user if available
      if (provider.name != null) {
        _nameController.text = provider.name!;
      } else {
        final user = authProvider.user;
        if (user?.fullName != null && user!.fullName!.isNotEmpty) {
          _nameController.text = user.fullName!;
          await provider.setName(user.fullName!);
        }
      }
    });
    
    // Listen for name changes to trigger provider updates
    _nameController.addListener(() {
      if (mounted) {
        // Note: setName is async but we don't await here to avoid blocking UI
        // The provider will notifyListeners() internally which rebuilds the button
        context.read<OnboardingProvider>().setName(_nameController.text);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _showAbandonDialog() async {
    if (!mounted) return;
    
    final result = await showFDialog<bool>(
      context: context,
      builder: (context, style, animation) => FDialog(
        title: const Text('Discard Onboarding?'),
        body: const Text('Your progress will be lost. You can resume later by logging in again.'),
        actions: [
          FButton(
            style: FButtonStyle.outline(),
            onPress: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FButton(
            onPress: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      context.read<OnboardingProvider>().abandonOnboarding();
      await context.read<AuthProvider>().logout();
      if (mounted) {
        context.go('/');
      }
    }
  }

  Future<void> _handleNext() async {
    final provider = context.read<OnboardingProvider>();
    final authProvider = context.read<AuthProvider>();
    
    if (_nameController.text.trim().isEmpty) {
      if (!mounted) return;
      showFToast(
        context: context,
        alignment: FToastAlignment.bottomCenter,
        icon: Icon(FIcons.triangleAlert, color: context.theme.colors.primary),
        title: const Text('Name Required'),
        description: const Text('Please enter your name to continue'),
        duration: AppConstants.toastDuration,
      );
      return;
    }

    provider.setLoading(true);

    try {
      final name = _nameController.text.trim();
      await provider.setName(name);

      final user = authProvider.user;
      if (user == null) {
        if (mounted) {
          showFToast(
            context: context,
            alignment: FToastAlignment.bottomCenter,
            icon: Icon(FIcons.triangleAlert, color: context.theme.colors.primary),
            title: const Text('Error'),
            description: const Text('User not found'),
            duration: AppConstants.toastDuration,
          );
        }
        return;
      }

      await SupabaseService().updateUserProfile(
        userId: user.id,
        fullName: name,
      );

      authProvider.updateUser(user.copyWith(fullName: name));

      await provider.nextStep();

      if (mounted) {
        context.push('/onboarding/step2');
      }
    } catch (e) {
      AppLogger.error('Step 1: Error during next: $e', tag: 'OnboardingStep1');
      if (mounted) {
        showFToast(
          context: context,
          alignment: FToastAlignment.bottomCenter,
          icon: Icon(FIcons.triangleAlert, color: context.theme.colors.primary),
          title: const Text('Error'),
          description: const Text('Failed to save progress'),
          duration: AppConstants.toastDuration,
        );
      }
    } finally {
      provider.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();

    return FScaffold(
      child: Column(
        children: [
          FHeader.nested(
            title: const Text('Step 1 of 2'),
            prefixes: [
              FHeaderAction.back(
                onPress: _showAbandonDialog,
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppConstants.standardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Text(
                    'What\'s your name?',
                    style: context.theme.typography.xl2.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppConstants.standardPadding),
                  Text(
                    'This will help personalize your experience',
                    style: context.theme.typography.sm.copyWith(
                      color: context.theme.colors.mutedForeground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppConstants.largeGap),

                  // Name input
                  FTextFormField(
                    control: FTextFieldControl.managed(controller: _nameController),
                    label: const Text('Full Name'),
                    hint: 'John Doe',
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(height: AppConstants.largeGap),

                  // Next button - use ValueListenableBuilder for reactivity
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _nameController,
                    builder: (context, value, child) {
                      final canSubmit = value.text.trim().isNotEmpty && !provider.isLoading;

                      return FButton(
                        onPress: canSubmit ? _handleNext : null,
                        prefix: provider.isLoading ? const FCircularProgress() : null,
                        child: Text(provider.isLoading ? 'Saving...' : 'Next'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
