import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maa_printing/l10n/l10n.dart';
import 'package:maa_printing/theme/app_theme.dart';
import 'package:maa_printing/theme/app_widgets.dart';

void main() {
  for (final size in const [Size(320, 640), Size(411, 891), Size(800, 1280)]) {
    for (final scale in const [1.0, 1.3]) {
      testWidgets('entry widgets fit $size @ $scale', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          theme: AppTheme.light(),
          builder: (c, child) => MediaQuery(
              data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)), child: child!),
          home: Scaffold(
            body: ListView(padding: const EdgeInsets.all(16), children: [
              AmountStepper(controller: TextEditingController(text: '12345.5')),
              Builder(builder: (c) => ShiftSelector(value: 'Day', onChanged: (_) {})),
              Builder(builder: (c) => DateChip(date: DateTime.now(), onChanged: (_) {})),
            ]),
          ),
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
