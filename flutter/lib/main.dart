import 'package:flutter/material.dart';
import 'theme/xantara_theme.dart';
import 'screens/login_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/pos_screen.dart';

/// Preview harness for the 1a ("Refined Material") redesign. Swap the
/// `home:` widget to jump straight to a given screen while reviewing.
void main() {
  runApp(const XantaraPreviewApp());
}

class XantaraPreviewApp extends StatelessWidget {
  const XantaraPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xantara POS — Redesign Preview',
      debugShowCheckedModeBanner: false,
      theme: buildXantaraTheme(),
      home: const _ScreenPicker(),
    );
  }
}

class _ScreenPicker extends StatefulWidget {
  const _ScreenPicker();
  @override
  State<_ScreenPicker> createState() => _ScreenPickerState();
}

class _ScreenPickerState extends State<_ScreenPicker> {
  int _index = 1;

  static const _screens = [LoginScreen(), AdminDashboardScreen(), PosScreen()];
  static const _labels = ['Login', 'Dashboard', 'POS'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      floatingActionButton: Wrap(
        spacing: 8,
        children: [
          for (int i = 0; i < _labels.length; i++)
            FloatingActionButton.small(
              heroTag: _labels[i],
              onPressed: () => setState(() => _index = i),
              backgroundColor: i == _index ? XantaraColors.primary : Colors.white,
              child: Text(_labels[i][0], style: TextStyle(color: i == _index ? Colors.white : XantaraColors.gray600)),
            ),
        ],
      ),
    );
  }
}
