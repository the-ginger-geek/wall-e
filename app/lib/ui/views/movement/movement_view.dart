import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'movement_viewmodel.dart';

class MovementView extends StackedView<MovementViewModel> {
  const MovementView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    MovementViewModel viewModel,
    Widget? child,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Movement Control',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: GestureDetector(
                onPanUpdate: (details) {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final localPosition = box.globalToLocal(details.globalPosition);
                  final centerX = box.size.width / 2;
                  final centerY = box.size.height / 2;
                  
                  final x = ((localPosition.dx - centerX) / centerX * 100).clamp(-100, 100);
                  final y = ((centerY - localPosition.dy) / centerY * 100).clamp(-100, 100);
                  
                  viewModel.move(x.round(), y.round());
                },
                onPanEnd: (_) => viewModel.stop(),
                child: Center(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: viewModel.isConnected ? () => viewModel.move(50, 50) : null,
                  child: const Text('Forward'),
                ),
                ElevatedButton(
                  onPressed: viewModel.isConnected ? () => viewModel.move(0, -50) : null,
                  child: const Text('Back'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: viewModel.isConnected ? () => viewModel.move(-50, 0) : null,
                  child: const Text('Left'),
                ),
                ElevatedButton(
                  onPressed: viewModel.isConnected ? () => viewModel.move(50, 0) : null,
                  child: const Text('Right'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.isConnected ? viewModel.stop : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('STOP', style: TextStyle(color: Colors.white)),
            ),
            if (viewModel.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: CircularProgressIndicator(),
              ),
            if (viewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  viewModel.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (viewModel.successMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  viewModel.successMessage!,
                  style: const TextStyle(color: Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  MovementViewModel viewModelBuilder(BuildContext context) => MovementViewModel();

  @override
  void onViewModelReady(MovementViewModel viewModel) {
    viewModel.initialise();
  }
}