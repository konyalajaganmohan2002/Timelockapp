import 'package:flutter/material.dart';
import 'package:timelock_digital_memory_app/services/security_manager.dart';

class BiometricRegistrationScreen extends StatefulWidget {
  const BiometricRegistrationScreen({super.key});

  @override
  State<BiometricRegistrationScreen> createState() => _BiometricRegistrationScreenState();
}

class _BiometricRegistrationScreenState extends State<BiometricRegistrationScreen>
    with TickerProviderStateMixin {
  final SecurityManager _securityManager = SecurityManager();
  
  bool _isLoading = false;
  String _statusMessage = '';
  bool _isSuccess = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await _securityManager.isBiometricAvailable();
      final hasBiometrics = await _securityManager.hasBiometricsRegistered();
      
      if (!isAvailable) {
        setState(() {
          _statusMessage = 'Biometric authentication is not available on this device.';
        });
        return;
      }
      
      if (!hasBiometrics) {
        setState(() {
          _statusMessage = 'No biometrics registered on device. Please set up fingerprint in device Settings first.';
        });
        return;
      }
      
      setState(() {
        _statusMessage = 'Ready to register fingerprint. Tap "Register Fingerprint" to begin.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error checking biometric availability: $e';
      });
    }
  }

  Future<void> _testHardware() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing biometric hardware...';
    });

    try {
      final result = await _securityManager.testBiometricHardware();
      
      String message = 'Hardware Test Results:\n';
      message += '• Device Supported: ${result['isDeviceSupported']}\n';
      message += '• Can Check Biometrics: ${result['canCheckBiometrics']}\n';
      message += '• Available Biometrics: ${result['availableBiometrics'].join(', ')}\n';
      message += '• Has Biometrics: ${result['hasBiometrics']}';
      
      if (result.containsKey('error')) {
        message += '\n\n❌ Error: ${result['error']}';
      }
      
      setState(() {
        _statusMessage = message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Hardware test failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _registerBiometric() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Please place your finger on the sensor...';
    });

    try {
      // First, check if biometrics are available and registered
      final isAvailable = await _securityManager.isBiometricAvailable();
      final hasBiometrics = await _securityManager.hasBiometricsRegistered();
      
      if (!isAvailable || !hasBiometrics) {
        setState(() {
          _statusMessage = 'Biometric setup incomplete. Please check device settings.';
          _isLoading = false;
        });
        return;
      }

      // Attempt to register biometric for this app
      final success = await _securityManager.enableBiometric();
      
      if (success) {
        setState(() {
          _isSuccess = true;
          _statusMessage = '🎉 Fingerprint registered successfully!';
          _isLoading = false;
        });
        
        // Show success message and navigate back after delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop(true); // Return true to indicate success
          }
        });
      } else {
        setState(() {
          _statusMessage = '❌ Fingerprint registration failed. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error during registration: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F3460),
      appBar: AppBar(
        title: const Text(
          'Register Fingerprint',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Fingerprint Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE94560).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  _isSuccess ? Icons.check_circle : Icons.fingerprint,
                  size: 60,
                  color: _isSuccess ? Colors.green : const Color(0xFFE94560),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              Text(
                _isSuccess ? 'Registration Complete!' : 'Register Your Fingerprint',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Subtitle
              Text(
                _isSuccess 
                  ? 'Your fingerprint is now registered and ready to use.'
                  : 'Place your finger on the sensor to register it for secure access.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFFB8B8B8),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Status Message
              if (_statusMessage.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isSuccess 
                      ? Colors.green.withOpacity(0.1)
                      : const Color(0xFFE94560).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isSuccess 
                        ? Colors.green.withOpacity(0.3)
                        : const Color(0xFFE94560).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      color: _isSuccess ? Colors.green : const Color(0xFFE94560),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              const SizedBox(height: 40),
              
              // Test Hardware Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _testHardware,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F3460),
                    backgroundColor: Colors.white.withOpacity(0.1),
                    side: const BorderSide(color: Color(0xFF0F3460), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.build, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Test Hardware',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Register Button
              if (!_isSuccess)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _registerBiometric,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE94560),
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: const Color(0xFFE94560).withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Registering...'),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.fingerprint, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Register Fingerprint',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // Back Button
              if (_isSuccess)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
