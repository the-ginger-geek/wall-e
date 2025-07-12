import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/service_locator.dart';
import '../viewmodels/robot_control_viewmodel.dart';
import '../widgets/movement_control_mvvm.dart';
import '../widgets/servo_control_mvvm.dart';
import '../widgets/animation_control_mvvm.dart';
import '../widgets/settings_control_mvvm.dart';
import '../widgets/status_display_mvvm.dart';
import '../widgets/camera_control_mvvm.dart';
import '../widgets/audio_control_mvvm.dart';

class RobotControlScreen extends StatelessWidget {
  const RobotControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => serviceLocator<RobotControlViewModel>(),
      child: const _RobotControlView(),
    );
  }
}

class _RobotControlView extends StatefulWidget {
  const _RobotControlView();

  @override
  State<_RobotControlView> createState() => _RobotControlViewState();
}

class _RobotControlViewState extends State<_RobotControlView> {
  @override
  void initState() {
    super.initState();
    // Check status when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RobotControlViewModel>().checkStatus();
    });
  }

  Future<void> _emergencyStop() async {
    await context.read<RobotControlViewModel>().emergencyStop();
    
    if (mounted) {
      final state = context.read<RobotControlViewModel>().state;
      if (state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Emergency stop failed: ${state.errorMessage}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Emergency stop activated')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WALL-E Controller'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Consumer<RobotControlViewModel>(
            builder: (context, viewModel, child) {
              return IconButton(
                icon: viewModel.state.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                onPressed: viewModel.state.isLoading
                    ? null
                    : () => viewModel.checkStatus(),
              );
            },
          ),
        ],
      ),
      body: Consumer<RobotControlViewModel>(
        builder: (context, viewModel, child) {
          final state = viewModel.state;
          
          return Column(
            children: [
              // Status Display
              StatusDisplay(
                robotStatus: state.robotStatus,
                isConnected: state.isConnected,
                statusMessage: state.statusMessage,
                errorMessage: state.errorMessage,
              ),
              
              // Emergency Stop Button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _emergencyStop,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'EMERGENCY STOP',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              
              // Tab Control
              Expanded(
                child: DefaultTabController(
                  length: 6,
                  child: Column(
                    children: [
                      const TabBar(
                        isScrollable: true,
                        tabs: [
                          Tab(text: 'Movement'),
                          Tab(text: 'Camera'),
                          Tab(text: 'Audio'),
                          Tab(text: 'Servos'),
                          Tab(text: 'Animations'),
                          Tab(text: 'Settings'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            MovementControl(isConnected: state.isConnected),
                            CameraControl(isConnected: state.isConnected),
                            AudioControl(isConnected: state.isConnected),
                            ServoControl(isConnected: state.isConnected),
                            AnimationControl(isConnected: state.isConnected),
                            SettingsControl(isConnected: state.isConnected),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}