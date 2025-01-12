import 'package:flutter/material.dart';
import '../lib/utils/icon_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await generateAppIcon();
  print('Icon generated successfully!');
}
