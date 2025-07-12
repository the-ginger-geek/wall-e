import '../services/robot_api_service.dart';
import 'base_viewmodel.dart';

/// State for movement control
class MovementState extends BaseViewState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final int currentX;
  final int currentY;

  const MovementState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.currentX = 0,
    this.currentY = 0,
  });

  MovementState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    int? currentX,
    int? currentY,
  }) {
    return MovementState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      currentX: currentX ?? this.currentX,
      currentY: currentY ?? this.currentY,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        successMessage,
        currentX,
        currentY,
      ];
}

/// ViewModel for movement control
class MovementViewModel extends BaseViewModel<MovementState> {
  final RobotAPIService _robotAPIService;

  MovementViewModel({
    required RobotAPIService robotAPIService,
  })  : _robotAPIService = robotAPIService,
        super(const MovementState());

  /// Move robot with X,Y coordinates
  Future<void> move(int x, int y) async {
    await executeWithLoading(
      () => _robotAPIService.move(x, y),
      (response) => state.copyWith(
        currentX: x,
        currentY: y,
        successMessage: 'Movement command sent successfully',
        errorMessage: null,
      ),
      (error) => state.copyWith(
        errorMessage: 'Movement failed: $error',
        successMessage: null,
      ),
      state.copyWith(isLoading: true, errorMessage: null, successMessage: null),
    );
  }

  /// Stop robot movement
  Future<void> stop() async {
    await executeWithLoading(
      () => _robotAPIService.emergencyStop(),
      (response) => state.copyWith(
        currentX: 0,
        currentY: 0,
        successMessage: 'Robot stopped',
        errorMessage: null,
      ),
      (error) => state.copyWith(
        errorMessage: 'Stop failed: $error',
        successMessage: null,
      ),
      state.copyWith(isLoading: true, errorMessage: null, successMessage: null),
    );
  }

  /// Clear messages
  void clearMessages() {
    setState(state.copyWith(
      errorMessage: null,
      successMessage: null,
    ));
  }
}