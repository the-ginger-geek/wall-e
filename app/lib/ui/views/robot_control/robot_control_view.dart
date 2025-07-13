import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../movement/movement_view.dart';
import '../status/status_view.dart';
import 'robot_control_viewmodel.dart';

class RobotControlView extends StackedView<RobotControlViewModel> {
  const RobotControlView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    RobotControlViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WALL-E Controller'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(viewModel.isConnected ? Icons.wifi : Icons.wifi_off),
            onPressed: viewModel.toggleConnection,
          ),
          IconButton(
            icon: const Icon(Icons.emergency),
            onPressed: viewModel.isConnected ? viewModel.emergencyStop : null,
          ),
        ],
      ),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerRight,
                    child: StatusView(),
                  ),
                  const SizedBox(height: 16),
                  const MovementView(),
                  const SizedBox(height: 16),
                  // TODO: Add other controls (servo, animation, camera, audio, settings)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Other Controls',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                              'Servo, Animation, Camera, Audio, and Settings controls will be added here.'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: viewModel.isConnected
                                ? viewModel.emergencyStop
                                : null,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: const Text('EMERGENCY STOP',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
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
