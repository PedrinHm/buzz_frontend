import 'dart:convert';

import 'package:flutter/material.dart';

void showSnackbar(BuildContext context, String message, Color color) {
  final snackBar = SnackBar(
    content: Text(message),
    backgroundColor: color,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showErrorMessage(BuildContext context, String responseBody) {
  try {
    final Map<String, dynamic> errorResponse = json.decode(responseBody);
    if (errorResponse.containsKey('detail')) {
      final detail = errorResponse['detail'];
      if (detail is List && detail.isNotEmpty) {
        final error = detail[0];
        showSnackbar(context, error['msg'], Colors.red);
      } else {
        showSnackbar(
            context, 'Erro desconhecido.', Colors.red);
      }
    } else {
      showSnackbar(
          context, 'Erro desconhecido.', Colors.red);
    }
  } catch (e) {
    showSnackbar(context, 'Erro desconhecido.', Colors.red);
  }
}
