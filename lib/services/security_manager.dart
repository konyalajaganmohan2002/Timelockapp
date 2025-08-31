import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class SecurityManager {
  static const String _pinKey = 'user_pin';
  static const String _sessionKey = 'session_active';
  static const String _lastActivityKey = 'last_activity';
  static const String _biometricEnabledKey = 'biometric_enabled';
  
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  // Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      final bool canAuthenticate = canCheckBiometrics || isDeviceSupported;
      
      print('🔍 Biometric Debug:');
      print('  - canCheckBiometrics: $canCheckBiometrics');
      print('  - isDeviceSupported: $isDeviceSupported');
      print('  - canAuthenticate: $canAuthenticate');
      
      return canAuthenticate;
    } catch (e) {
      print('❌ Biometric Error: $e');
      return false;
    }
  }

  // Check if user has biometrics registered on device
  Future<bool> hasBiometricsRegistered() async {
    try {
      final List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
      final bool hasBiometrics = availableBiometrics.isNotEmpty;
      
      print('🔍 Biometric Types Debug:');
      print('  - Available biometrics: $availableBiometrics');
      print('  - Has biometrics: $hasBiometrics');
      
      return hasBiometrics;
    } catch (e) {
      print('❌ Biometric Types Error: $e');
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometricTypes() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  // Check if biometric is enabled for this app
  Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_biometricEnabledKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  // Enable biometric for this app
  Future<bool> enableBiometric() async {
    try {
      print('🔐 Starting biometric enablement...');
      
      final bool isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        print('❌ Biometric not available');
        return false;
      }

      print('✅ Biometric available, starting authentication...');
      
      // Test biometric authentication
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to enable biometric login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      print('🔐 Authentication result: $didAuthenticate');

      if (didAuthenticate) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_biometricEnabledKey, true);
        print('✅ Biometric enabled successfully');
        return true;
      }

      print('❌ Biometric authentication failed');
      return false;
    } catch (e) {
      print('❌ Biometric enablement error: $e');
      return false;
    }
  }

  // Authenticate user with biometrics
  Future<bool> authenticateUser() async {
    try {
      final bool isAvailable = await isBiometricAvailable();
      final bool isEnabled = await isBiometricEnabled();
      
      if (!isAvailable || !isEnabled) {
        return false;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please verify your identity',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        await _startSession();
      }

      return didAuthenticate;
    } catch (e) {
      return false;
    }
  }

  // Authenticate with PIN
  Future<bool> authenticateWithPin(String pin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedPin = prefs.getString(_pinKey);
      
      if (storedPin == null) {
        // First time setup - PIN should be created through setup flow
        return false;
      }

      if (storedPin == _hashPin(pin)) {
        await _startSession();
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Set PIN for backup authentication (used during setup)
  Future<bool> setPin(String pin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hashedPin = _hashPin(pin);
      await prefs.setString(_pinKey, hashedPin);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Hash PIN for security
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Start user session
  Future<void> _startSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sessionKey, true);
    await prefs.setInt(_lastActivityKey, DateTime.now().millisecondsSinceEpoch);
  }

  // Check if session is active
  Future<bool> isSessionActive() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isActive = prefs.getBool(_sessionKey) ?? false;
      
      if (isActive) {
        // Check for inactivity timeout (30 minutes)
        final lastActivity = prefs.getInt(_lastActivityKey) ?? 0;
        final lastActivityTime = DateTime.fromMillisecondsSinceEpoch(lastActivity);
        final now = DateTime.now();
        
        if (now.difference(lastActivityTime).inMinutes > 30) {
          await _endSession();
          return false;
        }
        
        // Update last activity
        await prefs.setInt(_lastActivityKey, now.millisecondsSinceEpoch);
      }
      
      return isActive;
    } catch (e) {
      return false;
    }
  }

  // End user session
  Future<void> _endSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sessionKey, false);
  }

  // Logout user
  Future<void> logout() async {
    await _endSession();
  }

  // Check if PIN is set
  Future<bool> isPinSet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_pinKey) != null;
    } catch (e) {
      return false;
    }
  }

  // Check if user needs to complete setup
  Future<bool> needsSetup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasPin = prefs.getString(_pinKey) != null;
      final hasBiometric = prefs.getBool(_biometricEnabledKey) ?? false;
      
      // User needs setup if neither PIN nor biometric is configured
      return !hasPin && !hasBiometric;
    } catch (e) {
      return true;
    }
  }

  // Check if biometric setup is complete
  Future<bool> isBiometricSetupComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_biometricEnabledKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  // Clear all app data (for testing purposes)
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      // Ignore errors
    }
  }

  // Test biometric hardware directly (for debugging)
  Future<Map<String, dynamic>> testBiometricHardware() async {
    try {
      print('🧪 Testing biometric hardware...');
      
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      final List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      final result = {
        'canCheckBiometrics': canCheckBiometrics,
        'isDeviceSupported': isDeviceSupported,
        'availableBiometrics': availableBiometrics.map((e) => e.toString()).toList(),
        'hasBiometrics': availableBiometrics.isNotEmpty,
      };
      
      print('🧪 Biometric Hardware Test Results:');
      print('  - canCheckBiometrics: ${result['canCheckBiometrics']}');
      print('  - isDeviceSupported: ${result['isDeviceSupported']}');
      print('  - availableBiometrics: ${result['availableBiometrics']}');
      print('  - hasBiometrics: ${result['hasBiometrics']}');
      
      return result;
    } catch (e) {
      print('❌ Biometric hardware test error: $e');
      return {
        'error': e.toString(),
        'canCheckBiometrics': false,
        'isDeviceSupported': false,
        'availableBiometrics': [],
        'hasBiometrics': false,
      };
    }
  }
}
