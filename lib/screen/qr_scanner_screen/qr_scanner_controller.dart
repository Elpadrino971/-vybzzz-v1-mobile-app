import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vybzzz/common/service/vybzzz/ticket_service.dart';
import 'package:vybzzz/model/ticket_model/ticket_model.dart';

/// Contrôleur pour le scanner de QR codes
class QRScannerController extends GetxController {
  final TicketService _ticketService = TicketService();

  // Scanner controller
  late MobileScannerController scannerController;

  // État
  final RxBool isScanning = true.obs;
  final RxBool isLoading = false.obs;
  final Rx<TicketModel?> scannedTicket = Rx<TicketModel?>(null);
  final RxString errorMessage = ''.obs;

  // Stats
  final RxInt totalScanned = 0.obs;
  final RxInt validScanned = 0.obs;
  final RxInt invalidScanned = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initScanner();
  }

  void _initScanner() {
    scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void onClose() {
    scannerController.dispose();
    super.onClose();
  }

  // ============================================
  // SCAN QR CODE
  // ============================================

  Future<void> onQRCodeDetected(BarcodeCapture capture) async {
    if (!isScanning.value || isLoading.value) return;

    final List<Barcode> barcodes = capture.barcodes;

    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;

    if (code == null || code.isEmpty) return;

    // Pause scanning during validation
    isScanning.value = false;
    isLoading.value = true;

    await _validateQRCode(code);

    isLoading.value = false;
  }

  Future<void> _validateQRCode(String qrCode) async {
    try {
      // Valider le format du QR code
      if (!qrCode.startsWith('VYBZZZ_')) {
        _showError('QR code invalide', 'Ce n\'est pas un billet VyBzzZ');
        totalScanned.value++;
        invalidScanned.value++;
        return;
      }

      // Récupérer le billet
      final ticket = await _ticketService.getTicketByQRCode(qrCode);

      if (ticket == null) {
        _showError('Billet introuvable', 'Ce billet n\'existe pas');
        totalScanned.value++;
        invalidScanned.value++;
        return;
      }

      scannedTicket.value = ticket;

      // Vérifier si le billet peut être scanné
      if (!ticket.canBeScanned) {
        String message = '';

        switch (ticket.status) {
          case TicketStatus.used:
            message = 'Ce billet a déjà été utilisé';
            break;
          case TicketStatus.refunded:
            message = 'Ce billet a été remboursé';
            break;
          case TicketStatus.cancelled:
            message = 'Ce billet a été annulé';
            break;
          default:
            // Check time window
            if (ticket.eventStartTime != null) {
              final now = DateTime.now();
              final scanStartTime = ticket.eventStartTime!
                  .subtract(const Duration(hours: 2));

              if (now.isBefore(scanStartTime)) {
                final diff = scanStartTime.difference(now);
                final hours = diff.inHours;
                final minutes = diff.inMinutes % 60;
                message = 'Scan disponible dans ${hours}h ${minutes}min';
              } else {
                message = 'Billet non valide';
              }
            } else {
              message = 'Billet non valide';
            }
        }

        _showError('Billet non valide', message);
        totalScanned.value++;
        invalidScanned.value++;
        return;
      }

      // Marquer le billet comme utilisé
      await _ticketService.markTicketAsUsed(ticket.id!);
      ticket.status = TicketStatus.used;
      ticket.scannedAt = DateTime.now();

      // Succès!
      _showSuccess(ticket);
      totalScanned.value++;
      validScanned.value++;
    } catch (e) {
      _showError('Erreur', 'Erreur lors de la validation: $e');
      totalScanned.value++;
      invalidScanned.value++;
    }
  }

  void _showSuccess(TicketModel ticket) {
    Get.bottomSheet(
      _ValidationResultSheet(
        isSuccess: true,
        ticket: ticket,
        onDismiss: resumeScanning,
      ),
      isDismissible: false,
      enableDrag: false,
    );
  }

  void _showError(String title, String message) {
    Get.bottomSheet(
      _ValidationResultSheet(
        isSuccess: false,
        errorTitle: title,
        errorMessage: message,
        onDismiss: resumeScanning,
      ),
      isDismissible: false,
      enableDrag: false,
    );
  }

  // ============================================
  // CONTROLS
  // ============================================

  void resumeScanning() {
    scannedTicket.value = null;
    errorMessage.value = '';
    isScanning.value = true;
  }

  void toggleTorch() {
    scannerController.toggleTorch();
  }

  void switchCamera() {
    scannerController.switchCamera();
  }

  void resetStats() {
    totalScanned.value = 0;
    validScanned.value = 0;
    invalidScanned.value = 0;
  }
}

/// Bottom sheet pour afficher le résultat de la validation
class _ValidationResultSheet extends StatelessWidget {
  final bool isSuccess;
  final TicketModel? ticket;
  final String? errorTitle;
  final String? errorMessage;
  final VoidCallback onDismiss;

  const _ValidationResultSheet({
    required this.isSuccess,
    this.ticket,
    this.errorTitle,
    this.errorMessage,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: isSuccess
                      ? const Color(0xFF00C853).withValues(alpha: 0.2)
                      : const Color(0xFFE50914).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: isSuccess ? const Color(0xFF00C853) : const Color(0xFFE50914),
                  size: 60,
                ),
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                isSuccess ? 'Billet valide !' : (errorTitle ?? 'Erreur'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 12),

              // Message
              if (isSuccess && ticket != null) ...[
                Text(
                  'Type: ${ticket!.ticketType?.displayName ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Montant: ${ticket!.pricePaid?.toStringAsFixed(2)}€',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ] else ...[
                Text(
                  errorMessage ?? 'Une erreur est survenue',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],

              const SizedBox(height: 30),

              // Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: onDismiss,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'CONTINUER',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
