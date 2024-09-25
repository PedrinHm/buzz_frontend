import 'package:buzz/utils/size_config.dart';
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
      width: MediaQuery.of(context).size.width * 0.90, // Proporção para a largura
      child: Container(
        margin: EdgeInsets.symmetric(vertical: getHeightProportion(context, 8.0)), // Proporção para espaçamento vertical
        padding: EdgeInsets.symmetric(
          horizontal: getWidthProportion(context, 16.0), // Proporção para espaçamento horizontal
          vertical: getHeightProportion(context, 12.0),  // Proporção para espaçamento vertical
        ),
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
                    fontSize: getHeightProportion(context, 16), // Proporção para tamanho da fonte
                    color: Colors.black,
                    fontWeight: FontWeight.w600, // SemiBold
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: getHeightProportion(context, 4.0)), // Proporção para espaçamento vertical
                Text(
                  secondaryText,
                  style: TextStyle(
                    fontSize: getHeightProportion(context, 14), // Proporção para tamanho da fonte
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
