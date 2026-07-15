import 'package:flutter/services.dart';

class AlarmRinger {
  static const _channel = MethodChannel('com.logesh.ringrr/alarm_ringer');

  static Future<void> start() async {
    await _channel.invokeMethod('startRinging');
  }

  static Future<void> stop() async {
    await _channel.invokeMethod('stopRinging');
  }
}
