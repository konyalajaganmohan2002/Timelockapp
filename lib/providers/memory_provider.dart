import 'package:flutter/foundation.dart';
import '../models/memory.dart';
import '../services/storage_manager.dart';

enum MemoryFilter { all, locked, unlocked }

class MemoryProvider with ChangeNotifier {
  final StorageManager _storageManager = StorageManager();
  
  List<Memory> _memories = [];
  MemoryFilter _currentFilter = MemoryFilter.all;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Memory> get memories => _getFilteredMemories();
  MemoryFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalMemories => _memories.length;
  int get lockedMemories => _memories.where((m) => m.isLocked).length;
  int get unlockedMemories => _memories.where((m) => !m.isLocked).length;

  // Initialize provider
  Future<void> initialize() async {
    await loadMemories();
  }

  // Load memories from storage
  Future<void> loadMemories() async {
    try {
      _setLoading(true);
      _clearError();
      
      _memories = await _storageManager.getMemories();
      
      // Sort memories by creation date (newest first)
      _memories.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load memories: $e');
      _setLoading(false);
    }
  }

  // Add new memory
  Future<void> addMemory(Memory memory) async {
    try {
      // Validate memory data
      if (memory.title.trim().isEmpty) {
        throw Exception('Memory title cannot be empty');
      }
      if (memory.description.trim().isEmpty) {
        throw Exception('Memory description cannot be empty');
      }
      if (memory.unlockDate.isBefore(DateTime.now())) {
        throw Exception('Unlock date must be in the future');
      }
      if (memory.imagePath.isEmpty) {
        throw Exception('Memory must have an image');
      }

      _setLoading(true);
      _clearError();
      
      await _storageManager.saveMemory(memory);
      _memories.add(memory);
      
      // Sort memories by creation date (newest first)
      _memories.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add memory: $e');
      _setLoading(false);
      rethrow; // Re-throw to let UI handle the error
    }
  }

  // Update existing memory
  Future<void> updateMemory(Memory memory) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _storageManager.saveMemory(memory);
      
      final index = _memories.indexWhere((m) => m.id == memory.id);
      if (index != -1) {
        _memories[index] = memory;
        // Sort memories by creation date (newest first)
        _memories.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update memory: $e');
      _setLoading(false);
    }
  }

  // Delete memory
  Future<void> deleteMemory(String memoryId) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _storageManager.deleteMemory(memoryId);
      _memories.removeWhere((m) => m.id == memoryId);
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete memory: $e');
      _setLoading(false);
    }
  }

  // Set filter
  void setFilter(MemoryFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  // Get filtered memories
  List<Memory> _getFilteredMemories() {
    switch (_currentFilter) {
      case MemoryFilter.locked:
        return _memories.where((m) => m.isLocked).toList();
      case MemoryFilter.unlocked:
        return _memories.where((m) => !m.isLocked).toList();
      case MemoryFilter.all:
      default:
        return _memories;
    }
  }

  // Refresh memories (for pull-to-refresh)
  Future<void> refreshMemories() async {
    await loadMemories();
  }

  // Clear error
  void _clearError() {
    _error = null;
  }

  // Set error
  void _setError(String error) {
    _error = error;
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
  }

  // Get memory by ID
  Memory? getMemoryById(String id) {
    try {
      return _memories.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  // Check if memory can be viewed
  bool canViewMemory(String memoryId) {
    final memory = getMemoryById(memoryId);
    return memory?.canView() ?? false;
  }

  // Get countdown for locked memory
  Duration? getCountdown(String memoryId) {
    final memory = getMemoryById(memoryId);
    if (memory == null || !memory.isLocked) return null;
    
    final now = DateTime.now();
    if (now.isAfter(memory.unlockDate)) return Duration.zero;
    
    return memory.unlockDate.difference(now);
  }
}
