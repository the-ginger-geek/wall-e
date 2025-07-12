import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';

/// Base state class for ViewModels
abstract class BaseViewState extends Equatable {
  const BaseViewState();
}

/// Base ViewModel class with common functionality
abstract class BaseViewModel<T extends BaseViewState> extends ChangeNotifier {
  T _state;
  
  BaseViewModel(this._state);
  
  /// Current state
  T get state => _state;
  
  /// Update state and notify listeners
  @protected
  void setState(T newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }
  
  /// Execute an async operation with loading state
  @protected
  Future<void> executeWithLoading<R>(
    Future<R> Function() operation,
    T Function(R result) onSuccess,
    T Function(String error) onError,
    T loadingState,
  ) async {
    setState(loadingState);
    
    try {
      final result = await operation();
      setState(onSuccess(result));
    } catch (e) {
      setState(onError(e.toString()));
    }
  }
  
}