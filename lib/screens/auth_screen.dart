import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../services/security_manager.dart';
import '../widgets/pin_input_dialog.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final SecurityManager _securityManager = SecurityManager();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isBiometricAvailable = false;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _needsSetup = false;
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkSetupStatus();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _checkSetupStatus() async {
    try {
      final needsSetup = await _securityManager.needsSetup();
      final isBiometricAvailable = await _securityManager.isBiometricAvailable();
      final isBiometricEnabled = await _securityManager.isBiometricEnabled();
      
      setState(() {
        _needsSetup = needsSetup;
        _isBiometricAvailable = isBiometricAvailable;
        _isBiometricEnabled = isBiometricEnabled;
      });

      // If setup is needed, navigate to setup screen
      if (_needsSetup) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed('/setup');
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to check setup status';
      });
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // First check if biometrics are enabled for this app
      final isEnabled = await _securityManager.isBiometricEnabled();
      
      if (!isEnabled) {
        // Biometrics not enabled - guide user to enable them
        setState(() {
          _errorMessage = 'Biometrics not enabled. Please go to Setup to enable fingerprint authentication.';
        });
        return;
      }

      // Check if device has biometrics registered
      final hasBiometrics = await _securityManager.hasBiometricsRegistered();
      if (!hasBiometrics) {
        setState(() {
          _errorMessage = 'No biometrics registered on device. Please set up fingerprint in device Settings first.';
        });
        return;
      }

      // Now try to authenticate
      final success = await _securityManager.authenticateUser();
      if (success) {
        _onAuthenticationSuccess();
      } else {
        setState(() {
          _errorMessage = 'Biometric authentication failed. Please try again or use PIN.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Biometric authentication error. Please check your device settings or use PIN instead.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openBiometricRegistration() async {
    final result = await Navigator.of(context).pushNamed('/biometric-registration');
    
    // If registration was successful, refresh the biometric status
    if (result == true) {
      await _checkSetupStatus();
      setState(() {
        _errorMessage = '✅ Biometric registered successfully! You can now use fingerprint login.';
      });
      
      // Clear success message after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _errorMessage = '';
          });
        }
      });
    }
  }

  Future<void> _authenticateWithPin() async {
    final pin = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PinInputDialog(isLogin: true),
    );

    if (pin != null) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        final success = await _securityManager.authenticateWithPin(pin);
        if (success) {
          _onAuthenticationSuccess();
        } else {
          setState(() {
            _errorMessage = 'Invalid PIN';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'PIN authentication error: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onAuthenticationSuccess() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show auth screen if setup is needed
    if (_needsSetup) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1A2E),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE94560)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo and Title
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
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
                      const SizedBox(height: 24),
                      const Text(
                        'TimeLock',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Digital Memory App',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFB8B8B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Authentication Options
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      if (_isBiometricAvailable) ...[
                        _buildAuthButton(
                          icon: Icons.fingerprint,
                          text: 'Use Biometric',
                          onPressed: _isLoading ? null : _authenticateWithBiometrics,
                          color: const Color(0xFFE94560),
                        ),
                        const SizedBox(height: 16),
                        
                        // Register Biometric Button - Only show if not already registered
                        if (!_isBiometricEnabled) ...[
                          _buildAuthButton(
                            icon: Icons.app_registration,
                            text: 'Register Biometric',
                            onPressed: _isLoading ? null : _openBiometricRegistration,
                            color: const Color(0xFF0F3460),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        const Text(
                          'or',
                          style: TextStyle(
                            color: Color(0xFFB8B8B8),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      _buildAuthButton(
                        icon: Icons.pin,
                        text: 'Use PIN',
                        onPressed: _isLoading ? null : _authenticateWithPin,
                        color: const Color(0xFF16213E),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Error Message
              if (_errorMessage.isNotEmpty)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE94560).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE94560).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: const Color(0xFFE94560),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      // Setup button when biometrics not enabled
                      if (_errorMessage.contains('Biometrics not enabled'))
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pushReplacementNamed('/setup'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F3460),
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.settings, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Go to Setup',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              
              // Loading Indicator
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE94560)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthButton({
    required IconData icon,
    required String text,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: color.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
