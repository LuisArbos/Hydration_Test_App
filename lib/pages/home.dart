import 'dart:io';

import 'package:Hydration_Test_App/models/basic_model.dart';
import 'package:Hydration_Test_App/models/calcul_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  List<BasicModel> basics = [];
  List<CalculModel> calcul = [];
  Map<String, String> valuesMap = {};
  double perdida_peso_porcen = 0.0;
  double tasa_sudoracion = 0.0;
  TextEditingController _filePathController = TextEditingController();


  void _getData() {
    basics = BasicModel.getBasics();
    calcul = CalculModel.getCalcul();
  }
  
  /*Function for test puroposes
  void _onCalculatePressed() {
    valuesMap.forEach((key, value) {
      print('Name: $key, Value: $value');
    });
  } */
  bool _validateFields(){
    List<String> keysToCheck = ['Peso Antes del Ejercicio', 'Peso después del ejercicio','Líquido disponible antes del ejercicio','Liquido restante POST ejercicio','Volumen de orina (L)','Duración del ejercicio (min)'];
    bool allKeysExist = keysToCheck.every((key) => valuesMap.containsKey(key));
    bool anyEmptyValue = valuesMap.entries.where((entry) => keysToCheck.contains(entry.key)).any((entry) => entry.value.isEmpty);
    if(!allKeysExist || anyEmptyValue){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
                      title: Text('ERROR'),
                      content: Text('Todos los campos de "datos para el cálculo" deben ser rellenados.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cerrar',
                          style: TextStyle(color: Colors.green.withOpacity(0.8))),
                          ),
                      ],
                    );
        },
      );
    return false;
    }
    return true;
  }

  void _calculateResult(){
    double peso_antes = double.parse(valuesMap['Peso Antes del Ejercicio'].toString());
    double peso_despues = double.parse(valuesMap['Peso después del ejercicio'].toString());
    double liquido_antes = double.parse(valuesMap['Líquido disponible antes del ejercicio'].toString());
    double liquido_despues = double.parse(valuesMap['Liquido restante POST ejercicio'].toString());
    double vol_orina = double.parse(valuesMap['Volumen de orina (L)'].toString());
    double duracion_ejercicio = double.parse(valuesMap['Duración del ejercicio (min)'].toString());

    double ingesta_liq = liquido_antes - liquido_despues;
    double perdida_peso = peso_antes - peso_despues;
    double perdida_liq = perdida_peso + ingesta_liq - vol_orina;

    perdida_peso_porcen = double.parse((perdida_peso * 100 / peso_antes).toStringAsFixed(3));
    tasa_sudoracion = double.parse((perdida_liq / (duracion_ejercicio / 60)).toStringAsFixed(3));
  }

  @override
  Widget build(BuildContext context) {
    _getData();
    _dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    _timeController.text = DateFormat('HH:mm').format(DateTime.now());

    return Scaffold(
      appBar: appBar(),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _informationSection(),
          SizedBox(height: 20,),
          _buildExtraBar(context),
          _basicsSection(),
          SizedBox(height: 20,),
          _calculSection(),
          SizedBox(height: 20,),
          Center(child: _calculButton(context)),
        ],
        ),
    );
  }

  ElevatedButton _calculButton(BuildContext context) {
    return ElevatedButton(
          onPressed: (){
            if (_validateFields()){
            _calculateResult();
            showDialog(
              context: context, 
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Resultados'),
                  content: Text('Pérdida de peso: $perdida_peso_porcen % \n\nTasa de sudoración: $tasa_sudoracion L/h \n\nLíquido que necesitas reponer\npor hora de ejercicio: $tasa_sudoracion L/h'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cerrar',
                      style: TextStyle(color: Colors.green.withOpacity(0.8))),
                      ),
                  ],
                );
              },
            );
          }
          },
          child: Text('Calcular',
            style: TextStyle(color: Colors.green.withOpacity(0.8))),
        );
  }

  Column _calculSection() {
    return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                'Datos para el cálculo',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: _buildCalculIcon(calcul[0])),
                SizedBox(width: 25,),
                Expanded(child: _buildCalculIcon(calcul[1])),
              ],
            ),
            SizedBox(height: 25,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: _buildCalculIcon(calcul[2])),
                SizedBox(width: 25,),
                Expanded(child: _buildCalculIcon(calcul[3])),
              ],
            ),
            SizedBox(height: 25,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: _buildCalculIcon(calcul[4])),
                SizedBox(width: 25,),
                Expanded(child: _buildCalculIcon(calcul[5])),
              ],
            ),
          ],
        );
  }

  Column _basicsSection() {
    return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                'Básicos',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: _buildIcon(basics[0])),
                SizedBox(width: 25,),
                Expanded(child: _buildIcon(basics[1])),
              ],
            ),
            SizedBox(height: 25,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: _buildIcon(basics[2])),
                SizedBox(width: 25,),
                Expanded(child: _buildIcon(basics[3])),
              ],
            ),
          ],
        );
  }

  Container _informationSection() {
      return Container(
            margin: EdgeInsets.only(top: 10, left: 20, right: 20),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                color: Color(0xff1F1617).withOpacity(0.11),
                blurRadius: 40,
                spreadRadius: 0.0
                )
              ],
            ),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.all(15),
                    hintText: 'Nombre del Paciente',
                    hintStyle: TextStyle(
                      color: Color(0xffDDDADA),
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none
                    )
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      flex: 1,
                      child: TextField(
                        controller: _dateController,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate!);
                            });
                          }
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.all(15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10), // Add some spacing between text fields
                    Flexible(
                      flex: 1,
                      child: TextField(
                        controller: _timeController,
                        onTap: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              _timeController.text = pickedTime.format(context);
                            });
                          }
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.all(15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
      );
    }

  Widget _buildIcon(BasicModel info) {
    return Container(
      width: 100,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: info.boxColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            info.name,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: Colors.black,
              fontSize: 14,
            ),
          ),
          SizedBox(
            height: 25,
            child: TextFormField(
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none
                ),
                filled: true,
                fillColor: info.boxColor.withOpacity(0.45),
              ),
              onChanged: (value) {
                setState(() {
                  valuesMap[info.name] = value;
                });
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCalculIcon(CalculModel info) {
    return Container(
      width: 100,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: info.boxColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            info.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: Colors.black,
              fontSize: 14,
            ),
          ),
          SizedBox(
            height: 25,
            child: TextFormField(
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none
                ),
                filled: true,
                fillColor: info.boxColor.withOpacity(0.45),
              ),
              onChanged: (value) {
                setState(() {
                  valuesMap[info.name] = value;
                });
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildExtraBar(BuildContext context) {
    List<Widget> extraBar = [];
    if (Platform.isWindows) {
      extraBar.add(SizedBox(height: 50, child: _extraBar()));
      extraBar.add(const SizedBox(height: 10));
    }
    return Column(children: extraBar);
  }

  Widget _extraBar() {
    return Container(
      margin: EdgeInsets.only(top: 10, left: 20, right: 20),
      decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                color: Color(0xff1F1617).withOpacity(0.11),
                blurRadius: 40,
                spreadRadius: 0.0
                )
              ],
            ),
      alignment: Alignment.center,
      child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: _filePathController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.all(15),
              hintText: 'Direción del archivo Excel para guardar los datos',
              hintStyle: TextStyle(
                color: Color(0xffDDDADA),
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
            style: TextStyle(
              fontSize: 13, // Adjust the font size as needed
            ),
          ),
        ),
        SizedBox(width: 10), // Spacer between TextField and Button
        IconButton(
          icon: Icon(Icons.folder_open), // Icon for file picker
          onPressed: () async {
            String? filePath = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['xls', 'xlsx'], // Allow only Excel files
            ).then((value) => value?.files.single.path);
            
            if (filePath != null) {
              _filePathController.text = filePath;
            }
          },
        ),
      ],
    ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: Text(
        'Test  de Hidratación',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0.0,
      centerTitle: true,
    );
  }
}


  