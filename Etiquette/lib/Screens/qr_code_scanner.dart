import 'package:flutter/material.dart';
import 'dart:io';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRCodeScanner extends StatefulWidget {
  const QRCodeScanner({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRCodeScanner();
}

class _QRCodeScanner extends State<QRCodeScanner> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? barcode;
  QRViewController? controller;

  @override
  void reassemble() async {
    super.reassemble();
    if (Platform.isAndroid) {
      await controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR 코드 스캐너'),
        backgroundColor: Colors.white24,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget> [
          buildQrView(context),
          Positioned(
            bottom: 10,
            child: buildResult(),
          ),
        ],
      ),
    );
  }

  Widget buildResult() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white24,
      ),
      child: const Text(
        'Scan Code!',
        maxLines: 3,
      ),
    );
  }

  Widget buildQrView(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Theme.of(context).colorScheme.secondary,
        borderRadius: 10,
        borderLength: 20,
        borderWidth: 10,
        cutOutSize: MediaQuery.of(context).size.width * 0.8,
      ),
    );
  }

  void onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen( // QR 코드 인식 시 QR 코드 내용을 이전 화면에 전달하고 스캐너 종료
            (barcode) => setState(() {
          this.barcode = barcode;
          this.controller!.pauseCamera();
          Navigator.pop(context, this.barcode?.code);
        })
    );
    this.controller!.pauseCamera();
    this.controller!.resumeCamera();
  }
}