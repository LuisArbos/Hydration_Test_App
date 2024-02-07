import 'dart:io';
import 'package:ali_app/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) {
    WindowManager.instance.setMinimumSize(const Size(900, 800));
    WindowManager.instance.setMaximumSize(const Size(900, 800));
  }
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      home: HomePage(),

    );
  }
}
