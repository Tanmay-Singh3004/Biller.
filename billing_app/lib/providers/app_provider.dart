import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/register.dart';
import '../services/auth_service.dart';
import '../services/register_service.dart';

class AppProvider with ChangeNotifier {
  User? _currentUser;
  Register? _currentRegister;
  List<Register> _userRegisters = [];
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  Register? get currentRegister => _currentRegister;
  List<Register> get userRegisters => _userRegisters;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    setLoading(true);
    try {
      final user = await AuthService.signIn(email, password);
      if (user != null) {
        _currentUser = user;
        await loadUserRegisters();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> signUp(String email, String password) async {
    setLoading(true);
    try {
      final user = await AuthService.signUp(email, password);
      if (user != null) {
        _currentUser = user;
        _userRegisters = [];
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadUserRegisters() async {
    if (_currentUser != null) {
      _userRegisters = await RegisterService.getRegistersByUserId(_currentUser!.id);
      notifyListeners();
    }
  }

  Future<void> createRegister(String name) async {
    if (_currentUser != null) {
      setLoading(true);
      try {
        final register = await RegisterService.createRegister(name, _currentUser!.id);
        _userRegisters.add(register);
        notifyListeners();
      } finally {
        setLoading(false);
      }
    }
  }

  void setCurrentRegister(Register register) {
    _currentRegister = register;
    notifyListeners();
  }

  void signOut() {
    _currentUser = null;
    _currentRegister = null;
    _userRegisters = [];
    notifyListeners();
  }

  Future<void> linkGoogleAccount(String googleAccountId) async {
    if (_currentUser != null) {
      await AuthService.linkGoogleAccount(_currentUser!.id, googleAccountId);
      _currentUser!.googleAccountLinked = true;
      _currentUser!.googleAccountId = googleAccountId;
      notifyListeners();
    }
  }

  Future<void> unlinkGoogleAccount() async {
    if (_currentUser != null) {
      await AuthService.unlinkGoogleAccount(_currentUser!.id);
      _currentUser!.googleAccountLinked = false;
      _currentUser!.googleAccountId = null;
      notifyListeners();
    }
  }

  Future<void> refreshCurrentUser() async {
    if (_currentUser != null) {
      final updatedUser = await AuthService.getUserById(_currentUser!.id);
      if (updatedUser != null) {
        _currentUser = updatedUser;
        notifyListeners();
      }
    }
  }
}
