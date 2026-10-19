import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String get _locale => Localizations.localeOf(this).languageCode;

  /// ৳1,23,456.00 — Bangla digits when the app is in Bangla.
  String money(num value) => '৳${NumberFormat('#,##,##0.00', _locale).format(value)}';

  /// Plain number with [decimals] places, localized digits.
  String number(num value, [int decimals = 2]) =>
      NumberFormat.decimalPatternDigits(locale: _locale, decimalDigits: decimals).format(value);

  String date(DateTime d) => DateFormat('dd/MM/yyyy', _locale).format(d);

  String dateTime(DateTime d) => DateFormat('dd/MM/yyyy h:mm a', _locale).format(d);

  String time(DateTime d) => DateFormat('h:mm a', _locale).format(d);
}

/// Firestore stores these values in English; these map them to display labels only.
extension DataLabelsX on AppLocalizations {
  String role(String role) => switch (role.toLowerCase()) {
        'owner' => roleOwner,
        'admin' => roleAdmin,
        'editor' => roleEditor,
        _ => role,
      };

  String productType(String type) => switch (type) {
        'Pani' => typePani,
        '1 No' => type1No,
        '2 No' => type2No,
        '3 No' => type3No,
        _ => type,
      };

  String operation(String op) => switch (op) {
        'Blowing' => opBlowing,
        'Cutting' => opCutting,
        'Wastage' => opWastage,
        'Add' => opAdd,
        'Subtract' => opSubtract,
        _ => op,
      };

  String shiftName(String shift) => switch (shift) {
        'Day' => shiftDay,
        'Night' => shiftNight,
        _ => shift,
      };

  String category(String cat) => switch (cat) {
        'Boro' => catBoro,
        'Choto' => catChoto,
        _ => cat,
      };

  String unit(String unit) => switch (unit) {
        'KG' => unitKg,
        'Bundle' => unitBundle,
        _ => unit,
      };
}
