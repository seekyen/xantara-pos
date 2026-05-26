import 'package:flutter/material.dart';

enum AppLayout { mobile, tablet, desktop }

AppLayout getLayout(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width >= 1024) return AppLayout.desktop;
  if (width >= 600) return AppLayout.tablet;
  return AppLayout.mobile;
}
