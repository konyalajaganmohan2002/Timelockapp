# TimeLock - Digital Memory App

A secure Flutter application that allows users to create time-locked digital memories with photos and messages that unlock at future dates.

## 🚀 Features

### Core Functionality
- **Time-based Memory Locking**: Create memories that automatically unlock at specified dates
- **Secure Authentication**: Biometric login (fingerprint/Face ID) with PIN backup
- **Local Storage**: All data stored securely on device
- **Image Management**: Support for JPG, PNG, GIF, and WebP formats
- **Real-time Countdown**: Live countdown timers for locked memories

### Authentication & Security
- **Biometric Authentication**: Fingerprint and Face ID support
- **PIN Backup**: 4-digit PIN with SHA-256 hashing
- **Auto-lock**: Automatic session timeout for security
- **Permission Management**: Proper handling of device permissions

### Memory Management
- **Create Memories**: Add photos, titles, descriptions, and unlock dates
- **Smart Filtering**: Filter by All, Locked, or Unlocked memories
- **Search Functionality**: Search through memory titles and descriptions
- **Memory Details**: Comprehensive view with lock status and countdown
- **Delete Memories**: Remove unwanted memories with confirmation

### User Experience
- **Modern UI**: Dark theme with beautiful gradients and animations
- **Responsive Design**: Adapts to different screen sizes
- **Smooth Animations**: Fade, slide, and scale transitions
- **Pull-to-Refresh**: Easy memory list updates
- **Loading States**: Clear feedback during operations

## 🏗️ Technical Architecture

### Project Structure
```
lib/
├── models/          # Data models
├── providers/       # State management
├── screens/         # UI screens
├── services/        # Business logic
└── widgets/         # Reusable components
```

### Key Components

#### Memory Model (`lib/models/memory.dart`)
- **Automatic Locking**: `isLocked` property calculated from unlock date
- **View Control**: `canView()` method determines access
- **Serialization**: `toMap()` and `fromMap()` for storage
- **Immutability**: `copyWith()` for safe updates

#### Storage Manager (`lib/services/storage_manager.dart`)
- **Image Storage**: Local file system with format validation
- **Memory Persistence**: SharedPreferences for metadata
- **Error Handling**: Comprehensive error management
- **File Validation**: Size limits and format checking

#### Memory Provider (`lib/providers/memory_provider.dart`)
- **State Management**: Provider pattern for reactive UI
- **Data Operations**: CRUD operations with validation
- **Filtering**: Real-time memory filtering
- **Error States**: Loading and error state management

### Tech Stack
- **Framework**: Flutter 3.16+
- **Language**: Dart
- **State Management**: Provider
- **Local Storage**: SharedPreferences + Path Provider
- **Authentication**: Local Auth
- **Image Handling**: Image Picker
- **Animations**: Flutter Animate
- **Date Formatting**: Intl

## 📱 Screens

### Authentication Screen
- Biometric login with PIN fallback
- Secure session management
- Beautiful gradient design

### Memory List Screen
- Grid/list view of memories
- Advanced filtering and search
- Statistics dashboard
- Pull-to-refresh functionality


### Create Memory Screen
- Image picker (gallery support)
- Form validation
- Date picker for unlock time
- Real-time preview


### Memory Detail Screen
- Full memory display
- Lock status indicator
- Live countdown timer
- Unlock date information


## 🔒 Lock/Unlock System

### How It Works
1. **Memory Creation**: User sets unlock date in the future
2. **Automatic Locking**: Memory is locked until unlock date
3. **Real-time Countdown**: Live timer shows time remaining
4. **Automatic Unlocking**: Memory unlocks when date is reached
5. **Content Access**: Full content visible after unlocking

### Lock States
- **🔒 Locked**: Content hidden, countdown visible
- **🔓 Unlocked**: Full content accessible
- **⏰ Countdown**: Real-time updates every second

### Security Features
- **Time-based Access**: No manual override possible
- **Local Storage**: Data never leaves device
- **Biometric Protection**: Secure authentication required
- **Session Management**: Auto-lock after inactivity

## 🎨 UI/UX Features

### Design System
- **Color Palette**: Dark theme with accent colors
- **Typography**: Clear hierarchy and readability
- **Spacing**: Consistent padding and margins
- **Shadows**: Subtle depth and elevation

### Animations
- **Fade Effects**: Smooth opacity transitions
- **Slide Animations**: Directional movement
- **Scale Effects**: Size-based animations
- **Curved Motion**: Natural easing functions

### Responsive Design
- **Adaptive Layouts**: Works on all screen sizes
- **Flexible Components**: Responsive to content
- **Touch Optimization**: Proper touch targets
- **Accessibility**: Screen reader support

## 🧪 Testing

