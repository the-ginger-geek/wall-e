import 'dart:async';
import '../../../app/app.locator.dart';
import '../../../services/robot_api_service.dart';
import "../../../ui/common/base_viewmodel.dart";

/// Servo information
class ServoInfo {
  final String name;
  final String displayName;
  final int value;
  final int minValue;
  final int maxValue;

  const ServoInfo({
    required this.name,
    required this.displayName,
    required this.value,
    this.minValue = 0,
    this.maxValue = 100,
  });

  ServoInfo copyWith({
    String? name,
    String? displayName,
    int? value,
    int? minValue,
    int? maxValue,
  }) {
    return ServoInfo(
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      value: value ?? this.value,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
    );
  }
}

/// State for servo control
class ServoState extends BaseViewState {
  final bool isLoading;
  final bool isConnected;
  final String? errorMessage;
  final String? successMessage;
  final List<ServoInfo> servos;

  const ServoState({
    this.isLoading = false,
    this.isConnected = false,
    this.errorMessage,
    this.successMessage,
    this.servos = const [],
  });

  ServoState copyWith({
    bool? isLoading,
    bool? isConnected,
    String? errorMessage,
    String? successMessage,
    List<ServoInfo>? servos,
  }) {
    return ServoState(
      isLoading: isLoading ?? this.isLoading,
      isConnected: isConnected ?? this.isConnected,
      errorMessage: errorMessage,
      successMessage: successMessage,
      servos: servos ?? this.servos,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isConnected,
        errorMessage,
        successMessage,
        servos,
      ];
}

/// ViewModel for servo control
class ServoViewModel extends BaseStateViewModel<ServoState> {
  final _robotApiService = locator<RobotApiService>();
  StreamSubscription<bool>? _connectionSubscription;

  static const List<ServoInfo> _defaultServos = [
    ServoInfo(name: 'head_rotation', displayName: 'Head Rotation', value: 50),
    ServoInfo(name: 'neck_top', displayName: 'Neck Top', value: 50),
    ServoInfo(name: 'neck_bottom', displayName: 'Neck Bottom', value: 50),
    ServoInfo(name: 'arm_left', displayName: 'Left Arm', value: 50),
    ServoInfo(name: 'arm_right', displayName: 'Right Arm', value: 50),
    ServoInfo(name: 'eye_left', displayName: 'Left Eye', value: 50),
    ServoInfo(name: 'eye_right', displayName: 'Right Eye', value: 50),
  ];

  ServoViewModel() : super(const ServoState(servos: _defaultServos)) {
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

  /// Control individual servo
  Future<void> controlServo(String servoName, int value) async {
    if (!state.isConnected) return;
    
    // Update servo value in state immediately for responsive UI
    final updatedServos = state.servos.map((servo) {
      if (servo.name == servoName) {
        return servo.copyWith(value: value);
      }
      return servo;
    }).toList();

    setState(state.copyWith(
      servos: updatedServos,
      errorMessage: null,
      successMessage: null,
    ));

    await executeWithLoading(
      () => _robotApiService.controlServo(servoName, value),
      (response) => state.copyWith(
        successMessage: 'Servo ${_getDisplayName(servoName)} set to $value',
        errorMessage: null,
        isLoading: false,
      ),
      (error) => state.copyWith(
        errorMessage: 'Failed to control servo: $error',
        successMessage: null,
        isLoading: false,
      ),
      state.copyWith(isLoading: true, errorMessage: null, successMessage: null),
    );
  }

  /// Control multiple servos at once
  Future<void> controlMultipleServos(Map<String, int> servoValues) async {
    if (!state.isConnected) return;
    
    // Update all servo values in state immediately
    final updatedServos = state.servos.map((servo) {
      if (servoValues.containsKey(servo.name)) {
        return servo.copyWith(value: servoValues[servo.name]!);
      }
      return servo;
    }).toList();

    setState(state.copyWith(
      servos: updatedServos,
      errorMessage: null,
      successMessage: null,
    ));

    await executeWithLoading(
      () => _robotApiService.controlMultipleServos(servoValues),
      (responses) => state.copyWith(
        successMessage: 'Multiple servos updated successfully',
        errorMessage: null,
        isLoading: false,
      ),
      (error) => state.copyWith(
        errorMessage: 'Failed to control servos: $error',
        successMessage: null,
        isLoading: false,
      ),
      state.copyWith(isLoading: true, errorMessage: null, successMessage: null),
    );
  }

  /// Reset all servos to center position
  Future<void> resetAllServos() async {
    final resetValues = <String, int>{};
    for (final servo in state.servos) {
      resetValues[servo.name] = 50;
    }
    await controlMultipleServos(resetValues);
  }

  /// Get display name for servo
  String _getDisplayName(String servoName) {
    final servo = state.servos.firstWhere(
      (s) => s.name == servoName,
      orElse: () => const ServoInfo(name: '', displayName: 'Unknown', value: 0),
    );
    return servo.displayName;
  }

  /// Clear messages
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