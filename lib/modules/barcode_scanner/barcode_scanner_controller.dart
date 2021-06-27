import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:payflow/modules/barcode_scanner/barcode_scanner_status.dart';

class BarcodeScannerController {
  // Gerência de estado com ValueNotifier
  final statusNotifier =
      ValueNotifier<BarcodeScannerStatus>(BarcodeScannerStatus());
  BarcodeScannerStatus get status => statusNotifier.value;
  set status(BarcodeScannerStatus status) => statusNotifier.value = status;

  // Instanciar um barcode vision
  final barcodeScanner = GoogleMlKit.vision.barcodeScanner();

  CameraController? cameraController;

  // Função para verificar se o dispositivo tem câmeras disponíveis para uso
  void getAvailableCameras() async {
    try {
      // A função availableCameras() retorna uma lista de câmeras
      final response = await availableCameras();

      // Pegar a câmera de trás
      final camera = response.firstWhere(
          (element) => element.lensDirection == CameraLensDirection.back);

      // Instanciar o controller
      cameraController = CameraController(
        camera,
        ResolutionPreset.max,
        enableAudio: false,
      );
      // Inicializar a camera
      await cameraController!.initialize();

      // Chamar o processo de escanear o barcode
      scanWithCamera();

      // Chamar a função para ouvir o stream da imagem
      listenCamera();
    } catch (e) {
      status =
          BarcodeScannerStatus.error(e.toString()); // Pegar o erro para exibir
    }
  }

  // Função para escanear baseado na nossa camera
  void scanWithCamera() {
    // Isto significa que esta variável está ok para utilizar
    status = BarcodeScannerStatus.available();
    Future.delayed(Duration(seconds: 20)).then((value) {
      if (status.hasBarcode == false)
        status = BarcodeScannerStatus.error("Timeout de leitura de boleto");
    });
  }

  // Função para chamar o imagepicker e fazer o processo de leitura
  void scanWithImagePicker() async {
    final response = await ImagePicker().getImage(source: ImageSource.gallery);
    final inputImage = InputImage.fromFilePath(response!.path);
    scannerBarCode(inputImage);
  }

  // Função para processar a leitura do barcode
  Future<void> scannerBarCode(InputImage inputImage) async {
    try {
      // Usar a variável do GoogleMLKit para processar a imagem lida
      final barcodes = await barcodeScanner.processImage(inputImage);
      var barcode;
      for (Barcode item in barcodes) {
        barcode = item.value.displayValue;
      }

      if (barcode != null && status.barcode.isEmpty) {
        // Processo de leitura do barcode foi concluído
        status = BarcodeScannerStatus.barcode(barcode);
        cameraController!.dispose();
        // Quando encontrar o barcode, finalizar o barcodeScanner
        await barcodeScanner.close();
      }

      return;
    } catch (e) {
      print("ERRO DA LEITURA $e");
    }
  }

  // Função para ouvir a imagem que está vindo da câmera
  void listenCamera() {
    // Verifica se tem alguem ouvindo a imagem; Se não estiver, vamos startar imagestream
    if (cameraController!.value.isStreamingImages == false)
      cameraController!.startImageStream((cameraImage) async {
        if (status.stopScanner == false) {
          // Vamos converter a imagem da camera para passar para a função de scannerBarCode
          try {
            final WriteBuffer allBytes = WriteBuffer();
            for (Plane plane in cameraImage.planes) {
              allBytes.putUint8List(plane.bytes);
            }
            final bytes = allBytes.done().buffer.asUint8List();
            final Size imageSize = Size(
                cameraImage.width.toDouble(), cameraImage.height.toDouble());
            final InputImageRotation imageRotation =
                InputImageRotation.Rotation_0deg;
            final InputImageFormat inputImageFormat =
                InputImageFormatMethods.fromRawValue(cameraImage.format.raw) ??
                    InputImageFormat.NV21;
            final planeData = cameraImage.planes.map(
              (Plane plane) {
                return InputImagePlaneMetadata(
                  bytesPerRow: plane.bytesPerRow,
                  height: plane.height,
                  width: plane.width,
                );
              },
            ).toList();

            final inputImageData = InputImageData(
              size: imageSize,
              imageRotation: imageRotation,
              inputImageFormat: inputImageFormat,
              planeData: planeData,
            );

            // Imagem da camera convertida, pronta para enviar para scannerBarCode
            final inputImageCamera = InputImage.fromBytes(
                bytes: bytes, inputImageData: inputImageData);

            scannerBarCode(inputImageCamera);
          } catch (e) {
            print(e);
          }
        }
      });
  }

  // Finalizar os processos que foram abertos
  void dispose() {
    statusNotifier.dispose();
    barcodeScanner.close();
    if (status.showCamera) {
      cameraController!.dispose();
    }
  }
}
