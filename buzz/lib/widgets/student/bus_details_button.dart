import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:buzz/utils/size_config.dart';  // Import correto

class BusDetailsButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String busNumber;
  final String driverName;
  final int capacity;
  final int? availableSeats; // Fazendo este campo opcional
  final Color color;

  BusDetailsButton({
    required this.onPressed,
    required this.busNumber,
    required this.driverName,
    required this.capacity,
    this.availableSeats, // Removendo o 'required' para tornar opcional
    this.color = const Color(0xFF395BC7), // Cor padrão
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: getHeightProportion(context, 130),  // Proporção de altura
          padding: EdgeInsets.symmetric(
            vertical: getHeightProportion(context, 15.0), 
            horizontal: getWidthProportion(context, 20.0), // Proporção de padding
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(getHeightProportion(context, 10)), // Proporção de borda
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(getHeightProportion(context, 15)),  // Proporção de padding
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(getHeightProportion(context, 10)), // Proporção de borda
                  border: Border.all(
                    color: Colors.white,
                    width: 1,
                  ),
                ),
                child: Icon(
                  PhosphorIcons.bus,
                  color: Colors.white,
                  size: getHeightProportion(context, 35),  // Tamanho do ícone proporcional
                ),
              ),
              SizedBox(width: getWidthProportion(context, 20)), // Proporção de espaçamento
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ônibus',
                    style: TextStyle(
                      fontSize: getHeightProportion(context, 16),  // Tamanho do texto proporcional
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    busNumber,
                    style: TextStyle(
                      fontSize: getHeightProportion(context, 12),  // Tamanho do texto proporcional
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    driverName,
                    style: TextStyle(
                      fontSize: getHeightProportion(context, 12),  // Tamanho do texto proporcional
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Capacidade: $capacity',
                    style: TextStyle(
                      fontSize: getHeightProportion(context, 12),  // Tamanho do texto proporcional
                      color: Colors.white,
                    ),
                  ),
                  if (availableSeats != null) // Condicional para exibir ou não as vagas disponíveis
                    Text(
                      'Vagas disponíveis: $availableSeats',
                      style: TextStyle(
                        fontSize: getHeightProportion(context, 12),  // Tamanho do texto proporcional
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
