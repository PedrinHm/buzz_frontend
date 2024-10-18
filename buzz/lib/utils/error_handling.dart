import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:buzz/services/decodeJsonResponse.dart';

void showSnackbar(BuildContext context, String message, Color color) {
  final snackBar = SnackBar(
    content: Text(message),
    backgroundColor: color,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showErrorMessage(BuildContext context, String errorMessage) {
  try {
    // Primeiro, tentamos extrair o JSON da mensagem de erro
    final startIndex = errorMessage.indexOf('{');
    final endIndex = errorMessage.lastIndexOf('}');
    if (startIndex != -1 && endIndex != -1 && startIndex < endIndex) {
      final jsonString = errorMessage.substring(startIndex, endIndex + 1);
      final response = http.Response(jsonString, 200);
      final Map<String, dynamic> errorResponse = decodeJsonResponse(response);
      
      if (errorResponse.containsKey('detail')) {
        errorMessage = errorResponse['detail'];
      }
    }
    
    showSnackbar(context, errorMessage, Colors.red);
  } catch (e) {
    // Se algo der errado, exibimos a mensagem original
    showSnackbar(context, errorMessage, Colors.red);
  }
}
