import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/memory_provider.dart';
import '../widgets/memory_card.dart';
import '../models/memory.dart';
import '../services/security_manager.dart';
import 'create_memory_screen.dart';
import 'memory_detail_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MemoryListScreen extends StatefulWidget {
  const MemoryListScreen({super.key});

  @override
  State<MemoryListScreen> createState() => _MemoryListScreenState();
}

class _MemoryListScreenState extends State<MemoryListScreen> {
  final SecurityManager _securityManager = SecurityManager();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Initialize the memory provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MemoryProvider>().initialize();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Get filtered and searched memories
  List<Memory> _getFilteredAndSearchedMemories(List<Memory> memories) {
    var filteredMemories = memories;
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredMemories = filteredMemories.where((memory) {
        return memory.title.toLowerCase().contains(_searchQuery) ||
               memory.description.toLowerCase().contains(_searchQuery);
      }).toList();
    }
    
    return filteredMemories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text(
          'My Memories',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF16213E),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all, color: Colors.white),
            onPressed: _clearAppData,
            tooltip: 'Clear App Data (Testing)',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Consumer<MemoryProvider>(
        builder: (context, memoryProvider, child) {
          if (memoryProvider.isLoading && memoryProvider.memories.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE94560)),
              ),
            );
          }

          return Column(
            children: [
              // Filter Section
              _buildFilterSection(memoryProvider),
              
              // Statistics
              _buildStatisticsSection(memoryProvider),
              
              // Memories List
              Expanded(
                child: memoryProvider.memories.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: memoryProvider.refreshMemories,
                        color: const Color(0xFFE94560),
                        backgroundColor: const Color(0xFF16213E),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: memoryProvider.memories.length,
                          itemBuilder: (context, index) {
                            final memory = memoryProvider.memories[index];
                            return MemoryCard(
                              memory: memory,
                              onTap: () => _viewMemory(memory),
                              onDelete: () => _deleteMemory(memory.id, memoryProvider),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewMemory,
        backgroundColor: const Color(0xFFE94560),
        foregroundColor: Colors.white,
        elevation: 8,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildFilterSection(MemoryProvider memoryProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Memories',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildFilterChip(
                label: 'All',
                isSelected: memoryProvider.currentFilter == MemoryFilter.all,
                onTap: () => memoryProvider.setFilter(MemoryFilter.all),
              ),
              const SizedBox(width: 12),
              _buildFilterChip(
                label: 'Locked',
                isSelected: memoryProvider.currentFilter == MemoryFilter.locked,
                onTap: () => memoryProvider.setFilter(MemoryFilter.locked),
              ),
              const SizedBox(width: 12),
              _buildFilterChip(
                label: 'Unlocked',
                isSelected: memoryProvider.currentFilter == MemoryFilter.unlocked,
                onTap: () => memoryProvider.setFilter(MemoryFilter.unlocked),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE94560)
              : const Color(0xFF0F3460).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFE94560)
                : const Color(0xFFE94560).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFFB8B8B8),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(MemoryProvider memoryProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Total',
              value: memoryProvider.totalMemories.toString(),
              color: const Color(0xFF2196F3),
            ).animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.5, duration: 400.ms),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'Locked',
              value: memoryProvider.lockedMemories.toString(),
              color: const Color(0xFFE94560),
            ).animate()
              .fadeIn(duration: 600.ms)
              .slideX(begin: -0.3, duration: 600.ms),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'Unlocked',
              value: memoryProvider.unlockedMemories.toString(),
              color: const Color(0xFF4CAF50),
            ).animate()
              .fadeIn(duration: 600.ms)
              .slideX(begin: 0.3, duration: 600.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFB8B8B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_clock,
            size: 80,
            color: const Color(0xFFB8B8B8).withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          const Text(
            'No memories yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Create your first memory to get started',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFFB8B8B8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _createNewMemory,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE94560),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Create Memory',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _createNewMemory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateMemoryScreen(),
      ),
    );
  }

  void _viewMemory(Memory memory) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MemoryDetailScreen(memory: memory),
      ),
    );
  }

  Future<void> _deleteMemory(String memoryId, MemoryProvider memoryProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Delete Memory',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this memory? This action cannot be undone.',
          style: TextStyle(color: Color(0xFFB8B8B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFFB8B8B8)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFE94560)),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await memoryProvider.deleteMemory(memoryId);
    }
  }

  Future<void> _logout() async {
    await _securityManager.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  Future<void> _clearAppData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Clear App Data',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to clear all app data? This action cannot be undone.',
          style: TextStyle(color: Color(0xFFB8B8B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFFB8B8B8)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Clear',
              style: TextStyle(color: Color(0xFFE94560)),
            ),
          ),
        ],
      ),
    );

          if (confirmed == true) {
        await _securityManager.clearAllData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('App data cleared.'),
              backgroundColor: Color(0xFFE94560),
            ),
          );
        }
      }
  }
}
