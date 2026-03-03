import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../theme.dart';

class FormatScreen extends StatefulWidget {
  final String selectedFormat;

  const FormatScreen({super.key, required this.selectedFormat});

  @override
  State<FormatScreen> createState() => _FormatScreenState();
}

class _FormatScreenState extends State<FormatScreen> {
  late String _selected;

  static const _formats = [
    'Years',
    'Months',
    'Weeks',
    'Days',
    'Hours, minutes and seconds',
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedFormat;
  }

  void _select(String format) {
    setState(() => _selected = format);
    StorageService.saveTimeFormat(format);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _selected);
      },
      child: Scaffold(
        backgroundColor: kBgWhite,
        appBar: AppBar(
          backgroundColor: kBgWhite,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: kTextPrimary),
            onPressed: () => Navigator.pop(context, _selected),
          ),
          title: const Text(
            'Format',
            style: TextStyle(
              color: kTextPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Column(
          children: [
            const Divider(height: 1, color: kDivider),
            const SizedBox(height: 16),
            // 2-column grid for Years, Months, Weeks, Days
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildFormatTile('Years'),
                      const SizedBox(width: 12),
                      _buildFormatTile('Months'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildFormatTile('Weeks'),
                      const SizedBox(width: 12),
                      _buildFormatTile('Days'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Full-width tile for Hours, minutes and seconds
                  _buildFormatTileWide('Hours, minutes and seconds'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatTile(String format) {
    final isSelected = _selected == format;
    return Expanded(
      child: GestureDetector(
        onTap: () => _select(format),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: kCardLightAlt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  format,
                  style: const TextStyle(
                    color: kTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildCheckbox(isSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatTileWide(String format) {
    final isSelected = _selected == format;
    return GestureDetector(
      onTap: () => _select(format),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: kCardLightAlt,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                format,
                style: const TextStyle(
                  color: kTextPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildCheckbox(isSelected),
        ],
      ),
    );
  }

  Widget _buildCheckbox(bool isSelected) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isSelected ? kTextSecondary : Colors.transparent,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: isSelected ? kTextSecondary : kTextTertiary,
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : null,
    );
  }
}
