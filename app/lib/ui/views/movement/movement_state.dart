import '../../../ui/common/base_viewmodel.dart';

class MovementState extends BaseViewState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final int currentX;
  final int currentY;
  final bool isConnected;

  const MovementState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.currentX = 0,
    this.currentY = 0,
    this.isConnected = false,
  });

  MovementState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    int? currentX,
    int? currentY,
    bool? isConnected,
  }) {
    return MovementState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      currentX: currentX ?? this.currentX,
      currentY: currentY ?? this.currentY,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        successMessage,
        currentX,
        currentY,
        isConnected,
      ];
}