// Onboarding Step 2 - Profile Picture Upload
// User optionally uploads a profile picture (skippable)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';
import '../../providers/auth_provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../services/supabase_service.dart';

class OnboardingStep2Screen extends StatefulWidget {
  const OnboardingStep2Screen({super.key});

  @override
  State<OnboardingStep2Screen> createState() => _OnboardingStep2ScreenState();
}

class _OnboardingStep2ScreenState extends State<OnboardingStep2Screen> {
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // No need to manipulate step here - Step 1 already advanced to step 2
    // Just initialize if needed
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<OnboardingProvider>();
      if (provider.currentStep < 1) {
        await provider.init();
      }
    });
  }

  Future<void> _handlePickImage(ImageSource source) async {
    final provider = context.read<OnboardingProvider>();
    
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        await provider.setPicture(File(image.path));
      }
    } catch (e) {
      AppLogger.error('Failed to pick image: $e', tag: 'OnboardingStep2');
      if (mounted) {
        showFToast(
          context: context,
          alignment: FToastAlignment.bottomCenter,
          icon: Icon(FIcons.triangleAlert, color: context.theme.colors.primary),
          title: const Text('Error'),
          description: const Text('Failed to pick image'),
          duration: AppConstants.toastDuration,
        );
      }
    }
  }

  // ignore_for_file: use_build_context_synchronously
  Future<void> _handleCompleteOnboarding({bool skipPicture = false}) async {
    final nav = context;
    final provider = context.read<OnboardingProvider>();
    final authProvider = context.read<AuthProvider>();
    
    provider.setLoading(true);
    
    try {
      final user = authProvider.user;
      if (user == null) {
        if (mounted) {
          showFToast(
            context: nav,
            alignment: FToastAlignment.bottomCenter,
            icon: Icon(FIcons.triangleAlert, color: nav.theme.colors.primary),
            title: const Text('Error'),
            description: const Text('User not found'),
            duration: AppConstants.toastDuration,
          );
        }
        return;
      }

      String? avatarUrl;

      // Upload picture if available
      if (!skipPicture && provider.pictureFile != null) {
        try {
          avatarUrl = await SupabaseService().uploadAvatar(
            userId: user.id,
            filePath: provider.pictureFile!.path,
          );
          
          // Update profile with avatar URL
          await SupabaseService().updateUserProfile(
            userId: user.id,
            fullName: user.fullName ?? provider.name ?? 'User',
            avatarUrl: avatarUrl,
          );
          
          authProvider.updateUser(user.copyWith(avatarUrl: avatarUrl));
        } catch (e) {
          AppLogger.error('Failed to upload avatar: $e', tag: 'OnboardingStep2');
          if (mounted) {
            showFToast(
              context: nav,
              alignment: FToastAlignment.bottomCenter,
              icon: Icon(FIcons.triangleAlert, color: nav.theme.colors.primary),
              title: const Text('Error'),
              description: const Text('Failed to upload photo'),
              duration: AppConstants.toastDuration,
            );
          }
          return;
        }
      }

      // Mark onboarding as complete
      await SupabaseService().updateOnboardingStatus(
        userId: user.id,
        completed: true,
      );

      // Update auth provider with new onboarding status
      final updatedUser = user.copyWith(
        onboardingCompleted: true,
        avatarUrl: avatarUrl ?? user.avatarUrl,
      );
      authProvider.updateUser(updatedUser);

      // Clear onboarding progress
      await provider.resetProgress();

      if (mounted) {
        nav.go('/home');
      }
    } catch (e) {
      AppLogger.error(
        'Failed to complete onboarding: $e',
        tag: 'OnboardingStep2',
      );
      if (mounted) {
        showFToast(
          context: nav,
          alignment: FToastAlignment.bottomCenter,
          icon: Icon(FIcons.triangleAlert, color: nav.theme.colors.primary),
          title: const Text('Error'),
          description: const Text('Failed to complete onboarding'),
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
            title: const Text('Step 2 of 2'),
            prefixes: [
              FHeaderAction.back(
                onPress: provider.isLoading
                    ? null
                    : () async {
                        final nav = context;
                        await provider.previousStep();
                        if (mounted) {
                          nav.go('/onboarding');
                        }
                      },
              ),
            ],
            suffixes: [
              GestureDetector(
                onTap: provider.isLoading
                    ? null
                    : () => _handleCompleteOnboarding(skipPicture: true),
                child: Text(
                  'Skip',
                  style: context.theme.typography.sm.copyWith(
                    color: provider.isLoading 
                        ? context.theme.colors.mutedForeground
                        : context.theme.colors.primary,
                  ),
                ),
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
                    'Add a profile picture',
                    style: context.theme.typography.xl2.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppConstants.extraSmallGap),

                  Text(
                    'Optional - you can skip this step',
                    style: context.theme.typography.sm.copyWith(
                      color: context.theme.colors.mutedForeground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppConstants.largeGap),

                  // Avatar preview
                  Center(
                    child: provider.pictureFile != null ||
                            provider.pictureUrl != null
                        ? FAvatar(
                            image: provider.pictureFile != null
                                ? FileImage(provider.pictureFile!)
                                : NetworkImage(provider.pictureUrl!)
                                    as ImageProvider,
                            size: 120,
                            fallback: Text(
                              provider.name?.substring(0, 1).toUpperCase() ??
                                  '?',
                              style: context.theme.typography.xl4,
                            ),
                          )
                        : FAvatar.raw(
                            size: 120,
                            child: Text(
                              provider.name?.substring(0, 1).toUpperCase() ??
                                  '?',
                              style: context.theme.typography.xl4,
                            ),
                          ),
                  ),
                  SizedBox(height: AppConstants.largeGap),

                  // Camera button
                  FButton(
                    style: FButtonStyle.outline(),
                    onPress: () => _handlePickImage(ImageSource.camera),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FIcons.camera, size: 18),
                        SizedBox(width: AppConstants.extraSmallGap),
                        const Text('Take Photo'),
                      ],
                    ),
                  ),
                  SizedBox(height: AppConstants.standardGap),

                  // Gallery button
                  FButton(
                    style: FButtonStyle.outline(),
                    onPress: () => _handlePickImage(ImageSource.gallery),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FIcons.image, size: 18),
                        SizedBox(width: AppConstants.extraSmallGap),
                        const Text('Choose from Gallery'),
                      ],
                    ),
                  ),
                  SizedBox(height: AppConstants.largeGap),

                  // Upload button
                  FButton(
                    onPress: (provider.pictureFile != null || provider.pictureUrl != null) && !provider.isLoading
                        ? () => _handleCompleteOnboarding(skipPicture: false)
                        : null,
                    prefix: provider.isLoading ? const FCircularProgress() : null,
                    child: Text(provider.isLoading ? 'Uploading...' : 'Upload'),
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
