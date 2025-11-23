import 'package:flutter/material.dart';

class MyAppTheme extends InheritedWidget {
  final void Function(bool dark) toggleTheme;
  final void Function(Locale? locale) changeLocale;

  const MyAppTheme({
    super.key,
    required this.toggleTheme,
    required this.changeLocale,
    required super.child,
  });

  static MyAppTheme? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MyAppTheme>();

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
