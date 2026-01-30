/// Onboarding state management provider
///
/// Manages the multi-step onboarding flow including:
/// - Step progression (1: Name, 2: Picture)
/// - Name input state
/// - Picture file/URL state
/// - Progress persistence via SharedPreferences
library;

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notagain/core/logging/app_logger.dart';

class OnboardingProvider extends ChangeNotifier {
  // State
  int _currentStep = 1;
  String? _name;
  File? _pictureFile;
  String? _pictureUrl;
  bool _isLoading = false;

  // SharedPreferences keys
  static const String _keyCurrentStep = 'onboarding_current_step';
  static const String _keyNameDraft = 'onboarding_name_draft';
  static const String _keyPicturePath = 'onboarding_picture_path';

  // Getters
  int get currentStep => _currentStep;
  String? get name => _name;
  File? get pictureFile => _pictureFile;
  String? get pictureUrl => _pictureUrl;
  bool get isLoading => _isLoading;
  bool get canProceedFromStep1 => _name != null && _name!.trim().isNotEmpty;

  /// Initialize onboarding provider and load saved progress
  Future<void> init() async {
    try {
      AppLogger.info('Initializing OnboardingProvider', tag: 'OnboardingProvider');
      final prefs = await SharedPreferences.getInstance();

      // Load saved step
      _currentStep = prefs.getInt(_keyCurrentStep) ?? 1;

      // Load saved name
      _name = prefs.getString(_keyNameDraft);

      // Load saved picture path
      final savedPath = prefs.getString(_keyPicturePath);
      if (savedPath != null && File(savedPath).existsSync()) {
        _pictureFile = File(savedPath);
      }

      AppLogger.info(
        'Loaded onboarding progress: step=$_currentStep, name=$_name',
        tag: 'OnboardingProvider',
      );
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to load onboarding progress: $e', tag: 'OnboardingProvider');
    }
  }

  /// Set user's name for Step 1
  Future<void> setName(String name) async {
    try {
      _name = name.trim();
      notifyListeners();

      // Persist to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyNameDraft, _name!);

      AppLogger.info('Name set: $_name', tag: 'OnboardingProvider');
    } catch (e) {
      AppLogger.error('Failed to save name: $e', tag: 'OnboardingProvider');
    }
  }

  /// Set profile picture for Step 2
  Future<void> setPicture(File file) async {
    try {
      _pictureFile = file;
      notifyListeners();

      // Persist file path to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyPicturePath, file.path);

      AppLogger.info('Picture selected: ${file.path}', tag: 'OnboardingProvider');
    } catch (e) {
      AppLogger.error('Failed to save picture: $e', tag: 'OnboardingProvider');
    }
  }

  /// Set profile picture URL (from SSO or after upload)
  void setPictureUrl(String url) {
    _pictureUrl = url;
    notifyListeners();
    AppLogger.info('Picture URL set: $url', tag: 'OnboardingProvider');
  }

  /// Move to next step
  Future<void> nextStep() async {
    if (_currentStep < 2) {
      _currentStep++;
      notifyListeners();

      // Persist step progress
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyCurrentStep, _currentStep);

      AppLogger.info('Advanced to step $_currentStep', tag: 'OnboardingProvider');
    }
  }

  /// Move to previous step
  Future<void> previousStep() async {
    if (_currentStep > 1) {
      _currentStep--;
      notifyListeners();

      // Persist step progress
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyCurrentStep, _currentStep);

      AppLogger.info('Returned to step $_currentStep', tag: 'OnboardingProvider');
    }
  }

  /// Mark onboarding as complete and clear progress
  Future<void> completeOnboarding() async {
    try {
      AppLogger.info('Completing onboarding', tag: 'OnboardingProvider');
      await resetProgress();
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to complete onboarding: $e', tag: 'OnboardingProvider');
    }
  }

  /// Abandon onboarding (pause progress, do NOT logout)
  /// User will resume from current step on next app launch
  void abandonOnboarding() {
    AppLogger.info(
      'Onboarding abandoned at step $_currentStep',
      tag: 'OnboardingProvider',
    );
    // Progress is already persisted to SharedPreferences, no action needed
  }

  /// Reset all onboarding progress
  Future<void> resetProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyCurrentStep);
      await prefs.remove(_keyNameDraft);
      await prefs.remove(_keyPicturePath);

      _currentStep = 1;
      _name = null;
      _pictureFile = null;
      _pictureUrl = null;

      AppLogger.info('Onboarding progress reset', tag: 'OnboardingProvider');
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to reset progress: $e', tag: 'OnboardingProvider');
    }
  }

  /// Pre-populate name from SSO (used when SSO provides full_name)
  Future<void> prefillFromSSO({String? name, String? avatarUrl}) async {
    if (name != null) {
      await setName(name);
      AppLogger.info('Pre-filled name from SSO: $name', tag: 'OnboardingProvider');
    }
    if (avatarUrl != null) {
      setPictureUrl(avatarUrl);
      AppLogger.info('Pre-filled avatar from SSO: $avatarUrl', tag: 'OnboardingProvider');
    }
  }

  /// Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
