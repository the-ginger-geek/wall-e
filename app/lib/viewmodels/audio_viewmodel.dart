import '../services/robot_api_service.dart';
import 'base_viewmodel.dart';

/// State for audio control
class AudioState extends BaseViewState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final List<String> availableSounds;
  final String? selectedSound;
  final String ttsText;

  const AudioState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.availableSounds = const [],
    this.selectedSound,
    this.ttsText = '',
  });

  AudioState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    List<String>? availableSounds,
    String? selectedSound,
    String? ttsText,
  }) {
    return AudioState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      availableSounds: availableSounds ?? this.availableSounds,
      selectedSound: selectedSound ?? this.selectedSound,
      ttsText: ttsText ?? this.ttsText,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        successMessage,
        availableSounds,
        selectedSound,
        ttsText,
      ];
}

/// ViewModel for audio control
class AudioViewModel extends BaseViewModel<AudioState> {
  final RobotAPIService _robotAPIService;

  AudioViewModel({
    required RobotAPIService robotAPIService,
  })  : _robotAPIService = robotAPIService,
        super(const AudioState());

  /// Load available sounds from server
  Future<void> loadSounds() async {
    await executeWithLoading(
      () => _robotAPIService.listSounds(),
      (response) {
        final soundsStr = response['message'] as String? ?? '';
        final sounds = soundsStr.replaceFirst('Available sounds: ', '')
            .split(', ')
            .where((s) => s.isNotEmpty)
            .toList();
        
        return state.copyWith(
          availableSounds: sounds,
          selectedSound: sounds.isNotEmpty ? sounds.first : null,
          errorMessage: null,
        );
      },
      (error) => state.copyWith(
        errorMessage: 'Failed to load sounds: $error',
      ),
      state.copyWith(isLoading: true, errorMessage: null),
    );
  }

  /// Play selected sound
  Future<void> playSound(String soundName) async {
    await executeWithLoading(
      () => _robotAPIService.playSound(soundName),
      (response) => state.copyWith(
        successMessage: response['message'] ?? 'Playing sound: $soundName',
        errorMessage: null,
      ),
      (error) => state.copyWith(
        errorMessage: 'Failed to play sound: $error',
        successMessage: null,
      ),
      state.copyWith(isLoading: true, errorMessage: null, successMessage: null),
    );
  }

  /// Speak text using TTS
  Future<void> speakText(String text) async {
    if (text.trim().isEmpty) {
      setState(state.copyWith(
        errorMessage: 'Please enter text to speak',
      ));
      return;
    }

    await executeWithLoading(
      () => _robotAPIService.speakText(text),
      (response) => state.copyWith(
        successMessage: response['message'] ?? 'Speaking: $text',
        errorMessage: null,
      ),
      (error) => state.copyWith(
        errorMessage: 'Failed to speak text: $error',
        successMessage: null,
      ),
      state.copyWith(isLoading: true, errorMessage: null, successMessage: null),
    );
  }

  /// Set selected sound
  void setSelectedSound(String? sound) {
    setState(state.copyWith(selectedSound: sound));
  }

  /// Set TTS text
  void setTtsText(String text) {
    setState(state.copyWith(ttsText: text));
  }

  /// Clear TTS text
  void clearTtsText() {
    setState(state.copyWith(ttsText: ''));
  }

  /// Clear messages
  void clearMessages() {
    setState(state.copyWith(
      errorMessage: null,
      successMessage: null,
    ));
  }
}