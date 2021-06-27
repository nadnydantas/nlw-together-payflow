import 'package:camera/camera.dart';

class BarcodeScannerStatus {
  final bool isCameraAvailable;
  final String error;
  final String barcode;
  final bool stopScanner;

  // Construtor default
  BarcodeScannerStatus({
    this.isCameraAvailable = false,
    this.error = "",
    this.barcode = "",
    this.stopScanner = false,
  });

  // Construtor para quando a câmera estiver ativa
  factory BarcodeScannerStatus.available() =>
      BarcodeScannerStatus(
        isCameraAvailable: true,
        stopScanner: false,
      );

  // Construtor para quando houver erro
  factory BarcodeScannerStatus.error(String message) => BarcodeScannerStatus(
        error: message,
        stopScanner: true,
      );

  // Construtor para quando for armazenar um barcode
  factory BarcodeScannerStatus.barcode(String barcode) => BarcodeScannerStatus(
        barcode: barcode,
        stopScanner: true,
      );

  bool get showCamera => isCameraAvailable && error.isEmpty;

  bool get hasError => error.isNotEmpty;

  bool get hasBarcode => barcode.isNotEmpty;
}
