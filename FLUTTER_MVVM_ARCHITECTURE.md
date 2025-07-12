# Flutter MVVM Architecture Implementation

## Overview

The Flutter client has been refactored to follow MVVM (Model-View-ViewModel) architecture with dependency injection using the service locator pattern. This creates a clean, maintainable, and testable codebase that mirrors the architectural patterns used in the Dart TCP server.

## Architecture Components

### 1. Service Locator (`lib/core/service_locator.dart`)
- **Purpose**: Dependency injection container using GetIt
- **Responsibilities**:
  - Register services and ViewModels as singletons
  - Provide dependency resolution
  - Support for testing with mock implementations

### 2. Base Classes

#### BaseViewModel (`lib/viewmodels/base_viewmodel.dart`)
- **Purpose**: Abstract base class for all ViewModels
- **Features**:
  - Generic state management with type safety
  - `executeWithLoading()` helper for async operations
  - Automatic state change notifications
  - Built-in loading/error handling patterns

#### BaseViewState (`lib/viewmodels/base_viewmodel.dart`)
- **Purpose**: Abstract base class for all view states
- **Features**:
  - Extends Equatable for value comparison
  - Immutable state objects
  - Type-safe state transitions

### 3. Services

#### RobotAPIService (`lib/services/robot_api_service.dart`)
- **Purpose**: Encapsulates all robot communication logic
- **Features**:
  - JSON-based TCP communication
  - Connection status streaming
  - Error handling and retry logic
  - Clean API methods for all robot functions

### 4. ViewModels

#### RobotControlViewModel
- **State**: Connection status, robot status, loading states
- **Actions**: Connect, disconnect, emergency stop, status checking
- **Features**: Automatic connection monitoring

#### MovementViewModel
- **State**: Current position (x, y), loading, messages
- **Actions**: Move robot, stop, clear messages
- **Features**: Real-time position tracking

#### CameraViewModel
- **State**: Camera active state, streaming status, current frame
- **Actions**: Start/stop camera, frame streaming
- **Features**: Automatic frame refresh, error handling

#### AudioViewModel
- **State**: Available sounds, selected sound, TTS text
- **Actions**: Play sounds, text-to-speech, load sound list
- **Features**: Sound management, quick phrases

#### ServoViewModel
- **State**: Servo positions and configurations
- **Actions**: Control individual/multiple servos, reset positions
- **Features**: Real-time UI updates, batch operations

#### AnimationViewModel
- **State**: Available animations, current animation
- **Actions**: Play/stop animations
- **Features**: Animation status tracking

#### SettingsViewModel
- **State**: Robot settings and their values
- **Actions**: Update settings, reset to defaults
- **Features**: Type-safe setting management

### 5. Views (MVVM Widgets)

All widgets have been refactored to use the MVVM pattern:
- `RobotControlScreen` → Main screen with tab navigation
- `MovementControl` → Virtual joystick and directional controls
- `CameraControl` → Camera streaming with real-time preview
- `AudioControl` → Sound playback and text-to-speech
- `ServoControl` → Servo sliders with real-time feedback
- `AnimationControl` → Animation grid with status display
- `SettingsControl` → Settings management interface

## Key Features

### 1. State Management
- **Provider**: Used for state management and dependency injection
- **Immutable States**: All states are immutable value objects
- **Type Safety**: Full type safety throughout the architecture
- **Reactive Updates**: Automatic UI updates when state changes

### 2. Dependency Injection
- **Service Locator**: GetIt for dependency resolution
- **Singleton Pattern**: Services and ViewModels as singletons
- **Easy Testing**: Support for mock implementations
- **Clean Dependencies**: Clear separation of concerns

### 3. Error Handling
- **Centralized**: Error handling in base ViewModel
- **User-Friendly**: Proper error messages in UI
- **Loading States**: Visual feedback for async operations
- **Recovery**: Graceful error recovery

### 4. Code Organization
```
lib/
├── core/
│   └── service_locator.dart       # Dependency injection setup
├── services/
│   └── robot_api_service.dart     # API communication service
├── viewmodels/
│   ├── base_viewmodel.dart        # Base classes
│   ├── robot_control_viewmodel.dart
│   ├── movement_viewmodel.dart
│   ├── camera_viewmodel.dart
│   ├── audio_viewmodel.dart
│   ├── servo_viewmodel.dart
│   ├── animation_viewmodel.dart
│   └── settings_viewmodel.dart
├── screens/
│   └── robot_control_screen_mvvm.dart  # Main screen
└── widgets/
    ├── movement_control_mvvm.dart
    ├── camera_control_mvvm.dart
    ├── audio_control_mvvm.dart
    ├── servo_control_mvvm.dart
    ├── animation_control_mvvm.dart
    ├── settings_control_mvvm.dart
    └── status_display_mvvm.dart
```

## Dependencies Added

```yaml
dependencies:
  # State Management & MVVM
  provider: ^6.1.2
  
  # Service Locator
  get_it: ^7.6.4
  
  # Utilities
  equatable: ^2.0.5
```

## Usage Examples

### 1. Service Locator Setup
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const WallEControllerApp());
}
```

### 2. ViewModel Usage
```dart
class MovementControl extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => serviceLocator<MovementViewModel>(),
      child: Consumer<MovementViewModel>(
        builder: (context, viewModel, child) {
          final state = viewModel.state;
          // Build UI based on state
        },
      ),
    );
  }
}
```

### 3. State Management
```dart
// In ViewModel
setState(state.copyWith(
  isLoading: false,
  successMessage: 'Operation completed',
  errorMessage: null,
));

// Automatic UI updates via Provider
```

## Benefits

### 1. Maintainability
- **Separation of Concerns**: Clear boundaries between layers
- **Single Responsibility**: Each class has one purpose
- **Easy Refactoring**: Changes isolated to specific layers

### 2. Testability
- **Unit Testing**: ViewModels can be tested independently
- **Mock Services**: Easy to mock dependencies
- **State Testing**: Immutable states are easy to verify

### 3. Scalability
- **Modular Design**: Easy to add new features
- **Reusable Components**: ViewModels and services can be reused
- **Performance**: Efficient state updates and memory usage

### 4. Developer Experience
- **Type Safety**: Compile-time error checking
- **IntelliSense**: Better IDE support
- **Debugging**: Clear data flow and state management

## Comparison with Previous Architecture

| Aspect | Old (StatefulWidget) | New (MVVM) |
|--------|---------------------|------------|
| State Management | setState() | Provider + ViewModels |
| Business Logic | Mixed with UI | Separated in ViewModels |
| Testing | Difficult | Easy unit testing |
| Code Reuse | Limited | High reusability |
| Dependency Management | Manual | Service Locator |
| Error Handling | Ad-hoc | Centralized |
| Data Flow | Unclear | Unidirectional |

## Future Enhancements

1. **Repository Pattern**: Add data layer abstraction
2. **Use Cases**: Implement use case classes for complex operations
3. **State Persistence**: Add state persistence for app restarts
4. **Offline Support**: Implement offline mode with caching
5. **Real-time Updates**: Add WebSocket support for real-time data
6. **Analytics**: Integrate analytics for user behavior tracking

## Migration Notes

- **Backward Compatibility**: Old widgets still exist but deprecated
- **Gradual Migration**: Can migrate one feature at a time
- **Performance**: Improved performance due to efficient state updates
- **Bundle Size**: Minimal impact on app size

The MVVM architecture provides a solid foundation for the Wall-E controller app, making it more maintainable, testable, and aligned with modern Flutter development practices.