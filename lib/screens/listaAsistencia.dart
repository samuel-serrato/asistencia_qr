import 'dart:convert';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ListaAsistencia extends StatefulWidget {
  @override
  _ListaAsistenciaState createState() => _ListaAsistenciaState();
}

class _ListaAsistenciaState extends State<ListaAsistencia> {
  late Future<Map<String, dynamic>> futureData;
  String selectedGrado = 'Todos'; // Valor predeterminado
  String selectedSeccion = 'Todas'; // Valor predeterminado
  String searchQuery = ''; // Término de búsqueda
  DateTime selectedDate = DateTime.now(); // Fecha seleccionada

  Future<Map<String, dynamic>> fetchData() async {
    final asistenciaResponse = await http.get(
        Uri.parse('http://192.168.1.116:8000/asistencias_api/asistencia.php'));
    final alumnosResponse = await http.get(Uri.parse(
        'http://192.168.1.116:8000/asistencias_api/listaAlumnos.php'));

    if (asistenciaResponse.statusCode == 200 &&
        alumnosResponse.statusCode == 200) {
      List<dynamic> asistenciaData = json.decode(asistenciaResponse.body);
      List<dynamic> alumnosData = json.decode(alumnosResponse.body);

      Map<String, dynamic> alumnosMap = {
        for (var alumno in alumnosData) alumno['matriculaSoc']: alumno
      };

      return {'asistencia': asistenciaData, 'alumnos': alumnosMap};
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  @override
  void initState() {
    super.initState();
    futureData = fetchData();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    String _formatDate(String dateString) {
      // Convierte la cadena a un objeto DateTime
      DateTime date = DateTime.parse(dateString);

      // Formatea la fecha y la hora en 12 horas en español
      final DateFormat formatter = DateFormat('h:mm:ss a', 'es_ES');
      return formatter.format(date);
    }

    return Scaffold(
        backgroundColor: Color(0xFFEFEFEF),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 28, 100, 163),
                  Color(0xFF181F4B),
                ],
                begin: Alignment.topLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: AppBar(
              //automaticallyImplyLeading: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: IconButton(
                    icon: const Icon(
                      Icons.replay_circle_filled_sharp,
                      color: Colors.white,
                    ),
                    tooltip: 'Recargar',
                    onPressed: () {
                      setState(() {
                        futureData = fetchData();
                      });
                    },
                  ),
                ),
              ],
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Asistencia',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<Map<String, dynamic>>(
            future: futureData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                    child: Text('Error: ${snapshot.error}',
                        style: TextStyle(color: Colors.red)));
              } else if (!snapshot.hasData ||
                  snapshot.data!['asistencia'].isEmpty) {
                return Center(
                    child: Text('No hay datos disponibles',
                        style: TextStyle(color: Colors.black)));
              } else {
                List<dynamic> asistencia = snapshot.data!['asistencia'];
                Map<String, dynamic> alumnos = snapshot.data!['alumnos'];

                List<dynamic> filteredAsistencia = asistencia.where((item) {
                  String matricula = item['matriculaSoc'] ?? '';
                  var alumno = alumnos[matricula] ?? {};
                  DateTime fechaEntrada = DateTime.parse(item['fechaEntrada']);
                  bool matchesDate = fechaEntrada.year == selectedDate.year &&
                      fechaEntrada.month == selectedDate.month &&
                      fechaEntrada.day == selectedDate.day;

                  String lowerSearchQuery =
                      removeDiacritics(searchQuery.toLowerCase());
                  String nombres =
                      removeDiacritics(alumno['nombres']?.toLowerCase() ?? '');
                  String apellidoP = removeDiacritics(
                      alumno['apellidoP']?.toLowerCase() ?? '');
                  String apellidoM = removeDiacritics(
                      alumno['apellidoM']?.toLowerCase() ?? '');
                  String matriculaLower =
                      removeDiacritics(matricula.toLowerCase());

                  bool matchesSearch = nombres.contains(lowerSearchQuery) ||
                      apellidoP.contains(lowerSearchQuery) ||
                      apellidoM.contains(lowerSearchQuery) ||
                      matriculaLower.contains(lowerSearchQuery);

                  return matchesDate &&
                      (selectedGrado == 'Todos' ||
                          alumno['grado'] == selectedGrado) &&
                      (selectedSeccion == 'Todas' ||
                          alumno['seccion'] == selectedSeccion) &&
                      matchesSearch;
                }).toList();

                return Column(
                  children: [
                    SizedBox(height: 16),
                    // Fila de filtros
                    if (isDesktop) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Fecha",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Container(
                                width: 200,
                                height: 47,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(17),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 2,
                                      blurRadius: 7,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () => _selectDate(context),
                                  icon: Icon(Icons.calendar_today),
                                  label: Text(
                                    DateFormat('E, d MMM yyyy')
                                        .format(selectedDate),
                                    //"${selectedDate.toLocal().toString().split(' ')[0]}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(17))),
                                    foregroundColor: Colors.black,
                                    backgroundColor: Colors.white,
                                    shadowColor: Colors.transparent,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 10.0),
                                    textStyle: TextStyle(fontSize: 16),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Sección",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Container(
                                width: 150,
                                child: DropdownButtonFormField<String>(
                                  value: selectedSeccion,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedSeccion = newValue ?? 'Todas';
                                    });
                                  },
                                  items: [
                                    'Todas',
                                    'Preescolar',
                                    'Primaria',
                                    'Secundaria',
                                    'Preparatoria'
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(17),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(17),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(17),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 12),
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Grado",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Container(
                                width: 150,
                                child: DropdownButtonFormField<String>(
                                  value: selectedGrado,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedGrado = newValue ?? 'Todos';
                                    });
                                  },
                                  items: ['Todos', '1', '2', '3', '4', '5', '6']
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(17),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(17),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(17),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 12),
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Column(
                            children: [
                              SizedBox(height: 24),
                              Container(
                                width: 500,
                                child: TextField(
                                  onChanged: (value) {
                                    setState(() {
                                      searchQuery = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    floatingLabelStyle:
                                        TextStyle(color: Colors.black),
                                    labelText: 'Buscar por nombre o matrícula',
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius:
                                            BorderRadius.circular(17)),
                                    fillColor: Colors.white,
                                    filled: true,
                                    prefixIcon: Icon(
                                      Icons.search,
                                      size: 20,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(17),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ] else ...[
                      // Diseño para móviles
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Fecha",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 4),
                                    Container(
                                      width: double.infinity,
                                      height: 47,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(17),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            spreadRadius: 2,
                                            blurRadius: 10,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton.icon(
                                        onPressed: () => _selectDate(context),
                                        icon: Icon(
                                          Icons.calendar_today,
                                          size: 14,
                                        ),
                                        label: Text(
                                          "${selectedDate.toLocal().toString().split(' ')[0]}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(17))),
                                          foregroundColor: Colors.black,
                                          backgroundColor: Colors.white,
                                          shadowColor: Colors.transparent,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.0, vertical: 10.0),
                                          textStyle: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Sección",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 4),
                                    Container(
                                      width: double.infinity,
                                      child: DropdownButtonFormField<String>(
                                        style: TextStyle(fontSize: 12),
                                        value: selectedSeccion,
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedSeccion =
                                                newValue ?? 'Todas';
                                          });
                                        },
                                        items: [
                                          'Todas',
                                          'Preescolar',
                                          'Primaria',
                                          'Secundaria',
                                          'Preparatoria'
                                        ].map<DropdownMenuItem<String>>(
                                            (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          filled: true,
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(17),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(17),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(17),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 12),
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            spreadRadius: 2,
                                            blurRadius: 10,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Grado",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 4),
                                    Container(
                                      width: double.infinity,
                                      child: DropdownButtonFormField<String>(
                                        style: TextStyle(fontSize: 12),
                                        value: selectedGrado,
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedGrado = newValue ?? 'Todos';
                                          });
                                        },
                                        items: [
                                          'Todos',
                                          '1',
                                          '2',
                                          '3',
                                          '4',
                                          '5',
                                          '6'
                                        ].map<DropdownMenuItem<String>>(
                                            (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          filled: true,
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(17),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(17),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(17),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 12),
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            spreadRadius: 2,
                                            blurRadius: 10,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value;
                                });
                              },
                              decoration: InputDecoration(
                                floatingLabelStyle:
                                    TextStyle(color: Colors.black),
                                labelText: 'Buscar por nombre o matrícula',
                                labelStyle: TextStyle(fontSize: 12),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(17)),
                                fillColor: Colors.white,
                                filled: true,
                                prefixIcon: Icon(
                                  Icons.search,
                                  size: 18,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(17),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        height: 400,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: MediaQuery.of(context).size.width,
                                ),
                                child: DataTable(
                                  border: TableBorder(
                                    horizontalInside: BorderSide(
                                        color: Color(0xFFcacaca), width: 1),
                                  ),
                                  columnSpacing: 16.0,
                                  headingRowColor:
                                      MaterialStateColor.resolveWith(
                                    (states) => Color.fromARGB(255, 16, 31, 123)
                                        .withOpacity(0.99),
                                  ),
                                  dataRowColor: MaterialStateColor.resolveWith(
                                    (states) => Colors.grey.withOpacity(0.05),
                                  ),
                                  columns: [
                                    DataColumn(
                                      label: Text(
                                        'Matrícula',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  600
                                              ? 12
                                              : null,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Fecha y Hora',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  600
                                              ? 12
                                              : null,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Nombres',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  600
                                              ? 12
                                              : null,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Apellidos',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  600
                                              ? 12
                                              : null,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Sección',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  600
                                              ? 12
                                              : null,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Grado',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  600
                                              ? 12
                                              : null,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Fecha de Nacimiento',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  600
                                              ? 12
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows:
                                      filteredAsistencia.map((asistenciaItem) {
                                    String matricula =
                                        asistenciaItem['matriculaSoc'] ?? '';
                                    var alumno = alumnos[matricula] ?? {};
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Text(
                                            matricula,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .width <
                                                      600
                                                  ? 12
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            _formatDate(
                                                asistenciaItem['fechaEntrada']),
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .width <
                                                      600
                                                  ? 12
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            alumno['nombres'] ?? '',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .width <
                                                      600
                                                  ? 12
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${alumno['apellidoP'] ?? ''} ${alumno['apellidoM'] ?? ''}',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .width <
                                                      600
                                                  ? 12
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            alumno['seccion'] ?? '',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .width <
                                                      600
                                                  ? 12
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            alumno['grado'] ?? '',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .width <
                                                      600
                                                  ? 12
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            alumno['fechaNacimiento']
                                                    ?.split(' ')[0] ??
                                                '',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .width <
                                                      600
                                                  ? 12
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                );
              }
            },
          ),
        ));
  }
}
