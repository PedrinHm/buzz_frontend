import 'package:flutter/material.dart';
import 'package:buzz/utils/size_config.dart';  // Import correto

class CustomPopup extends StatelessWidget {
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  CustomPopup({
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(getHeightProportion(context, 16)),  // Proporção de borda
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      child: Container(
        padding: EdgeInsets.all(getHeightProportion(context, 16)),  // Proporção de padding
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: getHeightProportion(context, 16)),  // Proporção de espaço
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: getHeightProportion(context, 18), fontFamily: 'Inter', fontWeight: FontWeight.w400),
            ),
            SizedBox(height: getHeightProportion(context, 24)),  // Proporção de espaço
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: onCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFDD4425), // Cor do botão "Cancelar"
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(getHeightProportion(context, 12)),  // Proporção de borda
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: getWidthProportion(context, 24), 
                      vertical: getHeightProportion(context, 12),
                    ),  // Proporção de padding
                    child: Text(
                      cancelText,
                      style: TextStyle(
                        fontSize: getHeightProportion(context, 16),  // Tamanho do texto proporcional
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3E9B4F), // Cor do botão "Confirmar"
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(getHeightProportion(context, 12)),  // Proporção de borda
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: getWidthProportion(context, 24), 
                      vertical: getHeightProportion(context, 12),
                    ),  // Proporção de padding
                    child: Text(
                      confirmText,
                      style: TextStyle(
                        fontSize: getHeightProportion(context, 16),  // Tamanho do texto proporcional
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
