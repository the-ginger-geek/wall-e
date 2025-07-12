import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/service_locator.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsControl extends StatelessWidget {
  final bool isConnected;

  const SettingsControl({super.key, required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => serviceLocator<SettingsViewModel>(),
      child: _SettingsControlView(isConnected: isConnected),
    );
  }
}

class _SettingsControlView extends StatelessWidget {
  final bool isConnected;

  const _SettingsControlView({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, viewModel, child) {
        final state = viewModel.state;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Settings Controls
              Card(
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
                          ElevatedButton(
                            onPressed: isConnected && !state.isLoading
                                ? () => viewModel.resetToDefaults()
                                : null,
                            child: const Text('Reset to Defaults'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Settings list
                      ...state.settings.map((setting) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _SettingWidget(
                          setting: setting,
                          isConnected: isConnected,
                          isLoading: state.isLoading,
                          onChanged: (value) => viewModel.updateSetting(setting.name, value),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              
              // Notice about Dart server
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Notice',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Settings functionality is not yet implemented in the Dart TCP server. '
                        'Changes will be saved locally but may not affect robot behavior.',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Status messages
              if (state.successMessage != null) ...[
                const SizedBox(height: 16),
                _StatusMessage(
                  message: state.successMessage!,
                  isError: false,
                  onDismiss: () => viewModel.clearMessages(),
                ),
              ],
              
              if (state.errorMessage != null) ...[
                const SizedBox(height: 16),
                _StatusMessage(
                  message: state.errorMessage!,
                  isError: true,
                  onDismiss: () => viewModel.clearMessages(),
                ),
              ],
              
              if (!isConnected) ...[
                const SizedBox(height: 16),
                const _DisconnectedWarning(),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SettingWidget extends StatelessWidget {
  final dynamic setting;
  final bool isConnected;
  final bool isLoading;
  final Function(dynamic) onChanged;

  const _SettingWidget({
    required this.setting,
    required this.isConnected,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              setting.displayName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              setting.description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            
            // Different UI based on setting type
            if (setting.value is bool) ...[
              SwitchListTile(
                title: Text(setting.value ? 'Enabled' : 'Disabled'),
                value: setting.value,
                onChanged: isConnected && !isLoading ? onChanged : null,
                contentPadding: EdgeInsets.zero,
              ),
            ] else if (setting.minValue != null && setting.maxValue != null) ...[
              Row(
                children: [
                  Text('${setting.minValue}'),
                  Expanded(
                    child: Slider(
                      value: setting.value.toDouble(),
                      min: setting.minValue.toDouble(),
                      max: setting.maxValue.toDouble(),
                      divisions: (setting.maxValue - setting.minValue),
                      label: setting.value.toString(),
                      onChanged: isConnected && !isLoading
                          ? (value) => onChanged(value.round())
                          : null,
                    ),
                  ),
                  Text('${setting.maxValue}'),
                ],
              ),
              Center(
                child: Text(
                  'Current: ${setting.value}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
            ] else ...[
              TextFormField(
                initialValue: setting.value.toString(),
                enabled: isConnected && !isLoading,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onFieldSubmitted: (value) => onChanged(value),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  const _StatusMessage({
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError ? Colors.red.withValues(alpha: 0.3) : Colors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error : Icons.check_circle,
            color: isError ? Colors.red : Colors.green,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: isError ? Colors.red : Colors.green),
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(Icons.close, size: 16),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _DisconnectedWarning extends StatelessWidget {
  const _DisconnectedWarning();

  @override
  Widget build(BuildContext context) {
    return Container(
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
              'Robot not connected. Settings are disabled.',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}