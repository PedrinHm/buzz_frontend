import 'package:flutter/material.dart';

class CustomDropdownField extends StatelessWidget {
  final String labelText;
  final int? value;
  final List<DropdownMenuItem<int>> items;
  final void Function(int?) onChanged;

  CustomDropdownField({
    required this.labelText,
    required this.value,
    required this.items,
    required this.onChanged,
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
            fontSize: 16.0,
          ),
        ),
        FractionallySizedBox(
          widthFactor: 0.8,
          child: DropdownButtonHideUnderline(
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFD9D9D9),
                border: Border.all(color: Color(0xFFD9D9D9), width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonFormField<int>(
                value: value,
                items: items,
                onChanged: onChanged,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  filled: true,
                  fillColor: Color(0xFFD9D9D9),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                dropdownColor: Color(0xFFD9D9D9),
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
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
