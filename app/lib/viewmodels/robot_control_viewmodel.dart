import 'dart:async';
import '../services/robot_api_service.dart';
import 'base_viewmodel.dart';

/// State for robot control
class RobotControlState extends BaseViewState {
  final bool isConnected;
  final bool isLoading;
  final String? errorMessage;
  final String statusMessage;
  final RobotStatus? robotStatus;

  const RobotControlState({
    this.isConnected = false,
    this.isLoading = false,
    this.errorMessage,
    this.statusMessage = 'Checking connection...',
    this.robotStatus,
  });

  RobotControlState copyWith({
    bool? isConnected,
    bool? isLoading,
    String? errorMessage,
    String? statusMessage,
    RobotStatus? robotStatus,
  }) {
    return RobotControlState(
      isConnected: isConnected ?? this.isConnected,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      statusMessage: statusMessage ?? this.statusMessage,
      robotStatus: robotStatus ?? this.robotStatus,
    );
  }

  @override
  List<Object?> get props => [
        isConnected,
        isLoading,
        errorMessage,
        statusMessage,
        robotStatus,
      ];
}

/// ViewModel for robot control screen
class RobotControlViewModel extends BaseViewModel<RobotControlState> {
  final RobotAPIService _robotAPIService;
  StreamSubscription<bool>? _connectionSubscription;

  RobotControlViewModel({
    required RobotAPIService robotAPIService,
  })  : _robotAPIService = robotAPIService,
        super(const RobotControlState()) {
    _initialize();
  }

  void _initialize() {
    // Listen to connection status changes
    _connectionSubscription = _robotAPIService.connectionStatus.listen(
      (isConnected) {
        setState(state.copyWith(
          isConnected: isConnected,
          statusMessage: isConnected ? 'Connected' : 'Disconnected',
          errorMessage: null,
        ));
      },
    );

    // Check initial status
    checkStatus();
  }

  /// Check robot status
  Future<void> checkStatus() async {
    await executeWithLoading(
      () => _robotAPIService.getStatus(),
      (response) {
        final status = RobotStatus.fromJson(response);
        return state.copyWith(
          robotStatus: status,
          isConnected: status.arduinoConnected,
          statusMessage: status.arduinoConnected ? 'Connected' : 'Arduino not connected',
          errorMessage: null,
        );
      },
      (error) => state.copyWith(
        isConnected: false,
        statusMessage: 'Connection failed',
        errorMessage: error,
      ),
      state.copyWith(isLoading: true, errorMessage: null),
    );
  }

  /// Emergency stop
  Future<void> emergencyStop() async {
    await executeWithLoading(
      () => _robotAPIService.emergencyStop(),
      (response) => state.copyWith(
        errorMessage: null,
      ),
      (error) => state.copyWith(
        errorMessage: 'Emergency stop failed: $error',
      ),
      state.copyWith(isLoading: true),
    );
  }

  /// Connect to robot
  Future<void> connect() async {
    await executeWithLoading(
      () => _robotAPIService.connect(),
      (result) => state.copyWith(
        isConnected: true,
        statusMessage: 'Connected',
        errorMessage: null,
      ),
      (error) => state.copyWith(
        isConnected: false,
        statusMessage: 'Connection failed',
        errorMessage: error,
      ),
      state.copyWith(isLoading: true, statusMessage: 'Connecting...'),
    );
  }

  /// Disconnect from robot
  Future<void> disconnect() async {
    await executeWithLoading(
      () => _robotAPIService.disconnect(),
      (result) => state.copyWith(
        isConnected: false,
        statusMessage: 'Disconnected',
        errorMessage: null,
      ),
      (error) => state.copyWith(
        errorMessage: 'Disconnect failed: $error',
      ),
      state.copyWith(isLoading: true),
    );
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    _robotAPIService.dispose();
    super.dispose();
  }
}