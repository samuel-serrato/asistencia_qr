import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ListaAlumnos extends StatefulWidget {
  @override
  _ListaAlumnosState createState() => _ListaAlumnosState();
}

class _ListaAlumnosState extends State<ListaAlumnos> {
  late Future<List<dynamic>> futureAlumnos;
  String selectedSeccion = 'Todas';
  String selectedGrado = 'Todos';
  String searchQuery = '';

  Future<List<dynamic>> fetchAlumnos() async {
    final response = await http.get(
        Uri.parse('http://localhost:8000/asistencias_api/listaAlumnos.php'));

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

              if (selectedSeccion != 'Todas') {
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
                alumnos = alumnos
                    .where((alumno) =>
                        alumno['nombres']
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()) ||
                        alumno['apellidoP']
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()) ||
                        alumno['apellidoM']
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()) ||
                        alumno['matriculaSoc']
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()))
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
                                      labelText:
                                          'Buscar por nombre, matrícula o apellidos',
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(17)),
                                      fillColor: Colors.white,
                                      filled: true,
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
                          child: Container(
                            height: 400,
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
                                          'Nombre',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )),
                                        DataColumn(
                                            label: Text(
                                          'Apellido Paterno',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )),
                                        DataColumn(
                                            label: Text(
                                          'Apellido Materno',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )),
                                        DataColumn(
                                            label: Text(
                                          'Matrícula',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )),
                                        DataColumn(
                                            label: Text(
                                          'Grado',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )),
                                        DataColumn(
                                            label: Text(
                                          'Sección',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )),
                                        DataColumn(
                                            label: Text(
                                          'Fecha de Nacimiento',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )),
                                      ],
                                      rows: alumnos.map((alumno) {
                                        return DataRow(
                                          cells: [
                                            DataCell(Text(alumno['nombres'])),
                                            DataCell(Text(alumno['apellidoP'])),
                                            DataCell(Text(alumno['apellidoM'])),
                                            DataCell(
                                                Text(alumno['matriculaSoc'])),
                                            DataCell(Text(alumno['grado'])),
                                            DataCell(Text(alumno['seccion'])),
                                            DataCell(Text(alumno[
                                                'fechaNacimiento'])), // Modifica según sea necesario
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
                  } else {
                    // Modo móvil
                    return Column(
                      children: [
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
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
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                            fontSize:
                                                12), // Aquí se establece el tamaño de fuente
                                      ),
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
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Container(
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
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                            fontSize:
                                                12), // Aquí se establece el tamaño de fuente
                                      ),
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
                              labelText:
                                  'Buscar por nombre, matrícula o apellidos',
                              labelStyle: TextStyle(fontSize: 12),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(17)),
                              fillColor: Colors.white,
                              filled: true,
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
                                          'Grado',
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
                                              alumno['grado'],
                                              style: TextStyle(fontSize: 12),
                                            )),
                                            DataCell(Text(
                                              alumno['seccion'],
                                              style: TextStyle(fontSize: 12),
                                            )),
                                            DataCell(Text(
                                              alumno['fechaNacimiento'],
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
