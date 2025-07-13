import 'dart:async';
import '../../../app/app.locator.dart';
import '../../../services/robot_api_service.dart';
import '../../../ui/common/base_viewmodel.dart';
import 'movement_state.dart';

class MovementViewModel extends BaseStateViewModel<MovementState> {
  final _robotApiService = locator<RobotApiService>();
  StreamSubscription<bool>? _connectionSubscription;

  MovementViewModel() : super(const MovementState());

  bool get isConnected => state.isConnected;
  bool get isLoading => state.isLoading;
  String? get errorMessage => state.errorMessage;
  String? get successMessage => state.successMessage;
  int get currentX => state.currentX;
  int get currentY => state.currentY;

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

  Future<void> move(int x, int y) async {
    if (!isConnected) return;
    
    await executeWithLoading(
      () => _robotApiService.move(x, y),
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

  Future<void> stop() async {
    await move(0, 0);
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