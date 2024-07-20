import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ListItem extends StatelessWidget {
  final String primaryText;
  final String secondaryText;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  ListItem({
    required this.primaryText,
    required this.secondaryText,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.90,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Color(0xFF395BC7),
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
                    color: Colors.white,
                    fontWeight: FontWeight.w600, // SemiBold
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  secondaryText,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(PhosphorIcons.trashSimple, color: Colors.white),
                  onPressed: onDelete,
                ),
                IconButton(
                  icon: Icon(PhosphorIcons.pencilSimple, color: Colors.white),
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
