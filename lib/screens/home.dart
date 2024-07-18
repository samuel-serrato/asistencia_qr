import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final List<Map<String, String>> qrCodeList;

  HomePage({required this.qrCodeList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tabla de Códigos QR Escaneados'),
      ),
      body: Center(
        child: qrCodeList.isEmpty
            ? Text('No se ha escaneado ningún código QR.')
            : DataTable(
                columns: [
                  DataColumn(label: Text('Código QR')),
                  DataColumn(label: Text('Fecha y Hora')),
                ],
                rows: qrCodeList
                    .map((qrCode) => DataRow(cells: [
                          DataCell(Text(qrCode['qrCode']!)),
                          DataCell(Text(qrCode['dateTime']!)),
                        ]))
                    .toList(),
              ),
      ),
    );
  }
}
