import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  void useSystem() => emit(ThemeMode.system);
  void useLight() => emit(ThemeMode.light);
  void useDark() => emit(ThemeMode.dark);

  void toggle(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    emit(brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
  }
}
