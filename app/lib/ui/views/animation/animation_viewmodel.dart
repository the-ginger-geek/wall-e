import 'dart:async';
import '../../../app/app.locator.dart';
import '../../../services/robot_api_service.dart';
import '../../../ui/common/base_viewmodel.dart';
import '../../../ui/common/animation_framework.dart';
import '../../../ui/common/predefined_animations.dart';

/// Animation information for display
class AnimationInfo {
  final String id;
  final String name;
  final String description;
  final Duration duration;
  final bool isLoop;

  const AnimationInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    this.isLoop = false,
  });

  factory AnimationInfo.fromSequence(AnimationSequence sequence) {
    return AnimationInfo(
      id: sequence.id,
      name: sequence.name,
      description: sequence.description,
      duration: sequence.totalDuration,
      isLoop: sequence.loop,
    );
  }
}

/// State for animation control
class AnimationState extends BaseViewState {
  final bool isLoading;
  final bool isConnected;
  final String? errorMessage;
  final String? successMessage;
  final List<AnimationInfo> animations;
  final String? currentAnimation;
  final String? currentKeyframe;
  final bool isPlaying;

  const AnimationState({
    this.isLoading = false,
    this.isConnected = false,
    this.errorMessage,
    this.successMessage,
    this.animations = const [],
    this.currentAnimation,
    this.currentKeyframe,
    this.isPlaying = false,
  });

  AnimationState copyWith({
    bool? isLoading,
    bool? isConnected,
    String? errorMessage,
    String? successMessage,
    List<AnimationInfo>? animations,
    String? currentAnimation,
    String? currentKeyframe,
    bool? isPlaying,
  }) {
    return AnimationState(
      isLoading: isLoading ?? this.isLoading,
      isConnected: isConnected ?? this.isConnected,
      errorMessage: errorMessage,
      successMessage: successMessage,
      animations: animations ?? this.animations,
      currentAnimation: currentAnimation,
      currentKeyframe: currentKeyframe,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isConnected,
        errorMessage,
        successMessage,
        animations,
        currentAnimation,
        currentKeyframe,
        isPlaying,
      ];
}

/// ViewModel for animation control with servo-based animations
class AnimationViewModel extends BaseStateViewModel<AnimationState> {
  final _robotApiService = locator<RobotApiService>();
  StreamSubscription<bool>? _connectionSubscription;
  AnimationController? _animationController;

  AnimationViewModel() : super(const AnimationState()) {
    _initializeAnimations();
    _initializeConnection();
  }

  void _initializeAnimations() {
    // Initialize predefined animations
    PredefinedAnimations.initialize();
    
    // Convert to display format
    final animationInfos = PredefinedAnimations.all
        .map((sequence) => AnimationInfo.fromSequence(sequence))
        .toList();

    setState(state.copyWith(animations: animationInfos));
  }

  void _initializeConnection() {
    // Set initial connection status
    setState(state.copyWith(isConnected: _robotApiService.isConnected));
    
    // Listen to connection status changes
    _connectionSubscription = _robotApiService.connectionStatus.listen((connected) {
      setState(state.copyWith(isConnected: connected));
      
      // Stop any running animation if disconnected
      if (!connected && _animationController != null) {
        _stopCurrentAnimation();
      }
    });
  }

  /// Play animation by ID
  Future<void> playAnimation(String animationId) async {
    if (!state.isConnected) {
      setState(state.copyWith(
        errorMessage: 'Robot not connected',
        successMessage: null,
      ));
      return;
    }

    // Stop any currently running animation
    await _stopCurrentAnimation();

    // Get the animation sequence
    final sequence = PredefinedAnimations.getById(animationId);
    if (sequence == null) {
      setState(state.copyWith(
        errorMessage: 'Animation not found: $animationId',
        successMessage: null,
      ));
      return;
    }

    setState(state.copyWith(
      isLoading: true,
      currentAnimation: animationId,
      isPlaying: true,
      errorMessage: null,
      successMessage: 'Starting animation: ${sequence.name}',
    ));

    try {
      // Create and start animation controller
      _animationController = AnimationController(
        sequence: sequence,
        onServoUpdate: _updateServos,
        onComplete: _onAnimationComplete,
        onStop: _onAnimationStopped,
      );

      await _animationController!.play();

      setState(state.copyWith(
        isLoading: false,
        successMessage: 'Playing animation: ${sequence.name}',
      ));

    } catch (e) {
      setState(state.copyWith(
        isLoading: false,
        isPlaying: false,
        currentAnimation: null,
        errorMessage: 'Failed to start animation: $e',
        successMessage: null,
      ));
    }
  }

  /// Stop current animation
  Future<void> stopAnimation() async {
    await _stopCurrentAnimation();
    setState(state.copyWith(
      successMessage: 'Animation stopped',
      errorMessage: null,
    ));
  }

  Future<void> _stopCurrentAnimation() async {
    if (_animationController != null) {
      await _animationController!.stop();
      _animationController?.dispose();
      _animationController = null;
    }

    setState(state.copyWith(
      isPlaying: false,
      currentAnimation: null,
      currentKeyframe: null,
    ));
  }

  /// Update servos with new positions
  Future<void> _updateServos(Map<String, int> servoPositions) async {
    if (!state.isConnected || servoPositions.isEmpty) return;

    try {
      // Update current keyframe info
      setState(state.copyWith(
        currentKeyframe: _animationController?.currentKeyframeLabel,
      ));

      // Send servo commands to robot
      await _robotApiService.controlMultipleServos(servoPositions);
      
    } catch (e) {
      // Don't stop animation for servo errors, just log them
      setState(state.copyWith(
        errorMessage: 'Servo update failed: $e',
      ));
    }
  }

  void _onAnimationComplete() {
    setState(state.copyWith(
      isPlaying: false,
      currentAnimation: null,
      currentKeyframe: null,
      successMessage: 'Animation completed',
    ));
    
    _animationController?.dispose();
    _animationController = null;
  }

  void _onAnimationStopped() {
    setState(state.copyWith(
      isPlaying: false,
      currentAnimation: null,
      currentKeyframe: null,
    ));
    
    _animationController?.dispose();
    _animationController = null;
  }

  /// Get animation by ID
  AnimationInfo? getAnimation(String animationId) {
    try {
      return state.animations.firstWhere((a) => a.id == animationId);
    } catch (e) {
      return null;
    }
  }

  /// Get animation name by ID
  String getAnimationName(String animationId) {
    final animation = getAnimation(animationId);
    return animation?.name ?? 'Unknown';
  }

  /// Clear messages
  void clearMessages() {
    setState(state.copyWith(
      errorMessage: null,
      successMessage: null,
    ));
  }

  /// Pause current animation
  void pauseAnimation() {
    if (_animationController != null && state.isPlaying) {
      _animationController!.pause();
      setState(state.copyWith(
        isPlaying: false,
        successMessage: 'Animation paused',
      ));
    }
  }

  /// Resume paused animation
  Future<void> resumeAnimation() async {
    if (_animationController != null && !state.isPlaying) {
      await _animationController!.resume();
      setState(state.copyWith(
        isPlaying: true,
        successMessage: 'Animation resumed',
      ));
    }
  }

  /// Check if a specific animation is currently playing
  bool isAnimationPlaying(String animationId) {
    return state.currentAnimation == animationId && state.isPlaying;
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    _stopCurrentAnimation();
    super.dispose();
  }
}