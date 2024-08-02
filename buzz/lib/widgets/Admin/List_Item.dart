
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ListItem extends StatelessWidget {
  final String primaryText;
  final String secondaryText;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final int index;

  ListItem({
    required this.primaryText,
    required this.secondaryText,
    required this.onEdit,
    required this.onDelete,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    // Alterna entre cinza claro e cinza escuro
    final Color backgroundColor = index % 2 == 0 ? Colors.grey[300]! : Colors.grey[400]!;

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.90,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  primaryText,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600, // SemiBold
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  secondaryText,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(PhosphorIcons.trashSimple, color: Colors.black),
                  onPressed: onDelete,
                ),
                IconButton(
                  icon: Icon(PhosphorIcons.pencilSimple, color: Colors.black),
                  onPressed: onEdit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}