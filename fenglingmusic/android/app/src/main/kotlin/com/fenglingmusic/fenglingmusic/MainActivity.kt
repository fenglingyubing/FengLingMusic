package com.fenglingmusic.fenglingmusic

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioManager
import android.os.Build
import android.os.Bundle
import android.view.Display
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * TASK-125, TASK-126, TASK-127: Android Platform Integration
 *
 * Provides:
 * - Headphone event listening (plug/unplug, button press)
 * - Audio focus management
 * - Refresh rate detection and optimization
 */
class MainActivity : FlutterActivity() {
    private val HEADPHONE_CHANNEL = "com.fenglingmusic/headphone"
    private val REFRESH_RATE_CHANNEL = "com.fenglingmusic/refresh_rate"

    private var headphoneReceiver: HeadphoneReceiver? = null
    private var headphoneChannel: MethodChannel? = null
    private var refreshRateChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Setup headphone event channel
        headphoneChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, HEADPHONE_CHANNEL)
        headphoneChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "startListening" -> {
                    startHeadphoneListener()
                    result.success(null)
                }
                "stopListening" -> {
                    stopHeadphoneListener()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // Setup refresh rate channel
        refreshRateChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, REFRESH_RATE_CHANNEL)
        refreshRateChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getRefreshRate" -> {
                    val refreshRate = getRefreshRate()
                    result.success(refreshRate)
                }
                "getSupportedRefreshRates" -> {
                    val rates = getSupportedRefreshRates()
                    result.success(rates)
                }
                "setPreferredRefreshRate" -> {
                    val targetRate = call.argument<Double>("refreshRate")
                    if (targetRate != null) {
                        val success = setPreferredRefreshRate(targetRate.toFloat())
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGUMENT", "refreshRate is required", null)
                    }
                }
                "resetRefreshRate" -> {
                    resetRefreshRate()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Enable high refresh rate support
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            window.attributes = window.attributes.apply {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    preferredDisplayModeId = getHighestRefreshRateModeId()
                }
            }
        }
    }

    // ========== TASK-125, TASK-126: Headphone Event Listening ==========

    private fun startHeadphoneListener() {
        if (headphoneReceiver == null) {
            headphoneReceiver = HeadphoneReceiver(headphoneChannel)
            val filter = IntentFilter().apply {
                addAction(Intent.ACTION_HEADSET_PLUG)
                addAction(AudioManager.ACTION_AUDIO_BECOMING_NOISY)
                addAction(Intent.ACTION_MEDIA_BUTTON)
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(headphoneReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
            } else {
                registerReceiver(headphoneReceiver, filter)
            }
        }
    }

    private fun stopHeadphoneListener() {
        headphoneReceiver?.let {
            unregisterReceiver(it)
            headphoneReceiver = null
        }
    }

    // ========== TASK-127: Refresh Rate Optimization ==========

    private fun getRefreshRate(): Double {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            display?.mode?.refreshRate?.toDouble() ?: 60.0
        } else {
            @Suppress("DEPRECATION")
            display?.refreshRate?.toDouble() ?: 60.0
        }
    }

    private fun getSupportedRefreshRates(): List<Double> {
        val rates = mutableSetOf<Double>()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            display?.supportedModes?.forEach { mode ->
                rates.add(mode.refreshRate.toDouble())
            }
        } else {
            // Fallback for older devices
            rates.add(60.0)
        }

        return rates.sorted()
    }

    private fun setPreferredRefreshRate(refreshRate: Float): Boolean {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                val targetMode = display?.supportedModes?.minByOrNull {
                    kotlin.math.abs(it.refreshRate - refreshRate)
                }

                if (targetMode != null) {
                    window.attributes = window.attributes.apply {
                        preferredDisplayModeId = targetMode.modeId
                    }
                    true
                } else {
                    false
                }
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                window.attributes = window.attributes.apply {
                    preferredRefreshRate = refreshRate
                }
                true
            } else {
                false
            }
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun resetRefreshRate() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            window.attributes = window.attributes.apply {
                preferredRefreshRate = 0f
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    preferredDisplayModeId = 0
                }
            }
        }
    }

    private fun getHighestRefreshRateModeId(): Int {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val highestMode = display?.supportedModes?.maxByOrNull { it.refreshRate }
            return highestMode?.modeId ?: 0
        }
        return 0
    }

    override fun onDestroy() {
        super.onDestroy()
        stopHeadphoneListener()
    }

    // ========== Headphone Broadcast Receiver ==========

    inner class HeadphoneReceiver(private val channel: MethodChannel?) : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                Intent.ACTION_HEADSET_PLUG -> {
                    val state = intent.getIntExtra("state", -1)
                    when (state) {
                        0 -> {
                            // Headphone unplugged
                            channel?.invokeMethod("onHeadphoneUnplugged", null)
                        }
                        1 -> {
                            // Headphone plugged
                            channel?.invokeMethod("onHeadphonePlugged", null)
                        }
                    }
                }

                AudioManager.ACTION_AUDIO_BECOMING_NOISY -> {
                    // Audio is about to become noisy (headphones unplugged)
                    channel?.invokeMethod("onHeadphoneUnplugged", null)
                }

                Intent.ACTION_MEDIA_BUTTON -> {
                    // Media button pressed (headphone button)
                    // Note: This is handled by audio_service, but we keep it for completeness
                    channel?.invokeMethod("onHeadphoneButtonPressed", 1)
                }
            }
        }
    }
}
