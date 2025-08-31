import 'package:flutter/material.dart';
import 'package:timelock_digital_memory_app/services/security_manager.dart';
import 'package:timelock_digital_memory_app/screens/biometric_registration_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final SecurityManager _securityManager = SecurityManager();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  
  bool _enableBiometric = false;
  bool _biometricAvailable = false;
  bool _isPinSet = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
  }

  Future<void> _checkBiometricSupport() async {
    try {
      final isAvailable = await _securityManager.isBiometricAvailable();
      final hasBiometrics = await _securityManager.hasBiometricsRegistered();
      final isPinSet = await _securityManager.isPinSet();
      
      setState(() {
        _biometricAvailable = isAvailable && hasBiometrics;
        _isPinSet = isPinSet;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error checking biometric support: $e';
      });
    }
  }

  Future<void> _handleSetup() async {
    if (_isPinSet) {
      // PIN already set, proceed to biometric setup or app
      if (_biometricAvailable && _enableBiometric) {
        final success = await _securityManager.enableBiometric();
        if (success) {
          _navigateToApp();
        } else {
          setState(() {
            _errorMessage = 'Failed to enable biometric authentication.';
          });
        }
      } else {
        _navigateToApp();
      }
      return;
    }

    // PIN not set, validate and create PIN
    final pin = _pinController.text;
    final confirmPin = _confirmPinController.text;

    if (pin.isEmpty || confirmPin.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both PIN fields.';
      });
      return;
    }

    if (pin != confirmPin) {
      setState(() {
        _errorMessage = 'PINs do not match.';
      });
      return;
    }

    if (pin.length < 4) {
      setState(() {
        _errorMessage = 'PIN must be at least 4 digits.';
      });
      return;
    }

    try {
      final success = await _securityManager.setPin(pin);
      if (success) {
        setState(() {
          _isPinSet = true;
          _errorMessage = '';
        });
        
        // If biometric is enabled, set it up
        if (_biometricAvailable && _enableBiometric) {
          final biometricSuccess = await _securityManager.enableBiometric();
          if (biometricSuccess) {
            _navigateToApp();
          } else {
            setState(() {
              _errorMessage = 'PIN set successfully, but biometric setup failed.';
            });
          }
        } else {
          _navigateToApp();
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to set PIN. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error setting PIN: $e';
      });
    }
  }

  Future<void> _openBiometricRegistration() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BiometricRegistrationScreen(),
      ),
    );
    
    if (result == true) {
      // Registration successful
      setState(() {
        _enableBiometric = true;
        _errorMessage = '';
      });
    }
  }

  void _navigateToApp() {
    Navigator.of(context).pushReplacementNamed('/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F3460),
      appBar: AppBar(
        title: const Text("TimeLock Digital Memory App"),
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 
                      MediaQuery.of(context).padding.top - 
                      kToolbarHeight - 40, // 40 for padding
          ),
          child: IntrinsicHeight(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo and Title Section
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213E),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F3460).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_clock,
                    size: 60,
                    color: Color(0xFFE94560),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'TimeLock',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Digital Memory App',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFB8B8B8),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Divider
                Container(
                  height: 1,
                  width: double.infinity,
                  color: const Color(0xFF0F3460).withOpacity(0.3),
                ),
                const SizedBox(height: 24),
                
                // Setup Section Title
                const Text(
                  "Set up your security",
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                
                // PIN Setup Section - Only show if PIN not already set
                if (!_isPinSet) ...[
                  TextField(
                    controller: _pinController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Enter PIN",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmPinController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Confirm PIN",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  // Show PIN already set message
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "PIN already set up ✓",
                            style: TextStyle(color: Colors.green, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                if (_biometricAvailable) ...[
                  CheckboxListTile(
                    title: const Text(
                      "Enable Fingerprint Authentication",
                      style: TextStyle(color: Colors.white),
                    ),
                    value: _enableBiometric,
                    onChanged: (value) {
                      setState(() {
                        _enableBiometric = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFFE94560),
                    checkColor: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  
                  // Register Fingerprint Button - Only show if not already enabled
                  if (!_enableBiometric) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _openBiometricRegistration,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE94560),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.fingerprint, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Register Fingerprint Now',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Biometrics not available. Please set up fingerprint in device Settings first.",
                            style: TextStyle(color: Colors.orange, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Complete Setup Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _handleSetup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE94560),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _isPinSet ? "Continue to App" : "Complete Setup",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                if (_errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