### Test Coverage
- **Unit Tests**: Memory model validation
- **Widget Tests**: UI component testing
- **Integration Tests**: End-to-end workflows
- **Performance Tests**: Memory and storage optimization

### Test Files
- `test/memory_test.dart`: Comprehensive memory model tests
- `test/widget_test.dart`: App widget testing
- **Coverage**: Lock/unlock functionality, data validation, edge cases

### Running Tests
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/memory_test.dart
```

## 📋 Installation

### Prerequisites
- Flutter 3.16 or higher
- Dart 3.0 or higher
- Android Studio / VS Code
- Android SDK / Xcode

### Setup Steps
1. **Clone Repository**
   ```bash
   git clone https://github.com/konyalajaganmohan2002/Timelockapp
   cd timelock-memory-app
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Platform Configuration**
   - **Android**: Update `android/app/src/main/AndroidManifest.xml`
   - **iOS**: Update `ios/Runner/Info.plist`

4. **Run Application**
   ```bash
   flutter run
   ```

## ⚙️ Configuration

### Android Permissions
```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.CAMERA" />
```

### iOS Permissions
```xml
<key>NSFaceIDUsageDescription</key>
<string>Use Face ID to securely access your memories</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Access photos to create memories</string>
<key>NSCameraUsageDescription</key>
<string>Take photos to create memories</string>
```

## 🚀 Usage Guide

### Creating Memories
1. Tap the + button on the home screen
2. Select an image from gallery
3. Enter title and description
4. Set unlock date (must be in future)
5. Save memory

### Viewing Memories
1. Browse memory list on home screen
2. Use filters to find specific memories
3. Search by title or description
4. Tap memory to view details

### Managing Memories
1. **View Details**: Tap any memory card
2. **Delete Memory**: Use delete button with confirmation
3. **Filter View**: Use filter chips for organization
4. **Refresh List**: Pull down to refresh

## 🔧 Development

### Code Style
- **Dart Standards**: Follow official Dart style guide
- **Flutter Best Practices**: Use recommended patterns
- **Documentation**: Inline comments for complex logic
- **Error Handling**: Comprehensive error management

### Performance
- **Image Optimization**: Automatic compression and sizing
- **Memory Management**: Efficient data structures
- **Storage Optimization**: Minimal disk usage
- **UI Performance**: Smooth 60fps animations

### Security
- **Data Validation**: Input sanitization and validation
- **Secure Storage**: Local-only data persistence
- **Authentication**: Biometric and PIN protection
- **Permission Handling**: Minimal required permissions

## 📊 Performance Metrics

### Storage Efficiency
- **Image Compression**: 85% quality with size limits
- **File Formats**: Optimized format support
- **Metadata Storage**: Efficient JSON serialization

### Memory Usage
- **Optimized Lists**: Efficient ListView.builder
- **Image Caching**: Smart image loading
- **State Management**: Minimal provider overhead

### UI Performance
- **Animation FPS**: Consistent 60fps
- **Loading Times**: Sub-second response
- **Smooth Scrolling**: Optimized list performance

## 🐛 Troubleshooting

### Common Issues
1. **Biometric Not Working**: Check device settings and permissions
2. **Images Not Loading**: Verify storage permissions
3. **App Crashes**: Check Flutter version compatibility
4. **Performance Issues**: Monitor memory usage

### Debug Mode
```bash
# Enable debug logging
flutter run --debug

# Check for issues
flutter doctor

# Analyze code
flutter analyze
```

## 📈 Roadmap

### Future Features
- **Cloud Backup**: Secure cloud storage integration
- **Memory Sharing**: Share memories with others
- **Advanced Security**: Encryption and additional auth methods
- **Categories**: Organize memories by type
- **Notifications**: Unlock reminders and alerts

### Performance Improvements
- **Image Caching**: Advanced image optimization
- **Database Migration**: SQLite for complex queries
- **Background Sync**: Automatic data synchronization
- **Offline Support**: Enhanced offline functionality

## 🤝 Contributing

### Development Process
1. Fork the repository
2. Create feature branch
3. Implement changes
4. Add tests
5. Submit pull request

### Code Review
- **Quality Standards**: Maintain code quality
- **Test Coverage**: Ensure adequate testing
- **Documentation**: Update relevant docs
- **Performance**: Consider performance impact

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Getting Help
- **Documentation**: Check this README first
- **Issues**: Report bugs on GitHub
- **Discussions**: Join community discussions
- **Email**: Contact development team

### Community
- **GitHub**: [Repository](https://github.com/yourusername/timelock-memory-app)
- **Discord**: Join our community server
- **Blog**: Development updates and tutorials
- **YouTube**: Video tutorials and demos

---

**TimeLock - Where memories wait for the perfect moment to be revealed.** 🔒✨

