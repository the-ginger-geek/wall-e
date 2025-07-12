import '../services/robot_api_service.dart';
import 'base_viewmodel.dart';

/// Animation information
class AnimationInfo {
  final int id;
  final String name;
  final String description;

  const AnimationInfo({
    required this.id,
    required this.name,
    required this.description,
  });
}

/// State for animation control
class AnimationState extends BaseViewState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final List<AnimationInfo> animations;
  final int? currentAnimation;

  const AnimationState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.animations = const [],
    this.currentAnimation,
  });

  AnimationState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    List<AnimationInfo>? animations,
    int? currentAnimation,
  }) {
    return AnimationState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      animations: animations ?? this.animations,
      currentAnimation: currentAnimation ?? this.currentAnimation,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        successMessage,
        animations,
        currentAnimation,
      ];
}

/// ViewModel for animation control
class AnimationViewModel extends BaseViewModel<AnimationState> {
  final RobotAPIService _robotAPIService;

  static const List<AnimationInfo> _defaultAnimations = [
    AnimationInfo(id: 1, name: 'Hello', description: 'Greeting animation'),
    AnimationInfo(id: 2, name: 'Look Around', description: 'Head movement animation'),
    AnimationInfo(id: 3, name: 'Happy', description: 'Happy expression'),
    AnimationInfo(id: 4, name: 'Sad', description: 'Sad expression'),
    AnimationInfo(id: 5, name: 'Surprise', description: 'Surprised expression'),
    AnimationInfo(id: 6, name: 'Dance', description: 'Dance movement'),
    AnimationInfo(id: 7, name: 'Sleep', description: 'Sleep animation'),
    AnimationInfo(id: 8, name: 'Wake Up', description: 'Wake up animation'),
  ];

  AnimationViewModel({
    required RobotAPIService robotAPIService,
  })  : _robotAPIService = robotAPIService,
        super(const AnimationState(animations: _defaultAnimations));

  /// Play animation by ID
  Future<void> playAnimation(int animationId) async {
    await executeWithLoading(
      () => _robotAPIService.playAnimation(animationId),
      (response) => state.copyWith(
        currentAnimation: animationId,
        successMessage: 'Playing animation: ${_getAnimationName(animationId)}',
        errorMessage: null,
      ),
      (error) => state.copyWith(
        errorMessage: 'Failed to play animation: $error',
        successMessage: null,
      ),
      state.copyWith(
        isLoading: true,
        errorMessage: null,
        successMessage: null,
        currentAnimation: animationId,
      ),
    );
  }

  /// Stop current animation (play neutral position)
  Future<void> stopAnimation() async {
    await executeWithLoading(
      () => _robotAPIService.playAnimation(0), // Assuming 0 is neutral/stop
      (response) => state.copyWith(
        currentAnimation: null,
        successMessage: 'Animation stopped',
        errorMessage: null,
      ),
      (error) => state.copyWith(
        errorMessage: 'Failed to stop animation: $error',
        successMessage: null,
      ),
      state.copyWith(isLoading: true, errorMessage: null, successMessage: null),
    );
  }

  /// Get animation name by ID
  String _getAnimationName(int animationId) {
    final animation = state.animations.firstWhere(
      (a) => a.id == animationId,
      orElse: () => AnimationInfo(id: animationId, name: 'Unknown', description: ''),
    );
    return animation.name;
  }

  /// Get animation by ID
  AnimationInfo? getAnimation(int animationId) {
    try {
      return state.animations.firstWhere((a) => a.id == animationId);
    } catch (e) {
      return null;
    }
  }

  /// Clear messages
  void clearMessages() {
    setState(state.copyWith(
      errorMessage: null,
      successMessage: null,
    ));
  }
}