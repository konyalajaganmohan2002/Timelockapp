import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/memory.dart';

class StorageManager {
  static const String _memoriesKey = 'memories';
  
  // Save memory to local storage
  Future<void> saveMemory(Memory memory) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final memoriesJson = prefs.getStringList(_memoriesKey) ?? [];
      
      // Check if memory already exists
      final existingIndex = memoriesJson.indexWhere((json) {
        final existingMemory = Memory.fromMap(jsonDecode(json));
        return existingMemory.id == memory.id;
      });
      
      if (existingIndex != -1) {
        // Update existing memory
        memoriesJson[existingIndex] = jsonEncode(memory.toMap());
      } else {
        // Add new memory
        memoriesJson.add(jsonEncode(memory.toMap()));
      }
      
      await prefs.setStringList(_memoriesKey, memoriesJson);
    } catch (e) {
      throw Exception('Failed to save memory: $e');
    }
  }

  // Retrieve all memories from local storage
  Future<List<Memory>> getMemories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final memoriesJson = prefs.getStringList(_memoriesKey) ?? [];
      
      return memoriesJson.map((json) {
        return Memory.fromMap(jsonDecode(json));
      }).toList();
    } catch (e) {
      throw Exception('Failed to retrieve memories: $e');
    }
  }

  // Delete memory from local storage
  Future<void> deleteMemory(String memoryId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final memoriesJson = prefs.getStringList(_memoriesKey) ?? [];
      
      // Find and remove the memory
      final memoryToDelete = memoriesJson.firstWhere((json) {
        final memory = Memory.fromMap(jsonDecode(json));
        return memory.id == memoryId;
      });
      
      final memory = Memory.fromMap(jsonDecode(memoryToDelete));
      
      // Delete the image file if it exists
      if (memory.imagePath.isNotEmpty) {
        await _deleteImageFile(memory.imagePath);
      }
      
      // Remove from storage
      memoriesJson.removeWhere((json) {
        final memory = Memory.fromMap(jsonDecode(json));
        return memory.id == memoryId;
      });
      
      await prefs.setStringList(_memoriesKey, memoriesJson);
    } catch (e) {
      throw Exception('Failed to delete memory: $e');
    }
  }

  // Save image to local storage and return the path
  Future<String> saveImage(File imageFile) async {
    try {
      // Validate file exists
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      // Validate file size (max 10MB)
      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('Image file size exceeds 10MB limit');
      }

      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/images');
      
      // Create images directory if it doesn't exist
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      
      // Generate unique filename with better naming
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = imageFile.path.split('.').last.toLowerCase();
      
      // Validate file extension
      if (!['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
        throw Exception('Unsupported image format. Please use JPG, PNG, GIF, or WebP');
      }
      
      final filename = 'memory_${timestamp}_${DateTime.now().microsecondsSinceEpoch}.$extension';
      final savedPath = '${imagesDir.path}/$filename';
      
      // Copy the image to the app directory
      await imageFile.copy(savedPath);
      
      // Verify the copied file
      final savedFile = File(savedPath);
      if (!await savedFile.exists()) {
        throw Exception('Failed to save image file');
      }
      
      return savedPath;
    } catch (e) {
      throw Exception('Failed to save image: $e');
    }
  }

  // Delete image file
  Future<void> _deleteImageFile(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore errors when deleting image files
      print('Warning: Failed to delete image file: $e');
    }
  }

  // Get image file
  Future<File?> getImageFile(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Clear all data (for testing or reset purposes)
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_memoriesKey);
      
      // Delete all image files
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/images');
      if (await imagesDir.exists()) {
        await imagesDir.delete(recursive: true);
      }
    } catch (e) {
      throw Exception('Failed to clear data: $e');
    }
  }
}
