import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_web_qrcode_scanner/flutter_web_qrcode_scanner.dart';
import 'package:http/http.dart' as http;

class QRScannerPage extends StatefulWidget {
  QRScannerPage();

  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage>
    with SingleTickerProviderStateMixin {
  String _qrCodeResult = 'Escanea un código QR';
  String? _lastQrCodeResult;
  late AnimationController _animationController;
  late CameraController _controller;
  bool _isCameraActive = true;
  List<Map<String, String>> alumnosList = [];
  final List<Map<String, String>> qrCodeList = [];
  String alumnoNombre = '';
  TextEditingController _manualMatriculaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAlumnos();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);

    _controller = CameraController(autoPlay: true);
    _startCamera();
  }

  void _startCamera() {
    try {
      _controller.startVideoStream();
    } catch (e) {
      print("Error starting camera: $e");
    }
  }

  void _stopCamera() {
    try {
      _controller.stopVideoStream();
    } catch (e) {
      print("Error stopping camera: $e");
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _stopCamera();
    _manualMatriculaController.dispose();
    super.dispose();
  }

  void _showQRCodeResult(String result, BuildContext context) {
    if (result.isEmpty) {
      return;
    }
    setState(() {
      _qrCodeResult = result;
      _lastQrCodeResult = result;
    });

    addQrCode(result, context);

    Future.delayed(Duration(seconds: 3), () {
      _stopCamera();
      setState(() {
        _qrCodeResult = 'Escanea un código QR';
        _lastQrCodeResult = null;
      });
      Future.delayed(Duration(milliseconds: 300), () {
        _startCamera();
      });
    });
  }

  // Obtener lista de alumnos
  Future<void> _fetchAlumnos() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.116:8000/asistencias_api/listaAlumnos.php'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          alumnosList = data
              .map((item) => {
                    'matriculaSoc': item['matriculaSoc'].toString(),
                    'nombres': item['nombres'].toString(),
                    'apellidoP': item['apellidoP'].toString(),
                    'apellidoM': item['apellidoM'].toString(),
                  })
              .toList();
        });
      } else {
        throw Exception('Error al cargar la lista de alumnos');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _sendMatricula(String matricula, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.116:8000/asistencias_api/asistencia.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'matriculaSoc': matricula,
        }),
      );

      final message = response.statusCode == 200
          ? 'Matrícula enviada exitosamente.'
          : 'Error al enviar matrícula.';

      _showSuccessDialog(context, message);
    } catch (e) {
      print('Error: $e');
      _showSuccessDialog(context, 'Error al enviar matrícula: $e');
    }
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          contentPadding: EdgeInsets.all(20),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 80,
                ),
                SizedBox(height: 20),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context, rootNavigator: true).pop();
    });
  }

  void addQrCode(String code, BuildContext context) {
    DateTime now = DateTime.now();
    String dateTimeString =
        "${now.day}-${now.month}-${now.year} ${now.hour}:${now.minute}:${now.second}";

    setState(() {
      qrCodeList.add({
        'qrCode': code,
        'dateTime': dateTimeString,
      });
    });

    _sendMatricula(code, context);

    // Buscar el nombre del alumno
    var alumno = alumnosList.firstWhere(
        (alumno) => alumno['matriculaSoc'] == code,
        orElse: () => {'nombres': 'Alumno no encontrado'});

    // Mensajes de depuración
    print('Código escaneado: $code');
    print(
        'Alumno encontrado: ${alumno['nombres']} ${alumno['apellidoP']} ${alumno['apellidoM']}');
    setState(() {
      alumnoNombre =
          '${alumno['nombres']} ${alumno['apellidoP']} ${alumno['apellidoM']}';
    });

    // Limpiar el nombre del alumno después de 5 segundos
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        alumnoNombre = '';
      });
    });
  }

  void _showManualMatriculaDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Text(
            'Ingresar Matrícula Manualmente',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: TextField(
            controller: _manualMatriculaController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1.0), // Borde cuando no está enfocado
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.0), // Borde cuando está enfocado
                borderRadius: BorderRadius.circular(8.0),
              ),
              labelText: 'Matrícula',
              labelStyle: TextStyle(color: Colors.blue),
            ),
            keyboardType: TextInputType.text,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.redAccent),
                overlayColor: MaterialStateProperty.all(
                  Colors.redAccent.withOpacity(0.1),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _handleManualMatricula();
                Navigator.of(context).pop();
              },
              child: Text('Enviar'),
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.blue),
                overlayColor: MaterialStateProperty.all(
                  Colors.blue.withOpacity(0.1),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleManualMatricula() {
    final matricula = _manualMatriculaController.text.trim();
    if (matricula.isNotEmpty) {
      _sendMatricula(matricula, context);
      _manualMatriculaController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
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
            backgroundColor:
                Colors.transparent, // Haz el fondo del AppBar transparente
            elevation: 0, // Elimina la sombra del AppBar
            title: Center(
              child: Text(
                'Asistencia',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _qrCodeResult,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                alumnoNombre,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              Container(
                width: isMobile ? size.width * 0.8 : size.width * 0.28,
                height: isMobile ? size.height * 0.5 : size.height * 0.5,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    FlutterWebQrcodeScanner(
                      controller: _controller,
                      width: isMobile ? size.width * 0.9 : size.width * 0.6,
                      height: isMobile ? size.height * 0.5 : size.height * 0.5,
                      cameraDirection: CameraDirection.back,
                      stopOnFirstResult: false,
                      onGetResult: (result) {
                        if (_lastQrCodeResult != result && result.isNotEmpty) {
                          _showQRCodeResult(result, context);
                        }
                      },
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: CustomPaint(
                        painter: ScannerOverlayPainter(),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Positioned(
                          top: _animationController.value *
                              (isMobile
                                  ? size.height * 0.5 - 50
                                  : size.height * 0.5 - 50),
                          left: 0,
                          right: 0,
                          child: Opacity(
                            opacity: 0.8,
                            child: Container(
                              width: size.width * 0.8,
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.red,
                                    Colors.transparent,
                                  ],
                                  stops: [0.1, 0.5, 0.9],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Botón para abrir el diálogo
              TextButton(
                onPressed: _showManualMatriculaDialog,
                style: ButtonStyle(
                  overlayColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.hovered)) {
                        return Colors.white.withOpacity(
                            0); // Color cuando el cursor está encima
                      }
                      return null; // Sin color de overlay por defecto
                    },
                  ),
                  foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.hovered)) {
                        return Color(
                            0xFFB80000); // Color del texto cuando está encima
                      }
                      return Colors.black; // Color del texto por defecto
                    },
                  ),
                ),
                child: Text(
                  'Escribir matrículaa',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton.extended(
              backgroundColor: Color(0xFFB80000),
              onPressed: () {
                _stopCamera(); // Detener la cámara antes de navegar
                Navigator.pushNamed(context, '/screen1').then((_) {
                  _startCamera(); // Reanudar la cámara al regresar
                });
              },
              icon: Icon(
                Icons.table_chart,
                color: Colors.white,
              ),
              label: Text(
                'Alumnos',
                style: TextStyle(color: Colors.white),
              ),
            ),
            FloatingActionButton.extended(
              backgroundColor: Color(0xFFB80000),
              onPressed: () {
                _stopCamera(); // Detener la cámara antes de navegar
                Navigator.pushNamed(context, '/screen2').then((_) {
                  _startCamera(); // Reanudar la cámara al regresar
                });
              },
              icon: Icon(
                Icons.list,
                color: Colors.white,
              ),
              label: Text(
                'Asistencia',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Screen1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Screen 1'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Go Back to Scanner'),
        ),
      ),
    );
  }
}

