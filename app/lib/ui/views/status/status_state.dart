import '../../../ui/common/base_viewmodel.dart';
import '../../../services/robot_api_service.dart';

class StatusState extends BaseViewState {
  final bool isLoading;
  final String? errorMessage;
  final bool isConnected;
  final String batteryLevel;
  final RobotStatus? robotStatus;
  final String statusMessage;

  const StatusState({
    this.isLoading = false,
    this.errorMessage,
    this.isConnected = false,
    this.batteryLevel = 'Unknown',
    this.robotStatus,
    this.statusMessage = 'Disconnected',
  });

  StatusState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isConnected,
    String? batteryLevel,
    RobotStatus? robotStatus,
    String? statusMessage,
  }) {
    return StatusState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isConnected: isConnected ?? this.isConnected,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      robotStatus: robotStatus ?? this.robotStatus,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        isConnected,
        batteryLevel,
        robotStatus,
        statusMessage,
      ];
}