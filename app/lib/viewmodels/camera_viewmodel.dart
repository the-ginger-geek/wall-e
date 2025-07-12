import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import '../services/robot_api_service.dart';
import 'base_viewmodel.dart';

/// State for camera control
class CameraState extends BaseViewState {
  final bool isActive;
  final bool isLoading;
  final bool isStreaming;
  final String? errorMessage;
  final Uint8List? currentFrame;

  const CameraState({
    this.isActive = false,
    this.isLoading = false,
    this.isStreaming = false,
    this.errorMessage,
    this.currentFrame,
  });

  CameraState copyWith({
    bool? isActive,
    bool? isLoading,
    bool? isStreaming,
    String? errorMessage,
    Uint8List? currentFrame,
  }) {
    return CameraState(
      isActive: isActive ?? this.isActive,
      isLoading: isLoading ?? this.isLoading,
      isStreaming: isStreaming ?? this.isStreaming,
      errorMessage: errorMessage,
      currentFrame: currentFrame ?? this.currentFrame,
    );
  }

  @override
  List<Object?> get props => [
        isActive,
        isLoading,
        isStreaming,
        errorMessage,
        currentFrame,
      ];
}

/// ViewModel for camera control
class CameraViewModel extends BaseViewModel<CameraState> {
  final RobotAPIService _robotAPIService;
  Timer? _frameTimer;

  CameraViewModel({
    required RobotAPIService robotAPIService,
  })  : _robotAPIService = robotAPIService,
        super(const CameraState());

  /// Start camera streaming
  Future<void> startCamera() async {
    await executeWithLoading(
      () => _robotAPIService.startCamera(),
      (response) {
        _startFrameStream();
        return state.copyWith(
          isActive: true,
          errorMessage: null,
        );
      },
      (error) => state.copyWith(
        errorMessage: 'Failed to start camera: $error',
      ),
      state.copyWith(isLoading: true, errorMessage: null),
    );
  }

  /// Stop camera streaming
  Future<void> stopCamera() async {
    _stopFrameStream();
    
    await executeWithLoading(
      () => _robotAPIService.stopCamera(),
      (response) => state.copyWith(
        isActive: false,
        isStreaming: false,
        currentFrame: null,
        errorMessage: null,
      ),
      (error) => state.copyWith(
        errorMessage: 'Failed to stop camera: $error',
      ),
      state.copyWith(isLoading: true, errorMessage: null),
    );
  }

  /// Start continuous frame streaming
  void _startFrameStream() {
    if (!state.isActive) return;
    
    setState(state.copyWith(isStreaming: true));
    _getNextFrame();
  }

  /// Stop frame streaming
  void _stopFrameStream() {
    _frameTimer?.cancel();
    _frameTimer = null;
    setState(state.copyWith(isStreaming: false));
  }

  /// Get next frame from camera
  Future<void> _getNextFrame() async {
    if (!state.isStreaming || !state.isActive) return;

    try {
      final response = await _robotAPIService.getCameraFrame();
      if (response['status'] == 'OK' && response['message'] != null) {
        final frameMessage = response['message'] as String;
        if (frameMessage.contains('Frame captured:')) {
          final frameData = frameMessage.replaceFirst('Frame captured: ', '');
          if (frameData != 'frame_data_placeholder') {
            final bytes = base64Decode(frameData);
            setState(state.copyWith(
              currentFrame: bytes,
              errorMessage: null,
            ));
          }
        }
      }
    } catch (e) {
      setState(state.copyWith(
        errorMessage: 'Error getting frame: $e',
      ));
    }

    // Continue streaming if still active
    if (state.isStreaming && state.isActive) {
      _frameTimer = Timer(const Duration(milliseconds: 100), _getNextFrame);
    }
  }

  /// Clear error message
  void clearError() {
    setState(state.copyWith(errorMessage: null));
  }

  @override
  void dispose() {
    _stopFrameStream();
    super.dispose();
  }
}