import 'dart:async';
import '../../../app/app.locator.dart';
import '../../../services/robot_api_service.dart';
import '../../../ui/common/base_viewmodel.dart';
import 'robot_control_state.dart';

class RobotControlViewModel extends BaseStateViewModel<RobotControlState> {
  final _robotApiService = locator<RobotApiService>();
  StreamSubscription<bool>? _connectionSubscription;

  RobotControlViewModel() : super(const RobotControlState());

  bool get isConnected => state.isConnected;
  bool get isLoading => state.isLoading;
  String? get errorMessage => state.errorMessage;
  String? get successMessage => state.successMessage;

  Stream<bool> get connectionStatus => _robotApiService.connectionStatus;

  void initialise() {
    _initializeConnection();
  }

  void _initializeConnection() {
    // Set initial connection status
    setState(state.copyWith(isConnected: _robotApiService.isConnected));
    
    // Listen to connection status changes
    _connectionSubscription = _robotApiService.connectionStatus.listen((connected) {
      setState(state.copyWith(isConnected: connected));
    });
  }

  Future<void> toggleConnection() async {
    await executeWithLoading(
      () async {
        if (isConnected) {
          await _robotApiService.disconnect();
        } else {
          await _robotApiService.connect();
        }
      },
      (response) => state.copyWith(
        successMessage: isConnected ? 'Disconnected successfully' : 'Connected successfully',
        errorMessage: null,
      ),
      (error) => state.copyWith(
        errorMessage: 'Connection error: $error',
        successMessage: null,
      ),
      state.copyWith(isLoading: true, errorMessage: null, successMessage: null),
    );
  }

  Future<void> emergencyStop() async {
    if (!isConnected) return;
    
    await executeWithLoading(
      () => _robotApiService.emergencyStop(),
      (response) => state.copyWith(
        successMessage: 'Emergency stop activated',
        errorMessage: null,
      ),
      (error) => state.copyWith(
        errorMessage: 'Emergency stop error: $error',
        successMessage: null,
      ),
      state.copyWith(isLoading: true, errorMessage: null, successMessage: null),
    );
  }

  void clearMessages() {
    setState(state.copyWith(
      errorMessage: null,
      successMessage: null,
    ));
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    super.dispose();
  }
}