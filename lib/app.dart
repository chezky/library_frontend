import 'package:flutter/material.dart';
import 'package:library_frontend/home.dart';
import 'package:library_frontend/splash.dart';

class Library extends StatefulWidget {
  const Library({Key? key}) : super(key: key);

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {

  @override
  Widget build(BuildContext build) {
    return MaterialApp(
      home: const Splash(),
      debugShowCheckedModeBanner: false,
      theme: _lightTheme(),
    );
  }
}

ThemeData _lightTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    backgroundColor: Colors.green[50],
    scaffoldBackgroundColor: Colors.green[50],
    dialogBackgroundColor: Colors.green[100],
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: Colors.greenAccent[700],
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(
        color: (Colors.green[900])!,
      ),
      filled: true,
      fillColor: Colors.greenAccent[100]?.withOpacity(0.3),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        borderSide: BorderSide(
          color: (Colors.green[400])!,
          style: BorderStyle.solid,
          width: 0.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(
          color: (Colors.greenAccent[700])!,
          width: 1.4,
        ),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return (Colors.green[400])!; // Use the component's default.
          }
          return (Colors.grey[500])!; // Use the component's default.
        },
      ),
      trackColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return (Colors.greenAccent[100])!; // Use the component's default.
          }
          return (Colors.grey[300])!; // Use the component's default.
        },
      ),
    ),
  );
}