import 'package:flutter/material.dart';

class CategoryListItem extends StatelessWidget {
  final String name;
  final int count;
  final double amount;
  final String icon;
  final Color color;
  final double total;
  final double maxAmount;
  final bool isExpense;
  final VoidCallback? onTap;

  const CategoryListItem({
    super.key,
    required this.name,
    required this.count,
    required this.amount,
    required this.icon,
    required this.color,
    required this.total,
    required this.maxAmount,
    this.isExpense = true,
    this.onTap,
  });

  double get _pct => total > 0 ? (amount / total) * 100 : 0;
  double get _barRatio => maxAmount > 0 ? (amount / maxAmount).clamp(0.0, 1.0) : 0;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(icon, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: RichText(
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF263238),
                            ),
                            children: [
                              TextSpan(text: name),
                              TextSpan(
                                text: ' ($count)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF90A4AE),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_fmtAmount(amount)} ${isExpense ? '−' : '+'}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                          color: isExpense ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Progress bar
                  SizedBox(
                    height: 22,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFECEFF1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: _barRatio,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color, color.withOpacity(0.8)],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            '${_pct.toStringAsFixed(2)} %',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _barRatio > 0.5 ? Colors.white : const Color(0xFF546E7A),
                              shadows: _barRatio > 0.5
                                  ? const [Shadow(blurRadius: 2, color: Colors.black26)]
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
