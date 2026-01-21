# Windows Platform Features - Task 4.19 Implementation

## Overview
This implementation covers Windows-specific platform features for FengLing Music player:

1. **System Tray** (TASK-111, TASK-112, TASK-113)
2. **Global Hotkeys** (TASK-114, TASK-115)
3. **Media Keys Support** (TASK-116)
4. **Taskbar Integration** (TASK-117)
5. **High Refresh Rate Display Detection** (TASK-118)

## Architecture

### Services Created

1. **SystemTrayService** (`lib/services/platform/windows/system_tray_service.dart`)
   - System tray icon management
   - Context menu handling
   - Tray click events
   - Window show/hide integration

2. **HotkeyService** (`lib/services/platform/windows/hotkey_service.dart`)
   - Global hotkey registration
   - Default hotkey configurations
   - Hotkey conflict detection
   - Custom hotkey support

3. **WindowService** (`lib/services/platform/windows/window_service.dart`)
   - Window lifecycle management
   - Minimize to tray behavior
   - Window show/hide/focus
   - Window state listening

4. **ScreenService** (`lib/services/platform/windows/screen_service.dart`)
   - Display refresh rate detection
   - High refresh rate support (90Hz, 120Hz, 144Hz, 165Hz)
   - Recommended frame rate calculation
   - Animation duration optimization

5. **WindowsPlatformManager** (`lib/services/platform/windows/windows_platform_manager.dart`)
   - Unified Windows platform features
   - Service coordination
   - Simplified initialization

## Dependencies Added

```yaml
# Windows platform features
system_tray: ^2.0.3          # System tray functionality
hotkey_manager: ^0.2.3       # Global hotkeys
window_manager: ^0.5.1       # Window management
screen_retriever: ^0.2.0     # Screen info detection
media_kit: ^1.1.10           # Media playback (enhanced)
media_kit_libs_windows_audio: ^1.0.9  # Windows audio backend
```

## Usage

### Basic Integration in main.dart

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'services/platform/windows/windows_platform_manager.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window manager for Windows
  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializePlatformFeatures();
  }

  Future<void> _initializePlatformFeatures() async {
    if (!Platform.isWindows) return;

    final platformManager = ref.read(windowsPlatformManagerProvider);

    await platformManager.initialize(
      context: context,
      appTitle: 'FengLing Music',
      onPlayPause: () {
        // Handle play/pause action
        // Get audio player service and toggle playback
      },
      onNext: () {
        // Handle next track
      },
      onPrevious: () {
        // Handle previous track
      },
      onExit: () {
        // Handle app exit
        exit(0);
      },
    );

    // Log screen info
    final screenInfo = platformManager.screenInfo;
    if (screenInfo != null) {
      print('Screen: ${screenInfo.refreshRate}Hz, '
            'Recommended FPS: ${platformManager.recommendedFrameRate}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FengLing Music',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}
```

### Default Hotkeys

The following hotkeys are registered by default:

- **Ctrl + Space**: Play/Pause
- **Ctrl + Right**: Next Track
- **Ctrl + Left**: Previous Track
- **Ctrl + Up**: Volume Up (optional)
- **Ctrl + Down**: Volume Down (optional)

### System Tray Menu

Default tray menu includes:
- Show Window
- Play/Pause
- Next Track
- Previous Track
- Exit

### Updating Tray Info Dynamically

```dart
// Update tray tooltip with current song
final platformManager = ref.read(windowsPlatformManagerProvider);
await platformManager.updateTrayTooltip('FengLing Music - Playing: Song Title');
```

### Custom Hotkey Registration

```dart
// Register custom hotkey
final hotkeyConfig = HotkeyConfig(
  action: HotkeyAction.playPause,
  modifiers: [KeyboardKey.control, KeyboardKey.shift],
  key: KeyboardKey.keyP,
  description: 'Custom Play/Pause',
);

await platformManager.registerHotkey(hotkeyConfig, () {
  // Handle hotkey press
});
```

## Assets Required

### Tray Icon
Create a Windows ICO file: `assets/icons/tray_icon.ico`

Recommended sizes:
- 16x16 pixels (most common)
- 32x32 pixels
- 48x48 pixels

Use a simple, clear icon that's visible at small sizes.

## Features Implemented

### ✅ TASK-111: System Tray Icon
- System tray icon display
- Tooltip on hover
- Right-click context menu
- Platform: Windows only

### ✅ TASK-112: Tray Menu
- Play/Pause control
- Next/Previous track
- Show main window
- Exit application

### ✅ TASK-113: Minimize to Tray
- Close button minimizes to tray
- Double-click tray icon shows window
- Configurable behavior

### ✅ TASK-114: Global Hotkey Registration
- System-wide hotkey support
- Ctrl+Space: Play/Pause
- Ctrl+Right: Next track
- Ctrl+Left: Previous track
- Platform: Windows only

### ✅ TASK-115: Hotkey Settings
- Custom hotkey configuration
- Hotkey conflict detection
- Hotkey display strings

### ⏳ TASK-116: Media Keys Support
- Keyboard media keys (Play, Pause, Next, Prev)
- Integrated with audio_service package
- Note: Requires audio_service configuration

### ⏳ TASK-117: Taskbar Integration
- Taskbar thumbnail toolbar
- Play state display
- Note: Requires additional Windows API integration via platform channels

### ✅ TASK-118: High Refresh Rate Display Detection
- Detects primary display properties
- Supports 90Hz, 120Hz, 144Hz, 165Hz
- Provides recommended frame rate
- Animation duration optimization

## Known Limitations

1. **Screen Refresh Rate Detection**: The `screen_retriever` package doesn't directly provide refresh rate. Current implementation uses fallback logic. For production, consider implementing native Windows API calls via platform channels.

2. **Tray Icon Format**: Requires Windows ICO format. PNG icons need conversion.

3. **Media Keys**: Full implementation requires audio_service background handler setup.

4. **Taskbar Thumbnails**: Advanced taskbar features require Windows API platform channel implementation.

## Testing

### Manual Testing Checklist
- [ ] System tray icon appears
- [ ] Tray menu items work
- [ ] Minimize to tray works
- [ ] Double-click tray shows window
- [ ] Global hotkeys respond
- [ ] High refresh rate detected (if available)
- [ ] Window close behavior correct

### Test on Windows 10/11
- Windows 10 (21H2 or later)
- Windows 11

## Future Enhancements

1. **Dynamic Icon Updates**: Change tray icon based on playback state
2. **Taskbar Progress**: Show playback progress in taskbar
3. **Jump List**: Quick actions in Windows jump list
4. **Toast Notifications**: Windows 10/11 native notifications
5. **Accurate Refresh Rate**: Native API integration

## References

- [system_tray package](https://pub.dev/packages/system_tray)
- [hotkey_manager package](https://pub.dev/packages/hotkey_manager)
- [window_manager package](https://pub.dev/packages/window_manager)
- [screen_retriever package](https://pub.dev/packages/screen_retriever)
