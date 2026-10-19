import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/l10n.dart';

/// Parses user input; accepts Bangla digits as well as a comma decimal.
double? parseAmount(String text) {
  const bn = '০১২৩৪৫৬৭৮৯';
  final buf = StringBuffer();
  for (final ch in text.trim().replaceAll(',', '.').split('')) {
    final i = bn.indexOf(ch);
    buf.write(i >= 0 ? '$i' : ch);
  }
  return double.tryParse(buf.toString());
}

/// Number without a useless trailing ".0".
String compactNumber(double v) => v == v.truncateToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

final _amountFormatter = FilteringTextInputFormatter.allow(RegExp(r'[0-9০-৯.,\-]'));

/// Big numeric field with − / + buttons, built for quick data entry.
class AmountStepper extends StatelessWidget {
  final TextEditingController controller;
  final double step;
  final bool enabled;
  final bool allowNegative;
  final VoidCallback? onChanged;
  final bool autofocus;
  final String? hint;

  const AmountStepper({
    super.key,
    required this.controller,
    this.step = 1,
    this.enabled = true,
    this.allowNegative = true,
    this.onChanged,
    this.autofocus = false,
    this.hint,
  });

  void _bump(double delta) {
    HapticFeedback.selectionClick();
    var v = (parseAmount(controller.text) ?? 0) + delta;
    if (!allowNegative && v < 0) v = 0;
    controller.text = v == 0 ? '' : compactNumber(v);
    controller.selection = TextSelection.collapsed(offset: controller.text.length);
    onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget btn(IconData icon, double delta) => IconButton.filledTonal(
          onPressed: enabled ? () => _bump(delta) : null,
          icon: Icon(icon),
          style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
        );

    return Row(
      children: [
        btn(Icons.remove, -step),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            enabled: enabled,
            autofocus: autofocus,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: scheme.onSurface),
            keyboardType: TextInputType.numberWithOptions(decimal: true, signed: allowNegative),
            inputFormatters: [_amountFormatter],
            decoration: InputDecoration(hintText: hint ?? '0', isDense: true),
            onChanged: (_) => onChanged?.call(),
          ),
        ),
        const SizedBox(width: 8),
        btn(Icons.add, step),
      ],
    );
  }
}

/// Day / Night picker.
class ShiftSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const ShiftSelector({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(value: 'Day', icon: const Icon(Icons.wb_sunny_outlined), label: Text(context.l10n.shiftDay)),
        ButtonSegment(value: 'Night', icon: const Icon(Icons.nightlight_outlined), label: Text(context.l10n.shiftNight)),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

/// Tappable date pill used on entry forms.
class DateChip extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;
  const DateChip({super.key, required this.date, required this.onChanged});

  bool get _isToday {
    final n = DateTime.now();
    return n.year == date.year && n.month == date.month && n.day == date.day;
  }

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(Icons.calendar_today, size: 18),
      label: Text(_isToday ? '${context.l10n.today} • ${context.date(date)}' : context.date(date)),
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) onChanged(picked);
      },
    );
  }
}

/// Coloured circular icon used in cards and headers.
class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const IconBadge({super.key, required this.icon, required this.color, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(size / 3)),
      child: Icon(icon, color: color, size: size * 0.54),
    );
  }
}

/// Shows a modal bottom sheet that grows with the keyboard.
Future<T?> showEntrySheet<T>(BuildContext context, WidgetBuilder builder) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: builder(ctx),
      ),
    ),
  );
}

/// Fixed colour per product type so Pani / 1 No / 2 No / 3 No are easy to tell apart.
Color productColor(String type) => switch (type) {
      'Pani' => Colors.blue,
      '1 No' => Colors.orange,
      '2 No' => Colors.green,
      '3 No' => Colors.purple,
      _ => Colors.grey,
    };
