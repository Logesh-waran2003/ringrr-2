package com.logesh.ringrr

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.logesh.ringrr/alarm_ringer"
    private var pendingAlarmReminderId: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startRinging" -> {
                    AlarmRinger.start(applicationContext)
                    result.success(null)
                }
                "stopRinging" -> {
                    AlarmRinger.stop()
                    result.success(null)
                }
                "stopForegroundAlarm" -> {
                    AlarmForegroundService.stop(applicationContext)
                    result.success(null)
                }
                "getPendingAlarmId" -> {
                    result.success(pendingAlarmReminderId)
                    pendingAlarmReminderId = null
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleAlarmIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleAlarmIntent(intent)
    }

    private fun handleAlarmIntent(intent: Intent?) {
        val reminderId = intent?.getStringExtra("alarm_reminder_id")
        if (reminderId != null && reminderId.isNotEmpty()) {
            pendingAlarmReminderId = reminderId
            // If Flutter engine is ready, invoke immediately
            flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                MethodChannel(messenger, CHANNEL).invokeMethod("alarmFired", reminderId)
            }
        }
    }
}
