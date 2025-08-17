import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../app_localizations.dart';

class CustomRangePricePicker extends StatefulWidget {
  const CustomRangePricePicker({super.key});
  
  @override
  State<CustomRangePricePicker> createState() => _CustomRangePricePickerState();
}

class _CustomRangePricePickerState extends State<CustomRangePricePicker> {
  double? _rangeFromPrice;
  double? _rangeToPrice;

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
        children: [
          Text(
            AppLocalizations.of(context).get('filter-by-price'),
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    setState(() {
                      _rangeFromPrice = null;
                      _rangeToPrice = null;
                    });
                  },
                  child: Text(
                    AppLocalizations.of(context).get('clear'),
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBrandPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context, {
                      "start": _rangeFromPrice,
                      "end": _rangeToPrice,
                    });
                  },
                  child: Text(
                    AppLocalizations.of(context).get('search'),
                    style: TextStyle(color: Colors.white, fontSize: 18),
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

Future<Map<String, double?>?> showCustomPriceRangePicker(BuildContext context) async {
  return await showModalBottomSheet<Map<String, double?>>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const CustomRangePricePicker(),
  );
}