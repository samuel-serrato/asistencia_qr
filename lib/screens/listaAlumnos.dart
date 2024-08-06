import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:diacritic/diacritic.dart';
import 'package:intl/intl.dart';

class ListaAlumnos extends StatefulWidget {
  @override
  _ListaAlumnosState createState() => _ListaAlumnosState();
}

class _ListaAlumnosState extends State<ListaAlumnos> {
  late Future<List<dynamic>> futureAlumnos;
  String selectedSeccion = 'Todos';
  String selectedGrado = 'Todos';
  String searchQuery = '';

  Future<List<dynamic>> fetchAlumnos() async {
    final response = await http.get(Uri.parse(
        'http://192.168.1.116:8000/asistencias_api/listaAlumnos.php'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  @override
  void initState() {
    super.initState();
    futureAlumnos = fetchAlumnos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFEFEF),
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(60.0), // Ajusta la altura según sea necesario
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
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
            backgroundColor:
                Colors.transparent, // Haz el fondo del AppBar transparente
            elevation: 0, // Elimina la sombra del AppBar
            title: Text(
              'Lista de Alumnos',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<dynamic>>(
          future: futureAlumnos,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<dynamic> alumnos = snapshot.data!;

              if (selectedSeccion != 'Todos') {
                alumnos = alumnos
                    .where((alumno) => alumno['seccion'] == selectedSeccion)
                    .toList();
              }

              if (selectedGrado != 'Todos') {
                alumnos = alumnos
                    .where((alumno) => alumno['grado'] == selectedGrado)
                    .toList();
              }

              if (searchQuery.isNotEmpty) {
                final normalizedQuery =
                    removeDiacritics(searchQuery.toLowerCase());

                alumnos = alumnos
                    .where((alumno) =>
                        removeDiacritics(alumno['nombres'].toLowerCase())
                            .contains(normalizedQuery) ||
                        removeDiacritics(alumno['apellidoP'].toLowerCase())
                            .contains(normalizedQuery) ||
                        removeDiacritics(alumno['apellidoM'].toLowerCase())
                            .contains(normalizedQuery) ||
                        removeDiacritics(alumno['matriculaSoc'].toLowerCase())
                            .contains(normalizedQuery))
                    .toList();
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    // Modo escritorio
                    return Column(
                      children: [
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Sección",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Container(
                                  width: 150,
                                  child: DropdownButtonFormField<String>(
                                    value: selectedSeccion,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedSeccion = newValue ?? 'Todos';
                                      });
                                    },
                                    items: [
                                      'Todos',
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
                                    dropdownColor: Colors.white,
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
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
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
                                    dropdownColor: Colors.white,
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
                                      floatingLabelStyle: TextStyle(
                                          color: Colors
                                              .black), // Color del texto cuando está flotando

                                      labelText:
                                          'Buscar por nombre, matrícula o apellidos',
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
                                      ), //ícono de búsqueda
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
                        SizedBox(height: 16),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: MediaQuery.of(context).size.width -
                                  40, // Ajusta el padding si es necesario
                              height: 600,
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
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minWidth: constraints.maxWidth,
                                          ),
                                          child: DataTable(
                                            border: TableBorder(
                                              horizontalInside: BorderSide(
                                                color: Color(0xFFcacaca),
                                                width: 1,
                                              ),
                                            ),
                                            showCheckboxColumn: false,
                                            columnSpacing: 16.0,
                                            headingRowColor:
                                                MaterialStateColor.resolveWith(
                                              (states) => Color.fromARGB(
                                                      255, 16, 31, 123)
                                                  .withOpacity(0.99),
                                            ),
                                            dataRowColor:
                                                MaterialStateColor.resolveWith(
                                              (states) =>
                                                  Colors.grey.withOpacity(0.05),
                                            ),
                                            columns: [
                                              DataColumn(
                                                label: Text(
                                                  'Nombre',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Apellido Paterno',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Apellido Materno',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Matrícula',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Sección',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Grado',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Fecha de Nacimiento',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                            rows: alumnos.map((alumno) {
                                              return DataRow(
                                                cells: [
                                                  DataCell(
                                                      Text(alumno['nombres'])),
                                                  DataCell(Text(
                                                      alumno['apellidoP'])),
                                                  DataCell(Text(
                                                      alumno['apellidoM'])),
                                                  DataCell(Text(
                                                      alumno['matriculaSoc'])),
                                                  DataCell(
                                                      Text(alumno['seccion'])),
                                                  DataCell(
                                                      Text(alumno['grado'])),
                                                  DataCell(Text(
                                                    DateFormat('dd/MM/yyyy')
                                                        .format(
                                                      DateTime.parse(alumno[
                                                          'fechaNacimiento']),
                                                    ),
                                                  )),
                                                ],
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Modo móvil
                    return Column(
                      children: [
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Text(
                                      'Sección',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          5), // Espacio entre el texto y el dropdown
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5),
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
                                    child: DropdownButtonFormField<String>(
                                      value: selectedSeccion,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedSeccion = newValue ?? 'Todos';
                                        });
                                      },
                                      items: [
                                        'Todos',
                                        'Preescolar',
                                        'Primaria',
                                        'Secundaria',
                                        'Preparatoria'
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: TextStyle(fontSize: 12),
                                          ),
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
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Text(
                                      'Grado',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          5), // Espacio entre el texto y el dropdown
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5),
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
                                    child: DropdownButtonFormField<String>(
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
                                          child: Text(
                                            value,
                                            style: TextStyle(fontSize: 12),
                                          ),
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
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 5),
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
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value;
                              });
                            },
                            decoration: InputDecoration(
                              floatingLabelStyle:
                                  TextStyle(color: Colors.black),
                              labelText:
                                  'Buscar por nombre, matrícula o apellidos',
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
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                // Opcional, para agregar sombra
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              // Esto asegura que los bordes redondeados se apliquen a los hijos
                              borderRadius: BorderRadius.circular(12),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: constraints.maxWidth,
                                    ),
                                    child: DataTable(
                                      showCheckboxColumn: false,
                                      columnSpacing: 16.0,
                                      headingRowColor:
                                          MaterialStateColor.resolveWith(
                                        (states) =>
                                            Color.fromARGB(255, 16, 31, 123)
                                                .withOpacity(0.99),
                                      ),
                                      dataRowColor:
                                          MaterialStateColor.resolveWith(
                                        (states) =>
                                            Colors.grey.withOpacity(0.05),
                                      ),
                                      columns: [
                                        DataColumn(
                                            label: Text(
                                          'Matrícula',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        )),
                                        DataColumn(
                                            label: Text(
                                          'Nombre',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        )),
                                        DataColumn(
                                            label: Text(
                                          'Apellido Paterno',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        )),
                                        DataColumn(
                                            label: Text(
                                          'Apellido Materno',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        )),
                                        DataColumn(
                                            label: Text(
                                          'Sección',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        )),
                                        DataColumn(
                                            label: Text(
                                          'Grado',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        )),
                                        DataColumn(
                                            label: Text(
                                          'Fecha de Nacimiento',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        )),
                                      ],
                                      rows: alumnos.map((alumno) {
                                        return DataRow(
                                          cells: [
                                            DataCell(Text(
                                              alumno['matriculaSoc'],
                                              style: TextStyle(fontSize: 12),
                                            )),
                                            DataCell(Text(
                                              alumno['nombres'],
                                              style: TextStyle(fontSize: 12),
                                            )),
                                            DataCell(Text(
                                              alumno['apellidoP'],
                                              style: TextStyle(fontSize: 12),
                                            )),
                                            DataCell(Text(
                                              alumno['apellidoM'],
                                              style: TextStyle(fontSize: 12),
                                            )),
                                            DataCell(Text(
                                              alumno['seccion'],
                                              style: TextStyle(fontSize: 12),
                                            )),
                                            DataCell(Text(
                                              alumno['grado'],
                                              style: TextStyle(fontSize: 12),
                                            )),
                                            DataCell(Text(
                                              DateFormat('dd/MM/yyyy').format(
                                                  DateTime.parse(alumno[
                                                      'fechaNacimiento'])),
                                              style: TextStyle(fontSize: 12),
                                            )),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
