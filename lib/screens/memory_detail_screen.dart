import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/memory.dart';
import '../services/storage_manager.dart';
import 'dart:async';

class MemoryDetailScreen extends StatefulWidget {
  final Memory memory;

  const MemoryDetailScreen({
    super.key,
    required this.memory,
  });

  @override
  State<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends State<MemoryDetailScreen> with TickerProviderStateMixin {
  final StorageManager _storageManager = StorageManager();
  File? _imageFile;
  bool _isLoadingImage = true;
  late Timer _countdownTimer;
  String _timeRemaining = '';

  @override
  void initState() {
    super.initState();
    _loadImage();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    super.dispose();
  }

  void _startCountdownTimer() {
    _updateTimeRemaining();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateTimeRemaining();
      }
    });
  }

  void _updateTimeRemaining() {
    setState(() {
      _timeRemaining = _getTimeRemaining();
    });
  }

  Future<void> _loadImage() async {
    try {
      final file = await _storageManager.getImageFile(widget.memory.imagePath);
      setState(() {
        _imageFile = file;
        _isLoadingImage = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text(
          widget.memory.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF16213E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            _buildImageSection(),
            
            const SizedBox(height: 24),
            
            // Lock Status Section
            _buildLockStatusSection(),
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              widget.memory.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              widget.memory.description,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFFB8B8B8),
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Details Section
            _buildDetailsSection(),
            
            const SizedBox(height: 24),
            
            // Content Section (if unlocked)
            if (!widget.memory.isLocked) _buildContentSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F3460).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _isLoadingImage
            ? Container(
                color: const Color(0xFF16213E),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE94560)),
                  ),
                ),
              )
            : _imageFile != null
                ? Image.file(
                    _imageFile!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : Container(
                    color: const Color(0xFF16213E),
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 64,
                        color: Color(0xFFB8B8B8),
                      ),
                    ),
                  ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(
      begin: 0.3,
      duration: 600.ms,
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildLockStatusSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.memory.isLocked
            ? const Color(0xFFE94560).withValues(alpha: 0.1)
            : const Color(0xFF4CAF50).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.memory.isLocked
              ? const Color(0xFFE94560)
              : const Color(0xFF4CAF50),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            widget.memory.isLocked ? Icons.lock : Icons.lock_open,
            size: 32,
            color: widget.memory.isLocked
                ? const Color(0xFFE94560)
                : const Color(0xFF4CAF50),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.memory.isLocked ? 'Memory Locked' : 'Memory Unlocked',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.memory.isLocked
                        ? const Color(0xFFE94560)
                        : const Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(height: 4),
                if (widget.memory.isLocked)
                  Text(
                    'This memory will unlock on ${DateFormat('MMM dd, yyyy').format(widget.memory.unlockDate)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFB8B8B8),
                    ),
                  )
                else
                  Text(
                    'This memory was unlocked on ${DateFormat('MMM dd, yyyy').format(widget.memory.unlockDate)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFB8B8B8),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).slideX(
      begin: -0.3,
      duration: 800.ms,
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F3460).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow(
            icon: Icons.calendar_today,
            label: 'Created',
            value: DateFormat('MMM dd, yyyy').format(widget.memory.createdAt),
          ),
          const Divider(color: Color(0xFF0F3460), height: 24),
          _buildDetailRow(
            icon: Icons.schedule,
            label: 'Unlock Date',
            value: DateFormat('MMM dd, yyyy').format(widget.memory.unlockDate),
          ),
          if (widget.memory.isLocked) ...[
            const Divider(color: Color(0xFF0F3460), height: 24),
            _buildDetailRow(
              icon: Icons.timer,
              label: 'Time Remaining',
              value: _timeRemaining,
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 1000.ms).slideX(
      begin: 0.3,
      duration: 1000.ms,
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFFE94560),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFB8B8B8),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.visibility,
                color: Color(0xFF4CAF50),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Memory Content',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Congratulations! This memory is now unlocked and you can view its contents.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFB8B8B8),
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 1200.ms).scale(
      begin: const Offset(0.8, 0.8),
      duration: 1200.ms,
      curve: Curves.easeOutCubic,
    );
  }

  String _getTimeRemaining() {
    final now = DateTime.now();
    final difference = widget.memory.unlockDate.difference(now);
    
    if (difference.isNegative) {
      return 'Ready to unlock!';
    }
    
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    
    if (days > 0) {
      return '$days days, $hours hours';
    } else if (hours > 0) {
      return '$hours hours, $minutes minutes';
    } else {
      return '$minutes minutes';
    }
  }
}
