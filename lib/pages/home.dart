import 'dart:ffi';
import 'dart:io';
import 'package:Hydration_Test_App/models/basic_model.dart';
import 'package:Hydration_Test_App/models/calcul_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:excel/excel.dart' as EP;

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

  String name = "";
  String intensity = "";
  double temp_amb = 0.0;
  double humidity = 0.0;
  double temp_per = 0.0;
  double weight_before = 0.0;
  double weight_after = 0.0;
  double liquid_before = 0.0;
  double liquid_after = 0.0;
  double urine_vol = 0.0;
  double time_exercice = 0.0;
  double liquid_inp = 0.0;
  double weight_loss = 0.0;
  double liquid_loss = 0.0;
  double weight_loss_porcen = 0.0;
  double sweat_rate = 0.0;
  
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
    if (valuesMap.containsKey('Temperatura Ambiente')) {
    temp_amb = double.parse(valuesMap['Temperatura Ambiente'].toString().replaceAll(',', '.'));
    }
    if(valuesMap.containsKey('Temperatura Percibida')){
      temp_per= double.parse(valuesMap['Temperatura Percibida'].toString().replaceAll(',', '.'));
    }
    if(valuesMap.containsKey('Humedad')){
      humidity = double.parse(valuesMap['Humedad'].toString().replaceAll(',', '.'));
    }
    if(valuesMap.containsKey('Temperatura Percibida')){
      intensity = valuesMap['Intensidad']!;
    }
    weight_before = double.parse(valuesMap['Peso Antes del Ejercicio'].toString().replaceAll(',', '.'));
    weight_after = double.parse(valuesMap['Peso después del ejercicio'].toString().replaceAll(',', '.'));
    liquid_before = double.parse(valuesMap['Líquido disponible antes del ejercicio'].toString().replaceAll(',', '.'));
    liquid_after = double.parse(valuesMap['Liquido restante POST ejercicio'].toString().replaceAll(',', '.'));
    urine_vol = double.parse(valuesMap['Volumen de orina (L)'].toString().replaceAll(',', '.'));
    time_exercice = double.parse(valuesMap['Duración del ejercicio (min)'].toString().replaceAll(',', '.'));

    liquid_inp = liquid_before - liquid_after;
    weight_loss = weight_before - weight_after;
    liquid_loss = weight_loss + liquid_inp - urine_vol;

    weight_loss_porcen = double.parse((weight_loss * 100 / weight_before).toStringAsFixed(3));
    sweat_rate = double.parse((liquid_loss / (time_exercice / 60)).toStringAsFixed(3));
  }

  void _updateExcelFile() async {
    String filePath = _filePathController.text;

    if (filePath.isNotEmpty) {
      var bytes = File(filePath).readAsBytesSync();
      var file = Excel.decodeBytes(bytes);
      if(file.sheets.isNotEmpty){
        Sheet sheetObject = file.sheets.values.first;

        int? maxRow= sheetObject.maxRows;
        int myRowIndex = -1;

        for (var i = 9; i < maxRow; i++){
          var initialRow = sheetObject.row(i);
          if (initialRow[0] == null || initialRow[0]?.value == null) {
            myRowIndex = i;
            break;
          }
        }
        if(myRowIndex != -1){
          int? myMax = sheetObject.maxRows;
          for (int col = 0; col < sheetObject.maxColumns; col++) {
            final cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: myMax));
            cell.value = const TextCellValue(''); 
            cell.cellStyle = null; 
          }
          /*sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: myMax)).cellStyle = CellStyle(
            bottomBorder: EP.Border(borderStyle: EP.BorderStyle.Thin), 
            topBorder: EP.Border(borderStyle: EP.BorderStyle.Thin), 
            leftBorder: EP.Border(borderStyle: EP.BorderStyle.Thin), 
            rightBorder: EP.Border(borderStyle: EP.BorderStyle.Thin),
            backgroundColorHex: '#A0ACB1');
*/
          _insertRowAndShiftDown(sheetObject, maxRow, myRowIndex);
        }
        
        var cellName = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: myRowIndex));
        var cellDate = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: myRowIndex));
        var cellTime = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: myRowIndex));
        var cellIntensity = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: myRowIndex));
        var cellTempAmb = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: myRowIndex));
        var cellHumidity = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: myRowIndex));
        var cellTempPer = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: myRowIndex));
        var cellWeightBef = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: myRowIndex));
        var cellWeightAft = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: myRowIndex));
        var cellLiqBef = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: myRowIndex));
        var cellLiqAft = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: myRowIndex));
        var cellUrineVol = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: myRowIndex));
        var cellTimeExerc = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: myRowIndex));
        var cellLiqInp = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: myRowIndex));
        var cellWeightloss = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 14, rowIndex: myRowIndex));
        var cellLiqloss = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 15, rowIndex: myRowIndex));
        var cellWeightlossPerc = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 16, rowIndex: myRowIndex));
        var cellSudRate = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 17, rowIndex: myRowIndex));
        var cellLiqNecc = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 18, rowIndex: myRowIndex));

        CellStyle initialCell = CellStyle(
          leftBorder: EP.Border(borderStyle: EP.BorderStyle.Thin),
          rightBorder: EP.Border(borderStyle: EP.BorderStyle.Thin),
          topBorder: EP.Border(borderStyle: EP.BorderStyle.Thin),
          bottomBorder: EP.Border(borderStyle: EP.BorderStyle.Thin),
          numberFormat: NumFormat.standard_0,
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
        );
        CellStyle initialCell2 = CellStyle(
          leftBorder: EP.Border(borderStyle: EP.BorderStyle.Thin),
          rightBorder: EP.Border(borderStyle: EP.BorderStyle.Thin),
          topBorder: EP.Border(borderStyle: EP.BorderStyle.Thin),
          bottomBorder: EP.Border(borderStyle: EP.BorderStyle.Thin),
          numberFormat: NumFormat.standard_2,
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
        );
        CellStyle finalCell = CellStyle(
          leftBorder: EP.Border(borderStyle: EP.BorderStyle.Medium),
          rightBorder: EP.Border(borderStyle: EP.BorderStyle.Medium),
          topBorder: EP.Border(borderStyle: EP.BorderStyle.Thin),
          bottomBorder: EP.Border(borderStyle: EP.BorderStyle.Thin),
          numberFormat: NumFormat.standard_2,
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,           
        );

        cellName.value = TextCellValue(name);
        cellDate.value = TextCellValue(DateFormat('dd-MM-yyyy').format(DateTime.now()));
        cellTime.value = TextCellValue(DateFormat('HH:mm').format(DateTime.now()));
        cellIntensity.value = TextCellValue(intensity);
        cellTempAmb.value = DoubleCellValue(temp_amb); 
        cellTempAmb.cellStyle = (cellTempAmb.cellStyle ?? initialCell);
        cellHumidity.value = DoubleCellValue(humidity);
        cellHumidity.cellStyle = (cellHumidity.cellStyle ?? initialCell);
        cellTempPer.value = DoubleCellValue(temp_per);
        cellTempPer.cellStyle = (cellTempPer.cellStyle ?? initialCell);
        cellWeightBef.value = DoubleCellValue(weight_before);
        cellWeightBef.cellStyle = (cellWeightBef.cellStyle ?? initialCell);
        cellWeightAft.value = DoubleCellValue(weight_after);
        cellWeightAft.cellStyle = (cellWeightAft.cellStyle ?? initialCell);
        cellLiqBef.value = DoubleCellValue(liquid_before);
        cellLiqBef.cellStyle = (cellLiqBef.cellStyle ?? initialCell);
        cellLiqAft.value = DoubleCellValue(liquid_after);
        cellLiqAft.cellStyle = (cellLiqAft.cellStyle ?? initialCell);
        cellUrineVol.value = DoubleCellValue(urine_vol);
        cellUrineVol.cellStyle = (cellUrineVol.cellStyle ?? initialCell);
        cellTimeExerc.value = DoubleCellValue(time_exercice);
        cellTimeExerc.cellStyle = (cellTimeExerc.cellStyle ?? initialCell);
        cellLiqInp.value = DoubleCellValue(liquid_inp);
        cellLiqInp.cellStyle = (cellLiqInp.cellStyle ?? initialCell2);
        cellWeightloss.value = DoubleCellValue(weight_loss);
        cellWeightloss.cellStyle = (cellWeightloss.cellStyle ?? initialCell2);
        cellLiqloss.value = DoubleCellValue(liquid_loss);
        cellLiqloss.cellStyle = (cellLiqloss.cellStyle ?? initialCell2);
        cellWeightlossPerc.value = DoubleCellValue(weight_loss_porcen);
        cellWeightlossPerc.cellStyle = (cellWeightlossPerc.cellStyle ?? finalCell);
        cellSudRate.value = DoubleCellValue(sweat_rate);
        cellSudRate.cellStyle = (cellSudRate.cellStyle ?? finalCell);
        cellLiqNecc.value = DoubleCellValue(sweat_rate);
        cellLiqNecc.cellStyle = (cellLiqNecc.cellStyle ?? finalCell);

        sheetObject.setColumnWidth(0, (28.71*1.025));
        sheetObject.setColumnWidth(1, (11.71*1.065)); 
        sheetObject.setColumnWidth(2, (8*1.098)); 
        sheetObject.setColumnWidth(3, (10*1.077)); 
        sheetObject.setColumnWidth(4, (12.43*1.06)); 
        sheetObject.setColumnWidth(5, (9.57*1.08)); 
        sheetObject.setColumnWidth(6, (12.43*1.06)); 
        sheetObject.setColumnWidth(7, (11*1.069)); 
        sheetObject.setColumnWidth(8, (12.71*1.06)); 
        sheetObject.setColumnWidth(9, (14.71*1.05)); 
        sheetObject.setColumnWidth(10, (13.29*1.06)); 
        sheetObject.setColumnWidth(11, (8*1.098)); 
        sheetObject.setColumnWidth(12, (14.14*1.05)); 
        sheetObject.setColumnWidth(13, (9*1.085)); 
        sheetObject.setColumnWidth(14, (9.43*1.08)); 
        sheetObject.setColumnWidth(15, (10.14*1.075)); 
        sheetObject.setColumnWidth(16, (11.43*1.067)); 
        sheetObject.setColumnWidth(17, (10.71*1.071)); 
        sheetObject.setColumnWidth(18, (13.71*1.055)); 

        sheetObject.setRowHeight(0, (15));
        sheetObject.setRowHeight(1, (15));
        sheetObject.setRowHeight(2, (15));
        sheetObject.setRowHeight(3, (18.75));
        sheetObject.setRowHeight(4, (15.75));
        sheetObject.setRowHeight(5, (15.75));
        sheetObject.setRowHeight(6, (15));
        sheetObject.setRowHeight(7, (15.75));
        sheetObject.setRowHeight(8, (60));
        sheetObject.setRowHeight(9, (15));
        
        /*sheetObject.setMergedCellStyle(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 7), CellStyle(backgroundColorHex: '#ADEBEB', fontFamily: 'Calibri', fontSize: 11, verticalAlign: VerticalAlign.Center, horizontalAlign: HorizontalAlign.Center,));
        sheetObject.setMergedCellStyle(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 7), CellStyle(backgroundColorHex: '#99FFEB', fontFamily: 'Calibri', fontSize: 11, verticalAlign: VerticalAlign.Center, horizontalAlign: HorizontalAlign.Center,));
        sheetObject.setMergedCellStyle(CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: 7), CellStyle(backgroundColorHex: '#B7FFFF', fontFamily: 'Calibri', fontSize: 11, verticalAlign: VerticalAlign.Center, horizontalAlign: HorizontalAlign.Center,));
        sheetObject.setMergedCellStyle(CellIndex.indexByColumnRow(columnIndex: 16, rowIndex: 7), CellStyle(backgroundColorHex: '#30D1DA', fontFamily: 'Calibri', fontSize: 11, verticalAlign: VerticalAlign.Center, horizontalAlign: HorizontalAlign.Center,));
        */  

        _setRangeBackgroundColor(sheetObject, 2, 6, 7, "#ADEBEB");
        _setRangeBackgroundColor(sheetObject, 7, 12, 7, "#99FFEB");
        _setRangeBackgroundColor(sheetObject, 13, 15, 7, "#B7FFFF");
        _setRangeBackgroundColor(sheetObject, 16, 18, 7, "#30D1DA");

        file.save();
          List<int>? fileBytes = file.encode();
        if (fileBytes != null){
          File(filePath).writeAsBytesSync(fileBytes);
        }
      }
      
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Excel Actualizado'),
            content: Text('El archivo Excel ha sido actualizado correctamente.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _setRangeBackgroundColor(
    Sheet sheetObject, 
    int startColumn, 
    int endColumn, 
    int rowIndex, 
    String colorHex) {
    for (int i = startColumn; i <= endColumn; i++) {
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex)).cellStyle = CellStyle(
        backgroundColorHex: colorHex, 
        fontFamily: 'Calibri', 
        fontSize: 11,);
    }
  }

  void _insertRowAndShiftDown(Sheet sheetObject, int maxRow, int myRowIndex) {
    for (int i = maxRow-1 ; i > myRowIndex; i--) {
      for (int j = 0; j < sheetObject.maxColumns; j++) {
        var currentCell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i));
        var cellBelow = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1));
        cellBelow.value = currentCell.value;
        cellBelow.cellStyle = currentCell.cellStyle;
      }
    }
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
          SizedBox(height: 20,),
          Center(child: Text('Diseñado por Luis Arbós. luisarbos@gmx.com', style: TextStyle(fontSize: 9),),
          ),
        ],
        ),
    );
  }

  ElevatedButton _calculButton(BuildContext context) {
    return ElevatedButton(
          onPressed: (){
            if (_validateFields()){
            _calculateResult();
            _updateExcelFile();
            showDialog(
              context: context, 
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Resultados'),
                  content: Text('Pérdida de peso: $weight_loss_porcen % \n\nTasa de sudoración: $sweat_rate L/h \n\nLíquido que necesitas reponer\npor hora de ejercicio: $sweat_rate L/h'),
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
            SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: _buildCalculIcon(calcul[2])),
                SizedBox(width: 25,),
                Expanded(child: _buildCalculIcon(calcul[3])),
              ],
            ),
            SizedBox(height: 15,),
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
            SizedBox(height: 15,),
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
                  onChanged: (value){
                    setState(() {
                      name = value;
                    });
                  },
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
          SizedBox(height: 3,),
          SizedBox(
            height: 25,
            child: TextFormField(
              textAlignVertical: TextAlignVertical.center,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14,),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
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
          ),
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
          SizedBox(height: 3,),
          SizedBox(
            height: 25,
            child: TextFormField(
              textAlignVertical: TextAlignVertical.center,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14,),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
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
      backgroundColor: Colors.white,
      elevation: 0.0,
      centerTitle: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/Logo.png',
            width: 40, // Adjust the width as needed
            height: 40, // Adjust the height as needed
          ),
          Spacer(),
          Text(
            'Test  de Hidratación',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold
            ),
          ),
          Spacer(),
          SizedBox(width: 40,),
        ],
      ),
    );
  }
}


