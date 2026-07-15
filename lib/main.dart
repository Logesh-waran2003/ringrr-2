import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ringrr/data/reminder_provider.dart';
import 'package:ringrr/data/reminder_state.dart';
import 'package:ringrr/screens/app_shell.dart';
import 'package:ringrr/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  final state = ReminderState();
  state.load();

  runApp(RingrrApp(state: state));
}

class RingrrApp extends StatelessWidget {
  final ReminderState state;

  const RingrrApp({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ReminderProvider(
      state: state,
      child: MaterialApp(
        title: 'Ringrr',
        theme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        home: const AppShell(),
      ),
    );
  }
}
