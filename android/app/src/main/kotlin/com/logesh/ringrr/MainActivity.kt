package com.logesh.ringrr

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.logesh.ringrr/alarm_ringer"

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
                else -> result.notImplemented()
            }
        }
    }
}
