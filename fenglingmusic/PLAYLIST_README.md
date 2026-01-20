# Playlist Feature - Neo-Vinyl Design

## Overview

The playlist feature implements a **Neo-Vinyl** aesthetic that combines brutalist geometric clarity with the warmth of vintage album artwork. It's designed to make music collection management feel alive and expressive, not just functional.

## Features Implemented

### ✅ TASK-046: Playlist Page
- Grid layout with animated playlist cards
- Bold typography with Archivo Black font
- Warm gradient backgrounds inspired by vinyl labels
- Staggered entry animations (120fps optimized)
- Create/delete playlist actions
- Empty state with encouraging messaging

### ✅ TASK-047: Playlist Detail Page
- Hero animation transition from grid
- Large cover image display
- Drag-to-reorder song list (edit mode)
- Song metadata display
- Empty state handling

### ✅ TASK-048: Playlist Editing
- Toggle edit mode
- Drag handles for reordering
- Remove songs from playlist
- Visual feedback on hover/interaction
- Smooth animations for all actions

### ✅ TASK-049 & TASK-050: M3U Export/Import
- Export playlists to M3U8 format with EXTINF metadata
- Import M3U/M3U8 files
- File picker integration
- Success/error notifications

## Design System

### Typography
- **Headings**: Archivo Black (bold, geometric, impactful)
- **Body**: Inter (clean, readable, modern)
- **Letter spacing**: Generous for headings, normal for body

### Color Palette
- **Background**: Deep blues (#1a1a2e, #16213e, #0f3460)
- **Primary**: Vibrant pink-red (#e94560, #ff6b9d)
- **Accents**: Various gradients for playlist variety
- **Text**: White with varying opacity for hierarchy

### Animations (120fps)
- **Staggered entry**: Cards animate in sequence (80ms delay each)
- **Scale & slide**: Combined transforms for depth
- **Hover states**: Subtle scale (1.05x) with easing
- **Transitions**: Cubic easing for smoothness

## File Structure

```
lib/
├── presentation/
│   ├── pages/
│   │   └── playlist/
│   │       ├── playlist_page.dart          # Main playlist grid view
│   │       └── playlist_detail_page.dart   # Detail with drag-to-reorder
│   ├── widgets/
│   │   ├── playlist_card.dart              # Animated playlist card
│   │   └── song_tile_draggable.dart        # Draggable song list item
│   ├── dialogs/
│   │   └── create_playlist_dialog.dart     # Create/edit dialog
│   └── providers/
│       └── playlist_provider.dart          # Riverpod state management
├── services/
│   └── playlist/
│       └── m3u_service.dart                # M3U export/import logic
└── data/
    ├── models/
    │   └── playlist_model.dart             # Data models
    └── repositories/
        └── playlist_repository_impl.dart    # Data access
```

## Setup Instructions

### 1. Add Custom Fonts

Download and add these fonts to your project:

**Archivo Black** (headers):
- Download from [Google Fonts](https://fonts.google.com/specimen/Archivo+Black)
- Place in `assets/fonts/ArchivoBlack-Regular.ttf`

**Inter** (body):
- Download from [Google Fonts](https://fonts.google.com/specimen/Inter)
- Place variable font or weights 400, 500, 600, 700 in `assets/fonts/`

### 2. Update pubspec.yaml

Add fonts section:

```yaml
flutter:
  uses-material-design: true

  fonts:
    - family: Archivo Black
      fonts:
        - asset: assets/fonts/ArchivoBlack-Regular.ttf
          weight: 900

    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
          weight: 400
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
```

### 3. Install Dependencies

All required dependencies are already in pubspec.yaml:
- `flutter_riverpod: ^2.4.0` - State management
- `file_picker: ^6.1.1` - File selection
- `path: ^1.8.3` - Path manipulation
- `flutter_animate: ^4.3.0` - Animations

Run:
```bash
flutter pub get
```

### 4. Navigation Integration

Add playlist page to your app's navigation:

```dart
// In your main navigation/router
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const PlaylistPage()),
);
```

## Usage

### Creating a Playlist

1. Tap the "CREATE" FAB button
2. Enter playlist name (required)
3. Add description (optional)
4. Select cover image (optional)
5. Tap "CREATE"

### Managing Playlists

- **View**: Tap any playlist card to see details
- **Delete**: Hover over card, click delete icon
- **Edit**: In detail view, tap "EDIT" to enable drag-to-reorder

### Export/Import

**Export:**
1. Open playlist detail page
2. Tap "EXPORT" button
3. Select destination folder
4. M3U8 file is created with metadata

**Import:**
1. Open playlist detail page
2. Tap "IMPORT" button
3. Select M3U/M3U8 file
4. Songs are matched and added

## Performance Optimization

All animations are optimized for 120fps:

- **RepaintBoundary**: Used on cards to isolate repaints
- **Const constructors**: Minimize rebuilds
- **AnimationController**: Hardware-accelerated transforms
- **Staggered loading**: Prevents jank on large lists
- **Image caching**: File images cached automatically

## Accessibility

- Semantic labels on all interactive elements
- Keyboard navigation support (desktop)
- High contrast text (WCAG AA compliant)
- Clear visual feedback on all actions

## Future Enhancements

- [ ] Playlist cover art generation from song covers
- [ ] Smart playlists (auto-populate by criteria)
- [ ] Playlist sharing (export as shareable link)
- [ ] Collaborative playlists
- [ ] Playlist analytics (most played, skip rate, etc.)
- [ ] Batch operations (merge, split playlists)

## Troubleshooting

**Fonts not loading:**
- Ensure font files are in `assets/fonts/` directory
- Verify pubspec.yaml fonts section is correctly indented
- Run `flutter clean && flutter pub get`

**Animations laggy:**
- Check device refresh rate settings
- Disable debug mode overlays
- Profile with Flutter DevTools

**M3U import not working:**
- Verify M3U file format (plain text)
- Check file paths in M3U match actual file locations
- Ensure songs exist in database

## Credits

**Design Philosophy**: Neo-Vinyl aesthetic
**Fonts**: Archivo Black, Inter (Google Fonts)
**Color Inspiration**: Vintage vinyl labels, 1970s album art
**Animation Style**: Rhythmic, musical motion with weight and bounce

---

Built with ❤️ for music lovers who appreciate beautiful design.
