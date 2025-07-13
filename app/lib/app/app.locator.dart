import 'package:get_it/get_it.dart';
import 'package:stacked_services/stacked_services.dart';

import '../services/robot_api_service.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  // Register services
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => SnackbarService());
  locator.registerLazySingleton(() => RobotApiService());
}