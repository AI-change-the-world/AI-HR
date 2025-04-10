import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/app.dart';
import 'package:toastification/toastification.dart';

void main() {
  runApp(
    ToastificationWrapper(
      child: ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0D6EFD),
              brightness: Brightness.light,
            ),
          ),
          home: App(),
        ),
      ),
    ),
  );
}
