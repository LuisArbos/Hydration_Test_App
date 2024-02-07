import 'package:flutter/material.dart';

class CalculModel{
  String name;
  double value;
  Color boxColor;

  CalculModel({
    required this.name,
    required this.value,
    required this.boxColor,
  });

  static List<CalculModel> getCalcul() {
    List<CalculModel> calcul = [];

    calcul.add(
      CalculModel(
        name: 'Peso Antes del Ejercicio', 
        value: 0.0, 
        boxColor: Color(0xffC58BF2)
        )
    );

    calcul.add(
      CalculModel(
        name: 'Peso después del ejercicio', 
        value: 0.0, 
        boxColor: Color(0xff92A3FD)
        )
    );

    calcul.add(
      CalculModel(
        name: 'Líquido disponible antes del ejercicio', 
        value: 0.0, 
        boxColor: Color(0xff92A3FD)
        )
    );

    calcul.add(
      CalculModel(
        name: 'Liquido restante POST ejercicio', 
        value: 0.0, 
        boxColor: Color(0xffC58BF2)
        )
    );

    calcul.add(
      CalculModel(
        name: 'Volumen de orina (L)', 
        value: 0.0, 
        boxColor: Color(0xffC58BF2)
        )
    );

    calcul.add(
      CalculModel(
        name: 'Duración del ejercicio (min)', 
        value: 0.0, 
        boxColor: Color(0xff92A3FD)
        )
    );

    return calcul;
  }
}