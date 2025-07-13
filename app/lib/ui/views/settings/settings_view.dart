import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'settings_viewmodel.dart';

class SettingsView extends StackedView<SettingsViewModel> {
  final bool isConnected;
  
  const SettingsView({required this.isConnected, super.key});

  @override
  Widget builder(
    BuildContext context,
    SettingsViewModel viewModel,
    Widget? child,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Robot Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: isConnected && !viewModel.state.isLoading ? viewModel.resetToDefaults : null,
                  icon: const Icon(Icons.restore),
                  label: const Text('Reset to Defaults'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Settings controls
            ...viewModel.state.settings.map((setting) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: _buildSettingControl(setting, viewModel, isConnected),
              );
            }),
            
            const SizedBox(height: 16),
            
            // Loading indicator
            if (viewModel.state.isLoading) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
            
            // Success message
            if (viewModel.state.successMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        viewModel.state.successMessage!,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                    TextButton(
                      onPressed: viewModel.clearMessages,
                      child: const Text('Dismiss'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Error message
            if (viewModel.state.errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        viewModel.state.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton(
                      onPressed: viewModel.clearMessages,
                      child: const Text('Dismiss'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Connection status
            if (!isConnected) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Robot not connected. Settings changes are disabled.',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingControl(dynamic setting, SettingsViewModel viewModel, bool isConnected) {
    if (setting.value is bool) {
      return _buildBooleanSetting(setting, viewModel, isConnected);
    } else if (setting.value is int || setting.value is double) {
      return _buildNumericSetting(setting, viewModel, isConnected);
    } else {
      return _buildTextSetting(setting, viewModel, isConnected);
    }
  }

  Widget _buildBooleanSetting(dynamic setting, SettingsViewModel viewModel, bool isConnected) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                setting.displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                setting.description,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        Switch(
          value: setting.value as bool,
          onChanged: isConnected && !viewModel.state.isLoading
              ? (value) => viewModel.updateSetting(setting.name, value)
              : null,
          activeColor: isConnected ? Colors.blue : Colors.grey,
        ),
      ],
    );
  }

  Widget _buildNumericSetting(dynamic setting, SettingsViewModel viewModel, bool isConnected) {
    final value = setting.value is int ? (setting.value as int).toDouble() : setting.value as double;
    final minValue = setting.minValue?.toDouble() ?? 0.0;
    final maxValue = setting.maxValue?.toDouble() ?? 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              setting.displayName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${setting.value}',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          setting.description,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: minValue,
          max: maxValue,
          divisions: (maxValue - minValue).round(),
          onChanged: isConnected && !viewModel.state.isLoading
              ? (newValue) => viewModel.updateSetting(setting.name, newValue.round())
              : null,
          activeColor: isConnected ? Colors.blue : Colors.grey,
          inactiveColor: Colors.grey.withValues(alpha: 0.3),
        ),
      ],
    );
  }

  Widget _buildTextSetting(dynamic setting, SettingsViewModel viewModel, bool isConnected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          setting.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          setting.description,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: setting.value.toString(),
          enabled: isConnected && !viewModel.state.isLoading,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          onFieldSubmitted: (value) => viewModel.updateSetting(setting.name, value),
        ),
      ],
    );
  }

  @override
  SettingsViewModel viewModelBuilder(BuildContext context) => SettingsViewModel();
}