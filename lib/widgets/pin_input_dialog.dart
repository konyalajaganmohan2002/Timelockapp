import 'package:flutter/material.dart';

class PinInputDialog extends StatefulWidget {
  final bool isLogin;
  
  const PinInputDialog({
    super.key,
    this.isLogin = false,
  });

  @override
  State<PinInputDialog> createState() => _PinInputDialogState();
}

class _PinInputDialogState extends State<PinInputDialog> {
  final List<String> _pin = [];
  final int _pinLength = 4;
  bool _isConfirming = false;
  List<String> _confirmPin = [];
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              widget.isLogin 
                ? 'Enter PIN'
                : (_isConfirming ? 'Confirm PIN' : 'Create PIN'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Subtitle
            Text(
              widget.isLogin
                ? 'Enter your 4-digit PIN to access the app'
                : (_isConfirming 
                    ? 'Please confirm your PIN'
                    : 'Create a 4-digit PIN for backup authentication'),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFB8B8B8),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // PIN Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pinLength, (index) {
                final currentPin = widget.isLogin ? _pin : (_isConfirming ? _confirmPin : _pin);
                final isFilled = index < currentPin.length;
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled ? const Color(0xFFE94560) : const Color(0xFF16213E),
                    border: Border.all(
                      color: const Color(0xFFE94560),
                      width: 2,
                    ),
                  ),
                );
              }),
            ),
            
            const SizedBox(height: 32),
            
            // Error Message
            if (_errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE94560).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFE94560).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: const Color(0xFFE94560),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Number Pad
            Column(
              children: [
                // Row 1: 1, 2, 3
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildNumberButton('1'),
                    _buildNumberButton('2'),
                    _buildNumberButton('3'),
                  ],
                ),
                // Row 2: 4, 5, 6
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildNumberButton('4'),
                    _buildNumberButton('5'),
                    _buildNumberButton('6'),
                  ],
                ),
                // Row 3: 7, 8, 9
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildNumberButton('7'),
                    _buildNumberButton('8'),
                    _buildNumberButton('9'),
                  ],
                ),
                // Row 4: centered 0 and backspace
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 88), // Space for left alignment
                    _buildNumberButton('0'),
                    _buildBackspaceButton(),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Cancel Button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFFB8B8B8),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    if (number.isEmpty) {
      return const SizedBox(height: 80);
    }
    
    return Container(
      margin: const EdgeInsets.all(4),
      height: 80,
      child: ElevatedButton(
        onPressed: () => _addDigit(number),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF16213E),
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: const Color(0xFF0F3460).withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        child: Text(
          number,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return Container(
      margin: const EdgeInsets.all(4),
      height: 80,
      child: ElevatedButton(
        onPressed: _removeDigit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE94560),
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: const Color(0xFFE94560).withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        child: const Icon(
          Icons.backspace,
          size: 24,
        ),
      ),
    );
  }

  void _addDigit(String digit) {
    final currentPin = widget.isLogin ? _pin : (_isConfirming ? _confirmPin : _pin);
    
    if (currentPin.length < _pinLength) {
      setState(() {
        currentPin.add(digit);
        _errorMessage = '';
      });
      
      if (currentPin.length == _pinLength) {
        _onPinComplete();
      }
    }
  }

  void _removeDigit() {
    final currentPin = widget.isLogin ? _pin : (_isConfirming ? _confirmPin : _pin);
    
    if (currentPin.isNotEmpty) {
      setState(() {
        currentPin.removeLast();
        _errorMessage = '';
      });
    }
  }

  void _onPinComplete() {
    if (widget.isLogin) {
      // Login mode - return PIN immediately
      Navigator.of(context).pop(_pin.join());
    } else {
      // Creation mode - handle confirmation
      if (!_isConfirming) {
        // First time entering PIN, switch to confirmation
        setState(() {
          _isConfirming = true;
          _errorMessage = '';
        });
      } else {
        // Confirming PIN
        if (_pin.join() == _confirmPin.join()) {
          Navigator.of(context).pop(_pin.join());
        } else {
          setState(() {
            _errorMessage = 'PINs do not match. Please try again.';
            _confirmPin.clear();
          });
        }
      }
    }
  }
}
