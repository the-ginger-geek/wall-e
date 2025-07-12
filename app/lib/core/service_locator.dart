import 'package:get_it/get_it.dart';
import '../services/robot_api_service.dart';
import '../viewmodels/robot_control_viewmodel.dart';
import '../viewmodels/movement_viewmodel.dart';
import '../viewmodels/camera_viewmodel.dart';
import '../viewmodels/audio_viewmodel.dart';
import '../viewmodels/servo_viewmodel.dart';
import '../viewmodels/animation_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';

/// Service locator for dependency injection
/// Provides singleton instances of services and view models
final GetIt serviceLocator = GetIt.instance;

/// Initialize all dependencies
/// Call this before runApp() in main.dart
Future<void> setupServiceLocator() async {
  // Register services (singletons)
  serviceLocator.registerLazySingleton<RobotAPIService>(
    () => RobotAPIService(),
  );

  // Register view models (singletons)
  serviceLocator.registerLazySingleton<RobotControlViewModel>(
    () => RobotControlViewModel(
      robotAPIService: serviceLocator<RobotAPIService>(),
    ),
  );

  serviceLocator.registerLazySingleton<MovementViewModel>(
    () => MovementViewModel(
      robotAPIService: serviceLocator<RobotAPIService>(),
    ),
  );

  serviceLocator.registerLazySingleton<CameraViewModel>(
    () => CameraViewModel(
      robotAPIService: serviceLocator<RobotAPIService>(),
    ),
  );

  serviceLocator.registerLazySingleton<AudioViewModel>(
    () => AudioViewModel(
      robotAPIService: serviceLocator<RobotAPIService>(),
    ),
  );

  serviceLocator.registerLazySingleton<ServoViewModel>(
    () => ServoViewModel(
      robotAPIService: serviceLocator<RobotAPIService>(),
    ),
  );

  serviceLocator.registerLazySingleton<AnimationViewModel>(
    () => AnimationViewModel(
      robotAPIService: serviceLocator<RobotAPIService>(),
    ),
  );

  serviceLocator.registerLazySingleton<SettingsViewModel>(
    () => SettingsViewModel(
      robotAPIService: serviceLocator<RobotAPIService>(),
    ),
  );
}

/// Reset all singletons (useful for testing)
Future<void> resetServiceLocator() async {
  await serviceLocator.reset();
}