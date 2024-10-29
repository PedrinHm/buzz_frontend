import 'package:flutter/material.dart';
import 'package:buzz/utils/size_config.dart';  // Import correto

class CustomDropdownField extends StatelessWidget {
  final String labelText;
  final int? value;
  final List<DropdownMenuItem<int>> items;
  final void Function(int?) onChanged;
  final String? hintText;

  CustomDropdownField({
    required this.labelText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          labelText,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: getHeightProportion(context, 16.0),  // Tamanho do texto proporcional
          ),
        ),
        if (hintText != null)
          Padding(
            padding: EdgeInsets.only(
              bottom: getHeightProportion(context, 4.0),
              left: getWidthProportion(context, 2.0),
            ),
            child: Text(
              hintText!,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: getHeightProportion(context, 12.0),
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        FractionallySizedBox(
          widthFactor: 0.8,
          child: DropdownButtonHideUnderline(
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFD9D9D9),
                border: Border.all(color: Color(0xFFD9D9D9), width: 2),
                borderRadius: BorderRadius.circular(getHeightProportion(context, 10)),  // Proporção de borda
              ),
              child: DropdownButtonFormField<int>(
                value: value,
                items: items,
                onChanged: onChanged,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: getWidthProportion(context, 10), 
                    vertical: getHeightProportion(context, 15),
                  ),  // Proporção de padding
                  filled: true,
                  fillColor: Color(0xFFD9D9D9),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 2),
                    borderRadius: BorderRadius.circular(getHeightProportion(context, 10)),  // Proporção de borda
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 2),
                    borderRadius: BorderRadius.circular(getHeightProportion(context, 10)),  // Proporção de borda
                  ),
                ),
                dropdownColor: Color(0xFFD9D9D9),
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: getHeightProportion(context, 16.0),  // Tamanho do texto proporcional
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
