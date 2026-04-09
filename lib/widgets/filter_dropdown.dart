import 'package:flutter/material.dart';

class FilterDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final Alignment alignment;

  const FilterDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.alignment = Alignment.centerLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF4FC3F7), width: 2),
        ),
      ),
      child: PopupMenuButton<String>(
        onSelected: onChanged,
        offset: const Offset(0, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        itemBuilder: (ctx) => items.map((item) {
          return PopupMenuItem<String>(
            value: item,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item,
                  style: TextStyle(
                    fontSize: 15,
                    color: const Color(0xFF263238),
                    fontWeight: item == value ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                if (item == value)
                  const Icon(Icons.check, size: 18, color: Color(0xFF263238)),
              ],
            ),
          );
        }).toList(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            mainAxisAlignment: alignment == Alignment.centerRight
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF263238),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_drop_down, color: Color(0xFF4FC3F7), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
