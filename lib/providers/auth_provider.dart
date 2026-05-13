import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../repositories/auth_repository.dart';
import '../utils/app_logger.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  AppUser? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._authRepository) {
    _init();
  }

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null && !_user!.isGuest;
  bool get isGuest => _user?.isGuest ?? false;
  String? get error => _error;

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    
    _user = await _authRepository.getCurrentUser();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authRepository.login(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authRepository.register(name, email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loginAsGuest() async {
    _isLoading = true;
    notifyListeners();
    
    _user = await _authRepository.loginAsGuest();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _user = null;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
