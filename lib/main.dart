import 'package:asistencia_qr/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_qrcode_scanner/flutter_web_qrcode_scanner.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<Map<String, String>> qrCodeList = [];

  void addQrCode(String code) {
    DateTime now = DateTime.now();
    String dateTimeString = "${now.day}-${now.month}-${now.year} ${now.hour}:${now.minute}:${now.second}";

    setState(() {
      qrCodeList.add({
        'qrCode': code,
        'dateTime': dateTimeString,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: QRScannerPage(addQrCode: addQrCode),
      routes: {
        '/home': (context) => HomePage(qrCodeList: qrCodeList),
      },
    );
  }
}

class QRScannerPage extends StatefulWidget {
  final Function(String) addQrCode;

  QRScannerPage({required this.addQrCode});

  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage>
    with SingleTickerProviderStateMixin {
  String _qrCodeResult = 'Escanea un código QR';
  String? _lastQrCodeResult;
  late AnimationController _animationController;
  CameraController _controller = CameraController(autoPlay: true);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _showQRCodeResult(String result) {
    if (result.isEmpty) {
      return; // No hacer nada si el resultado está vacío
    }
    setState(() {
      _qrCodeResult = result;
      _lastQrCodeResult = result;
    });

    widget.addQrCode(result);

    // Mostrar SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Código QR escaneado: $result'),
      ),
    );

    // Reinicia el escáner después de 1 segundo para detectar el mismo QR de nuevo
    Future.delayed(Duration(seconds: 1), () {
      _controller.stopVideoStream();
      setState(() {
        _qrCodeResult = 'Escanea un código QR';
        _lastQrCodeResult = null; // Reiniciar el último resultado de QR
      });
      Future.delayed(Duration(milliseconds: 100), () {
        _controller.startVideoStream();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600; // Define un ancho de corte para móvil

    return Scaffold(
      appBar: AppBar(
        title: Text('QR Scanner'),
        centerTitle: true,
      ),
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
              SizedBox(height: 40),
              Container(
                width: isMobile ? size.width * 0.8 : size.width * 0.28,
                height: isMobile ? size.height * 0.3 : size.height * 0.5, // Ajuste para móvil
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
                      height: isMobile ? size.height * 0.3 : size.height * 0.5, // Ajuste para móvil
                      cameraDirection: CameraDirection.back,
                      stopOnFirstResult: false,
                      onGetResult: (result) {
                        if (_lastQrCodeResult != result && result.isNotEmpty) {
                          _showQRCodeResult(result);
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
                              (isMobile ? size.height * 0.3 : size.height * 0.5 - 50),
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
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/home');
        },
        child: Icon(Icons.table_chart),
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

    // Esquinas superiores izquierdas
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

    // Esquinas superiores derechas
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

    // Esquinas inferiores izquierdas
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

    // Esquinas inferiores derechas
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
