import 'dart:async';
import '../../../app/app.locator.dart';
import '../../../services/robot_api_service.dart';
import '../../../ui/common/base_viewmodel.dart';
import 'status_state.dart';

class StatusViewModel extends BaseStateViewModel<StatusState> {
  final _robotApiService = locator<RobotApiService>();
  StreamSubscription<bool>? _connectionSubscription;

  StatusViewModel() : super(const StatusState());

  bool get isConnected => state.isConnected;
  String get batteryLevel => state.batteryLevel;
  bool get isLoading => state.isLoading;
  String? get errorMessage => state.errorMessage;
  RobotStatus? get robotStatus => state.robotStatus;
  String get statusMessage => state.statusMessage;

  void initialise() {
    _initializeConnection();
    _loadStatus();
  }

  void _initializeConnection() {
    // Set initial connection status
    setState(state.copyWith(isConnected: _robotApiService.isConnected));
    
    // Listen to connection status changes
    _connectionSubscription = _robotApiService.connectionStatus.listen((connected) {
      setState(state.copyWith(
        isConnected: connected,
        statusMessage: connected ? 'Connected' : 'Disconnected',
      ));
    });
  }

  Future<void> _loadStatus() async {
    await executeWithLoading(
      () => _robotApiService.getStatus(),
      (response) {
        if (response['status'] == 'OK') {
          final robotStatus = response['robotStatus'] as RobotStatus?;
          return state.copyWith(
            robotStatus: robotStatus,
            statusMessage: 'Status updated successfully',
            errorMessage: null,
          );
        }
        return state.copyWith(
          statusMessage: 'Failed to get status',
          errorMessage: 'Invalid response from server',
        );
      },
      (error) => state.copyWith(
        errorMessage: 'Failed to load status: $error',
        statusMessage: 'Error loading status',
      ),
      state.copyWith(isLoading: true, errorMessage: null),
    );
  }

  Future<void> refreshStatus() async {
    await _loadStatus();
  }

  void clearError() {
    setState(state.copyWith(errorMessage: null));
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    super.dispose();
  }
}