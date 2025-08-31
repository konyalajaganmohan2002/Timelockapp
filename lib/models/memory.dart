class Memory {
  final String id;
  final String title;
  final String description;
  final DateTime unlockDate;
  final String imagePath; // store locally
  final bool isLocked;
  final DateTime createdAt;

  Memory({
    required this.id,
    required this.title,
    required this.description,
    required this.unlockDate,
    required this.imagePath,
    required this.createdAt,
  }) : isLocked = DateTime.now().isBefore(unlockDate);

  bool canView() {
    return DateTime.now().isAfter(unlockDate);
  }

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'unlockDate': unlockDate.millisecondsSinceEpoch,
      'imagePath': imagePath,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Create from Map
  factory Memory.fromMap(Map<String, dynamic> map) {
    return Memory(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      unlockDate: DateTime.fromMillisecondsSinceEpoch(map['unlockDate']),
      imagePath: map['imagePath'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  // Create a copy with updated fields
  Memory copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? unlockDate,
    String? imagePath,
    DateTime? createdAt,
  }) {
    return Memory(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      unlockDate: unlockDate ?? this.unlockDate,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
