import 'package:day_night/models/enums.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../app_localizations.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class PriceRangeDialog extends StatefulWidget {
  const PriceRangeDialog({super.key});

  @override
  State<PriceRangeDialog> createState() => _PriceRangeDialogState();
}

class _PriceRangeDialogState extends State<PriceRangeDialog> {
  double? _rangeFromPrice;
  double? _rangeToPrice;
  final TextEditingController fromPriceController = TextEditingController();
  final TextEditingController toPriceController = TextEditingController();
  ValidCurrency selectedCurrency = ValidCurrency.ILS;

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
            controller: fromPriceController,
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
            onChanged: (value) {
              setState(() {
                _rangeFromPrice = double.tryParse(value);
              });
            },
          ),
          const SizedBox(height: 12),

          // To Price
          TextField(
            controller: toPriceController,
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
            onChanged: (value) {
              setState(() {
                _rangeToPrice = double.tryParse(value);
              });
            },
          ),
          const SizedBox(height: 20),

          // Currency selector
          DropdownButton2<ValidCurrency>(
            value: selectedCurrency,
            dropdownStyleData: DropdownStyleData(
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            style: const TextStyle(color: Colors.white),
            items: ValidCurrency.values.map((currency) {
              return DropdownMenuItem(
                value: currency,
                child: Text(
                  switch (currency) {
                    ValidCurrency.USD => AppLocalizations.of(context).get('USD'),
                    ValidCurrency.ILS => AppLocalizations.of(context).get('ILS'),
                    ValidCurrency.EUR => AppLocalizations.of(context).get('EUR'),
                    ValidCurrency.GBP => AppLocalizations.of(context).get('GBP'),
                  }
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedCurrency = value;
                });
              }
            },
          ),
          const SizedBox(height: 20),

          // Action Buttons
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
                      fromPriceController.clear();
                      toPriceController.clear();
                      selectedCurrency = ValidCurrency.ILS;
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
                  onPressed: (_rangeFromPrice != null && _rangeToPrice != null) 
                    ? () {
                        Navigator.pop(context, {
                          'min': _rangeFromPrice,
                          'max': _rangeToPrice,
                          'currency': selectedCurrency,
                        });
                      }
                    : null,
                  child: Text(
                    AppLocalizations.of(context).get('apply'),
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
    builder: (context) => const PriceRangeDialog(),
  );
}