class Screen2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Screen 2'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Go Back to Scanner'),
        ),
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color.fromARGB(255, 0, 66, 190)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final cornerLength = 20.0;
    final cornerRadius = 8.0;

    canvas.drawLine(Offset(cornerRadius, 0), Offset(cornerLength, 0), paint);
    canvas.drawLine(Offset(0, cornerRadius), Offset(0, cornerLength), paint);
    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(cornerRadius, cornerRadius), radius: cornerRadius),
      3.14,
      3.14 / 2,
      false,
      paint,
    );

    canvas.drawLine(Offset(size.width - cornerRadius, 0),
        Offset(size.width - cornerLength, 0), paint);
    canvas.drawLine(Offset(size.width, cornerRadius),
        Offset(size.width, cornerLength), paint);
    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(size.width - cornerRadius, cornerRadius),
          radius: cornerRadius),
      -3.14 / 2,
      3.14 / 2,
      false,
      paint,
    );

    canvas.drawLine(Offset(cornerRadius, size.height),
        Offset(cornerLength, size.height), paint);
    canvas.drawLine(Offset(0, size.height - cornerRadius),
        Offset(0, size.height - cornerLength), paint);
    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(cornerRadius, size.height - cornerRadius),
          radius: cornerRadius),
      3.14 / 2,
      3.14 / 2,
      false,
      paint,
    );

    canvas.drawLine(Offset(size.width - cornerRadius, size.height),
        Offset(size.width - cornerLength, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height - cornerRadius),
        Offset(size.width, size.height - cornerLength), paint);
    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(size.width - cornerRadius, size.height - cornerRadius),
          radius: cornerRadius),
      0,
      3.14 / 2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
