import 'package:flutter_test/flutter_test.dart';
import 'package:timelock_digital_memory_app/models/memory.dart';

void main() {
  group('Memory Model Tests', () {
    late DateTime futureDate;
    late DateTime pastDate;
    late DateTime now;

    setUp(() {
      now = DateTime.now();
      futureDate = now.add(const Duration(days: 1));
      pastDate = now.subtract(const Duration(days: 1));
    });

    test('Memory constructor sets isLocked correctly', () {
      // Memory with future unlock date should be locked
      final lockedMemory = Memory(
        id: '1',
        title: 'Test Memory',
        description: 'Test Description',
        unlockDate: futureDate,
        imagePath: '/test/path',
        createdAt: now,
      );
      expect(lockedMemory.isLocked, true);

      // Memory with past unlock date should be unlocked
      final unlockedMemory = Memory(
        id: '2',
        title: 'Test Memory 2',
        description: 'Test Description 2',
        unlockDate: pastDate,
        imagePath: '/test/path2',
        createdAt: now,
      );
      expect(unlockedMemory.isLocked, false);
    });

    test('canView() method works correctly', () {
      final lockedMemory = Memory(
        id: '1',
        title: 'Test Memory',
        description: 'Test Description',
        unlockDate: futureDate,
        imagePath: '/test/path',
        createdAt: now,
      );
      expect(lockedMemory.canView(), false);

      final unlockedMemory = Memory(
        id: '2',
        title: 'Test Memory 2',
        description: 'Test Description 2',
        unlockDate: pastDate,
        imagePath: '/test/path2',
        createdAt: now,
      );
      expect(unlockedMemory.canView(), true);
    });

    test('toMap() and fromMap() serialization works correctly', () {
      final originalMemory = Memory(
        id: '1',
        title: 'Test Memory',
        description: 'Test Description',
        unlockDate: futureDate,
        imagePath: '/test/path',
        createdAt: now,
      );

      final map = originalMemory.toMap();
      final reconstructedMemory = Memory.fromMap(map);

      expect(reconstructedMemory.id, originalMemory.id);
      expect(reconstructedMemory.title, originalMemory.title);
      expect(reconstructedMemory.description, originalMemory.description);
      expect(reconstructedMemory.unlockDate.millisecondsSinceEpoch, 
             originalMemory.unlockDate.millisecondsSinceEpoch);
      expect(reconstructedMemory.imagePath, originalMemory.imagePath);
      expect(reconstructedMemory.createdAt.millisecondsSinceEpoch, 
             originalMemory.createdAt.millisecondsSinceEpoch);
      expect(reconstructedMemory.isLocked, originalMemory.isLocked);
    });

    test('copyWith() method works correctly', () {
      final originalMemory = Memory(
        id: '1',
        title: 'Test Memory',
        description: 'Test Description',
        unlockDate: futureDate,
        imagePath: '/test/path',
        createdAt: now,
      );

      final updatedMemory = originalMemory.copyWith(
        title: 'Updated Title',
        description: 'Updated Description',
      );

      expect(updatedMemory.id, originalMemory.id);
      expect(updatedMemory.title, 'Updated Title');
      expect(updatedMemory.description, 'Updated Description');
      expect(updatedMemory.unlockDate, originalMemory.unlockDate);
      expect(updatedMemory.imagePath, originalMemory.imagePath);
      expect(updatedMemory.createdAt, originalMemory.createdAt);
      expect(updatedMemory.isLocked, originalMemory.isLocked);
    });

    test('Lock status changes based on unlock date', () {
      // Test with exact current time
      final exactNowMemory = Memory(
        id: '1',
        title: 'Test Memory',
        description: 'Test Description',
        unlockDate: now,
        imagePath: '/test/path',
        createdAt: now,
      );
      expect(exactNowMemory.isLocked, false);

      // Test with future time (even 1 second)
      final oneSecondFuture = now.add(const Duration(seconds: 1));
      final oneSecondFutureMemory = Memory(
        id: '2',
        title: 'Test Memory 2',
        description: 'Test Description 2',
        unlockDate: oneSecondFuture,
        imagePath: '/test/path2',
        createdAt: now,
      );
      expect(oneSecondFutureMemory.isLocked, true);

      // Test with past time (even 1 second)
      final oneSecondPast = now.subtract(const Duration(seconds: 1));
      final oneSecondPastMemory = Memory(
        id: '3',
        title: 'Test Memory 3',
        description: 'Test Description 3',
        unlockDate: oneSecondPast,
        imagePath: '/test/path3',
        createdAt: now,
      );
      expect(oneSecondPastMemory.isLocked, false);
    });

    test('Edge cases for unlock dates', () {
      // Test with very far future date
      final farFutureDate = now.add(const Duration(days: 365 * 10)); // 10 years
      final farFutureMemory = Memory(
        id: '1',
        title: 'Far Future Memory',
        description: 'Test Description',
        unlockDate: farFutureDate,
        imagePath: '/test/path',
        createdAt: now,
      );
      expect(farFutureMemory.isLocked, true);

      // Test with very far past date
      final farPastDate = now.subtract(const Duration(days: 365 * 10)); // 10 years ago
      final farPastMemory = Memory(
        id: '2',
        title: 'Far Past Memory',
        description: 'Test Description',
        unlockDate: farPastDate,
        imagePath: '/test/path2',
        createdAt: now,
      );
      expect(farPastMemory.isLocked, false);
    });
  });
}
