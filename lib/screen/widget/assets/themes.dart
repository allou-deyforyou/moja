import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '_assets.dart';

class AppThemes {
  static const primaryColor = CupertinoColors.systemCyan; // Color(0xFF000000);

  static const _floatingActionButtonTheme = FloatingActionButtonThemeData(
    shape: StadiumBorder(),
    elevation: 0.0,
  );
  static const _bottomSheetTheme = BottomSheetThemeData(
    clipBehavior: Clip.antiAlias,
    elevation: 2.0,
  );
  static const _dividerTheme = DividerThemeData(
    space: 0.8,
    thickness: 0.8,
  );
  static final _filledButtonTheme = FilledButtonThemeData(
    style: FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 12.0),
    ),
  );
  static const _inputDecorationTheme = InputDecorationTheme(
    filled: true,
    isDense: true,
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.all(Radius.circular(26.0)),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    floatingLabelBehavior: FloatingLabelBehavior.always,
  );
  static const _listTileTheme = ListTileThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
    visualDensity: VisualDensity(
      horizontal: VisualDensity.minimumDensity,
      vertical: VisualDensity.minimumDensity,
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
  );

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        dividerTheme: _dividerTheme,
        fontFamily: FontFamily.futura,
        listTileTheme: _listTileTheme,
        bottomSheetTheme: _bottomSheetTheme,
        filledButtonTheme: _filledButtonTheme,
        inputDecorationTheme: _inputDecorationTheme,
        floatingActionButtonTheme: _floatingActionButtonTheme,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: primaryColor,
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        dividerTheme: _dividerTheme,
        fontFamily: FontFamily.futura,
        listTileTheme: _listTileTheme,
        bottomSheetTheme: _bottomSheetTheme,
        filledButtonTheme: _filledButtonTheme,
        inputDecorationTheme: _inputDecorationTheme,
        floatingActionButtonTheme: _floatingActionButtonTheme,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: primaryColor,
        ),
      );
}
