import '../../../ui/common/base_viewmodel.dart';

class RobotControlState extends BaseViewState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final bool isConnected;

  const RobotControlState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.isConnected = false,
  });

  RobotControlState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool? isConnected,
  }) {
    return RobotControlState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        successMessage,
        isConnected,
      ];
}