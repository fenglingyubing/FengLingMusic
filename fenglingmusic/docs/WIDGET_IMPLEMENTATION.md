# TASK-124: Android Desktop Widget Implementation

## 概述
为FengLing Music创建Android桌面小部件，让用户可以在主屏幕直接控制音乐播放。

## 功能特性
- 显示当前播放歌曲信息（标题、艺术家）
- 显示专辑封面
- 播放控制按钮（播放/暂停、上一曲、下一曲）
- 点击跳转到应用

## 实现步骤

### 1. 创建Widget布局文件

需要在 `android/app/src/main/res/layout/` 目录创建以下文件：

**music_widget.xml** - 小部件主布局
```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:background="@drawable/widget_background"
    android:orientation="vertical"
    android:padding="8dp">

    <!-- Album Art and Info -->
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:gravity="center_vertical">

        <ImageView
            android:id="@+id/widget_album_art"
            android:layout_width="56dp"
            android:layout_height="56dp"
            android:scaleType="centerCrop"
            android:contentDescription="Album Art" />

        <LinearLayout
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:layout_marginStart="12dp"
            android:orientation="vertical">

            <TextView
                android:id="@+id/widget_song_title"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:text="Song Title"
                android:textSize="14sp"
                android:textColor="@android:color/white"
                android:maxLines="1"
                android:ellipsize="end" />

            <TextView
                android:id="@+id/widget_artist_name"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:text="Artist Name"
                android:textSize="12sp"
                android:textColor="@android:color/white"
                android:alpha="0.7"
                android:maxLines="1"
                android:ellipsize="end" />
        </LinearLayout>
    </LinearLayout>

    <!-- Control Buttons -->
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="8dp"
        android:orientation="horizontal"
        android:gravity="center">

        <ImageButton
            android:id="@+id/widget_btn_previous"
            android:layout_width="40dp"
            android:layout_height="40dp"
            android:background="?attr/selectableItemBackgroundBorderless"
            android:src="@android:drawable/ic_media_previous"
            android:contentDescription="Previous"
            android:tint="@android:color/white" />

        <ImageButton
            android:id="@+id/widget_btn_play_pause"
            android:layout_width="48dp"
            android:layout_height="48dp"
            android:layout_marginHorizontal="16dp"
            android:background="?attr/selectableItemBackgroundBorderless"
            android:src="@android:drawable/ic_media_play"
            android:contentDescription="Play/Pause"
            android:tint="@android:color/white" />

        <ImageButton
            android:id="@+id/widget_btn_next"
            android:layout_width="40dp"
            android:layout_height="40dp"
            android:background="?attr/selectableItemBackgroundBorderless"
            android:src="@android:drawable/ic_media_next"
            android:contentDescription="Next"
            android:tint="@android:color/white" />
    </LinearLayout>
</LinearLayout>
```

### 2. 创建Widget配置文件

在 `android/app/src/main/res/xml/` 目录创建 `music_widget_info.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider xmlns:android="http://schemas.android.com/apk/res/android"
    android:minWidth="250dp"
    android:minHeight="110dp"
    android:updatePeriodMillis="0"
    android:initialLayout="@layout/music_widget"
    android:resizeMode="horizontal|vertical"
    android:widgetCategory="home_screen"
    android:description="@string/widget_description" />
```

### 3. 创建Widget Provider类

在 `MainActivity.kt` 所在的包中创建 `MusicWidgetProvider.kt`:

```kotlin
package com.fenglingmusic.fenglingmusic

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.graphics.BitmapFactory
import java.io.File

class MusicWidgetProvider : AppWidgetProvider() {

    companion object {
        const val ACTION_PLAY_PAUSE = "com.fenglingmusic.ACTION_PLAY_PAUSE"
        const val ACTION_NEXT = "com.fenglingmusic.ACTION_NEXT"
        const val ACTION_PREVIOUS = "com.fenglingmusic.ACTION_PREVIOUS"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val views = RemoteViews(context.packageName, R.layout.music_widget)

        // Set click listeners for buttons
        views.setOnClickPendingIntent(
            R.id.widget_btn_play_pause,
            getPendingIntent(context, ACTION_PLAY_PAUSE)
        )
        views.setOnClickPendingIntent(
            R.id.widget_btn_next,
            getPendingIntent(context, ACTION_NEXT)
        )
        views.setOnClickPendingIntent(
            R.id.widget_btn_previous,
            getPendingIntent(context, ACTION_PREVIOUS)
        )

        // Set click listener to open app
        val launchIntent = context.packageManager
            .getLaunchIntentForPackage(context.packageName)
        val launchPendingIntent = PendingIntent.getActivity(
            context, 0, launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_album_art, launchPendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun getPendingIntent(context: Context, action: String): PendingIntent {
        val intent = Intent(context, MusicWidgetProvider::class.java).apply {
            this.action = action
        }
        return PendingIntent.getBroadcast(
            context, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        when (intent.action) {
            ACTION_PLAY_PAUSE -> {
                // Send to Flutter through method channel
                sendToFlutter(context, "playPause")
            }
            ACTION_NEXT -> {
                sendToFlutter(context, "next")
            }
            ACTION_PREVIOUS -> {
                sendToFlutter(context, "previous")
            }
        }
    }

    private fun sendToFlutter(context: Context, action: String) {
        // Implementation to communicate with Flutter
        // This would need to be integrated with the audio service
    }
}
```

### 4. 在AndroidManifest.xml中注册Widget

在 `<application>` 标签内添加：

```xml
<!-- Desktop Widget -->
<receiver
    android:name=".MusicWidgetProvider"
    android:exported="false">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
        <action android:name="com.fenglingmusic.ACTION_PLAY_PAUSE" />
        <action android:name="com.fenglingmusic.ACTION_NEXT" />
        <action android:name="com.fenglingmusic.ACTION_PREVIOUS" />
    </intent-filter>
    <meta-data
        android:name="android.appwidget.provider"
        android:resource="@xml/music_widget_info" />
</receiver>
```

### 5. Flutter端集成

创建 `lib/services/platform/widget_service.dart`:

```dart
import 'package:flutter/services.dart';

class WidgetService {
  static const MethodChannel _channel = MethodChannel('com.fenglingmusic/widget');

  /// 更新桌面小部件显示
  Future<void> updateWidget({
    required String title,
    required String artist,
    required bool isPlaying,
    String? albumArtPath,
  }) async {
    try {
      await _channel.invokeMethod('updateWidget', {
        'title': title,
        'artist': artist,
        'isPlaying': isPlaying,
        'albumArtPath': albumArtPath,
      });
    } catch (e) {
      print('Error updating widget: $e');
    }
  }
}
```

## 注意事项

1. **权限**: 确保AndroidManifest.xml中已添加必要权限
2. **图标资源**: 需要准备相应的图标资源文件
3. **背景**: 需要创建widget_background drawable资源
4. **测试**: 在不同Android版本和屏幕尺寸上测试
5. **性能**: Widget更新不应过于频繁，避免耗电

## 当前状态

✅ 基础框架文档已创建
⏳ 需要完整实现XML布局文件
⏳ 需要完整实现Kotlin Provider类
⏳ 需要与audio_service集成
⏳ 需要测试和优化

## 后续步骤

由于桌面小部件的完整实现需要大量的Android原生代码和资源文件，建议：
1. 先完成核心播放功能的测试
2. 在后续版本中完善桌面小部件功能
3. 参考上述文档逐步实现各个组件
