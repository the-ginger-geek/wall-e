import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../movement/movement_view.dart';
import '../status/status_view.dart';
import '../animation/animation_view.dart';
import '../servo/servo_view.dart';
import '../camera/camera_view.dart';
import '../audio/audio_view.dart';
import '../settings/settings_view.dart';
import '../../common/textured_app_bar.dart';
import 'robot_control_viewmodel.dart';

class RobotControlView extends StackedView<RobotControlViewModel> {
  const RobotControlView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    RobotControlViewModel viewModel,
    Widget? child,
  ) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: TexturedAppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'WALL-',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.redAccent),
                child: const Text(
                  'E',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(viewModel.isConnected ? Icons.wifi : Icons.wifi_off),
              onPressed: viewModel.toggleConnection,
            ),
            IconButton(
              icon: const Icon(Icons.emergency, color: Colors.black),
              onPressed: viewModel.isConnected ? viewModel.emergencyStop : null,
            ),
          ],
        ),
        body: viewModel.isBusy
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Status view at the top
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: StatusView(),
                    ),
                  ),
                  // Tab bar
                  Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: TabBar(
                      isScrollable: true,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
                      indicatorColor: Theme.of(context).colorScheme.primary,
                      tabs: const [
                        Tab(icon: Icon(Icons.gamepad), text: 'Movement'),
                        Tab(icon: Icon(Icons.smart_toy), text: 'Animation'),
                        Tab(icon: Icon(Icons.tune), text: 'Servo'),
                        Tab(icon: Icon(Icons.camera), text: 'Camera'),
                        Tab(icon: Icon(Icons.volume_up), text: 'Audio'),
                        Tab(icon: Icon(Icons.settings), text: 'Settings'),
                      ],
                    ),
                  ),
                  // Tab views
                  Expanded(
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        MovementView(isConnected: viewModel.isConnected),
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: AnimationView(isConnected: viewModel.isConnected),
                        ),
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: ServoView(isConnected: viewModel.isConnected),
                        ),
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: CameraView(isConnected: viewModel.isConnected),
                        ),
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: AudioView(isConnected: viewModel.isConnected),
                        ),
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: SettingsView(isConnected: viewModel.isConnected),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  RobotControlViewModel viewModelBuilder(BuildContext context) =>
      RobotControlViewModel();

  @override
  void onViewModelReady(RobotControlViewModel viewModel) {
    viewModel.initialise();
  }
}
