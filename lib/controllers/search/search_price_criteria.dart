import 'package:day_night/models/enums.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../app_localizations.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CustomRangePricePicker extends StatefulWidget {
  const CustomRangePricePicker({super.key});

  @override
  State<CustomRangePricePicker> createState() => _CustomRangePricePickerState();
}

class _CustomRangePricePickerState extends State<CustomRangePricePicker> {
  double? _rangeFromPrice;
  double? _rangeToPrice;
  final TextEditingController fromPriceController = TextEditingController();
  final TextEditingController toPriceController = TextEditingController();
  ValidCurrency selectedCurrency = ValidCurrency.ILS; // default

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).get('filter-by-price'),
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 20),

          // From Price
          TextField(
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).get('from-price'),
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: const BorderSide(color: Colors.blueAccent),
              ),
            ),
            onChanged: (value) => setState(() {
              _rangeFromPrice = double.tryParse(value);
            }),
          ),
          const SizedBox(height: 12),

          // To Price
          TextField(
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).get('to-price'),
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: const BorderSide(color: Colors.blueAccent),
              ),
            ),
            onChanged: (value) => setState(() {
              _rangeToPrice = double.tryParse(value);
            }),
          ),
          const SizedBox(height: 12),

          // Currency Dropdown
          DropdownButtonFormField2<ValidCurrency>(
            value: selectedCurrency,
            dropdownStyleData: DropdownStyleData(
              maxHeight: 200,
              width:
                  MediaQuery.of(context).size.width * 0.8, // 👈 80% of screen
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            style: const TextStyle(color: Colors.white),
            items: ValidCurrency.values.map((currency) {
              return DropdownMenuItem(
                value: currency,
                child: Text(currency.symbol(context)),
              );
            }).toList(),
            onChanged: (value) => setState(() {
              selectedCurrency = value!;
            }),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).get('currency-option'),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: const BorderSide(color: Colors.white24),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Buttons Row
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _rangeFromPrice = null;
                      _rangeToPrice = null;
                      selectedCurrency = ValidCurrency.ILS; // reset to default
                    });
                  },
                  child: Text(
                    AppLocalizations.of(context).get('clear'),
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBrandPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, {
                      "range": {
                        "start": _rangeFromPrice ?? 0.0,
                        "end": _rangeToPrice ?? double.infinity,
                        "currency": selectedCurrency,
                      }
                    });
                  },
                  child: Text(
                    AppLocalizations.of(context).get('search'),
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<Map<String, Object?>?> showCustomPriceRangePicker(
  BuildContext context,
) async {
  return await showModalBottomSheet<Map<String, Object?>>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const CustomRangePricePicker(),
  );
}

extension ValidCurrencyExt on ValidCurrency {
  String symbol(BuildContext context) {
    switch (this) {
      case ValidCurrency.USD:
        return AppLocalizations.of(context).get('USD');
      case ValidCurrency.ILS:
        return AppLocalizations.of(context).get('ILS');
      case ValidCurrency.EUR:
        return AppLocalizations.of(context).get('EUR');
      case ValidCurrency.GBP:
        return AppLocalizations.of(context).get('GBP');
    }
  }
}
