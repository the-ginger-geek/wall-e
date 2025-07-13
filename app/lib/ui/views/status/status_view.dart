import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'status_viewmodel.dart';

class StatusView extends StackedView<StatusViewModel> {
  const StatusView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    StatusViewModel viewModel,
    Widget? child,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Robot Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  viewModel.isConnected ? Icons.check_circle : Icons.error,
                  color: viewModel.isConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  viewModel.isConnected ? 'Connected' : 'Disconnected',
                  style: TextStyle(
                    color: viewModel.isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.battery_full),
                const SizedBox(width: 8),
                Text('Battery: ${viewModel.batteryLevel}'),
              ],
            ),
            if (viewModel.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  viewModel.modelError.toString(),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  StatusViewModel viewModelBuilder(BuildContext context) => StatusViewModel();

  @override
  void onViewModelReady(StatusViewModel viewModel) {
    viewModel.initialise();
  }
}