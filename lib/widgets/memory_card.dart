import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/memory.dart';

class MemoryCard extends StatelessWidget {
  final Memory memory;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const MemoryCard({
    super.key,
    required this.memory,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 8,
      shadowColor: const Color(0xFF0F3460).withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: memory.isLocked
                  ? [
                      const Color(0xFF16213E),
                      const Color(0xFF0F3460),
                    ]
                  : [
                      const Color(0xFF1A1A2E),
                      const Color(0xFF16213E),
                    ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with lock status and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Lock Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: memory.isLocked
                          ? const Color(0xFFE94560).withValues(alpha: 0.2)
                          : const Color(0xFF4CAF50).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: memory.isLocked
                            ? const Color(0xFFE94560)
                            : const Color(0xFF4CAF50),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          memory.isLocked ? Icons.lock : Icons.lock_open,
                          size: 16,
                          color: memory.isLocked
                              ? const Color(0xFFE94560)
                              : const Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          memory.isLocked ? 'Locked' : 'Unlocked',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: memory.isLocked
                                ? const Color(0xFFE94560)
                                : const Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Date
                  Text(
                    DateFormat('MMM dd, yyyy').format(memory.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFB8B8B8),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Title
              Text(
                memory.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // Description
              Text(
                memory.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFB8B8B8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 16),
              
              // Bottom section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Unlock date or countdown
                  if (memory.isLocked) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Unlocks on',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB8B8B8),
                          ),
                        ),
                        Text(
                          DateFormat('MMM dd, yyyy').format(memory.unlockDate),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE94560),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Unlocked on',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB8B8B8),
                          ),
                        ),
                        Text(
                          DateFormat('MMM dd, yyyy').format(memory.unlockDate),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  // Action buttons
                  Row(
                    children: [
                      if (onDelete != null)
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Color(0xFFE94560),
                            size: 20,
                          ),
                          tooltip: 'Delete memory',
                        ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: const Color(0xFFB8B8B8),
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
              
              // Countdown section for locked memories
              _buildCountdownSection(),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(
      begin: 0.2,
      duration: 400.ms,
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildCountdownSection() {
    if (!memory.isLocked) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final unlockDate = memory.unlockDate;
    final duration = unlockDate.difference(now);

    if (duration.isNegative) {
      return const SizedBox.shrink();
    }

    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Unlocks in',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFFB8B8B8),
          ),
        ),
        Text(
          '$days days, $hours hours, $minutes minutes, $seconds seconds',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE94560),
          ),
        ),
      ],
    );
  }
}
