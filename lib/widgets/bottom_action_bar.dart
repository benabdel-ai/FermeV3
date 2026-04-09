import 'package:flutter/material.dart';

class BottomActionBar extends StatelessWidget {
  final double total;
  final String currency;
  final VoidCallback? onChartTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onSortTap;

  const BottomActionBar({
    super.key,
    required this.total,
    required this.currency,
    this.onChartTap,
    this.onShareTap,
    this.onSortTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFECEFF1), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _ActionButton(icon: Icons.pie_chart_outline, onTap: onChartTap),
            const SizedBox(width: 8),
            _ActionButton(icon: Icons.share_outlined, onTap: onShareTap),
            const SizedBox(width: 8),
            _ActionButton(icon: Icons.sort, onTap: onSortTap),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _fmtAmount(total),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                    color: Color(0xFF263238),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Calculé avec: $currency',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF90A4AE)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmtAmount(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]}.',
    );
    return '$intPart,${parts[1]}';
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFB0BEC5), width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF546E7A)),
      ),
    );
  }
}
