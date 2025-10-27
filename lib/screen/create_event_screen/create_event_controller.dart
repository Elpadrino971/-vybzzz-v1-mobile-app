import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vybzzz/common/service/vybzzz/event_service.dart';
import 'package:vybzzz/model/event_model/vybzzz_event_model.dart';
import 'package:vybzzz/common/controller/auth_controller.dart';
import 'package:image_picker/image_picker.dart';

/// Controller pour la création d'événements VyBzzZ
class CreateEventController extends GetxController {
  final EventService _eventService = EventService();
  final AuthController _authController = Get.find<AuthController>();
  final ImagePicker _picker = ImagePicker();

  // Form controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final venueNameController = TextEditingController();
  final venueAddressController = TextEditingController();

  // Observable states
  final Rx<EventType> eventType = EventType.live.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString coverImagePath = ''.obs;

  // Date & Time
  final Rx<DateTime?> startDateTime = Rx<DateTime?>(null);
  final Rx<DateTime?> endDateTime = Rx<DateTime?>(null);

  // Ticket prices
  final RxDouble virtualPrice = 10.0.obs;
  final RxDouble physicalPrice = 30.0.obs;
  final RxDouble fanbasePrice = 5.0.obs;

  // Ticket quantity
  final RxInt ticketQuantity = 100.obs;

  // Happy Hour
  final RxBool enableHappyHour = false.obs;

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    venueNameController.dispose();
    venueAddressController.dispose();
    super.onClose();
  }

  // ============================================
  // IMAGE PICKER
  // ============================================

  Future<void> pickCoverImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        coverImagePath.value = image.path;
      }
    } catch (e) {
      errorMessage.value = 'Erreur lors de la sélection de l\'image';
      Get.snackbar('Erreur', errorMessage.value);
    }
  }

  // ============================================
  // DATE PICKERS
  // ============================================

  Future<void> selectStartDateTime(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 20, minute: 0),
      );

      if (time != null) {
        startDateTime.value = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        // Auto-set end time to 2 hours later
        if (endDateTime.value == null) {
          endDateTime.value = startDateTime.value!.add(const Duration(hours: 2));
        }
      }
    }
  }

  Future<void> selectEndDateTime(BuildContext context) async {
    if (startDateTime.value == null) {
      Get.snackbar('Erreur', 'Veuillez d\'abord sélectionner la date de début');
      return;
    }

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: startDateTime.value!,
      firstDate: startDateTime.value!,
      lastDate: startDateTime.value!.add(const Duration(days: 1)),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          startDateTime.value!.add(const Duration(hours: 2)),
        ),
      );

      if (time != null) {
        endDateTime.value = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      }
    }
  }

  // ============================================
  // VALIDATION
  // ============================================

  bool _validateForm() {
    if (titleController.text.trim().isEmpty) {
      errorMessage.value = 'Le titre est requis';
      return false;
    }

    if (descriptionController.text.trim().isEmpty) {
      errorMessage.value = 'La description est requise';
      return false;
    }

    if (startDateTime.value == null) {
      errorMessage.value = 'La date de début est requise';
      return false;
    }

    if (endDateTime.value == null) {
      errorMessage.value = 'La date de fin est requise';
      return false;
    }

    if (eventType.value == EventType.physical || eventType.value == EventType.hybrid) {
      if (venueNameController.text.trim().isEmpty) {
        errorMessage.value = 'Le nom de la salle est requis';
        return false;
      }

      if (venueAddressController.text.trim().isEmpty) {
        errorMessage.value = 'L\'adresse de la salle est requise';
        return false;
      }
    }

    if (virtualPrice.value <= 0) {
      errorMessage.value = 'Le prix virtuel doit être supérieur à 0';
      return false;
    }

    if (ticketQuantity.value <= 0) {
      errorMessage.value = 'La quantité de billets doit être supérieure à 0';
      return false;
    }

    return true;
  }

  // ============================================
  // CREATE EVENT
  // ============================================

  Future<void> createEvent() async {
    if (!_validateForm()) {
      Get.snackbar('Erreur', errorMessage.value);
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final currentUser = _authController.currentUser.value;
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Créer l'événement
      final event = VyBzzZEvent(
        artistId: currentUser.id,
        artistName: currentUser.fullname,
        artistPhoto: currentUser.profilePhoto,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        coverImageUrl: coverImagePath.value.isNotEmpty ? coverImagePath.value : null,
        eventType: eventType.value,
        startTime: startDateTime.value,
        endTime: endDateTime.value,
        venueName: venueNameController.text.trim().isNotEmpty
            ? venueNameController.text.trim()
            : null,
        venueAddress: venueAddressController.text.trim().isNotEmpty
            ? venueAddressController.text.trim()
            : null,
        ticketPriceVirtual: virtualPrice.value,
        ticketPricePhysical: physicalPrice.value,
        ticketPriceFanbase: fanbasePrice.value,
        ticketQuantity: ticketQuantity.value,
        isHappyHour: enableHappyHour.value,
      );

      // Calculer les prix Happy Hour si activé
      if (enableHappyHour.value) {
        const discount = 0.25; // 25% de réduction
        event.happyHourPriceVirtual = virtualPrice.value * (1 - discount);
        event.happyHourPricePhysical = physicalPrice.value * (1 - discount);
        event.happyHourPriceFanbase = fanbasePrice.value * (1 - discount);

        // Happy Hour le mercredi prochain à 20h
        final now = DateTime.now();
        var nextWednesday = now;
        while (nextWednesday.weekday != DateTime.wednesday) {
          nextWednesday = nextWednesday.add(const Duration(days: 1));
        }
        event.happyHourStartTime = DateTime(
          nextWednesday.year,
          nextWednesday.month,
          nextWednesday.day,
          20,
          0,
        );
        event.happyHourEndTime = event.happyHourStartTime!.add(const Duration(minutes: 15));
      }

      final createdEvent = await _eventService.createEvent(event);

      isLoading.value = false;

      Get.snackbar(
        'Événement créé',
        'Votre événement a été créé avec succès!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      // Rediriger vers la page de l'événement
      Get.back(result: createdEvent);
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();

      Get.snackbar(
        'Erreur',
        'Impossible de créer l\'événement: $errorMessage',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // ============================================
  // SAVE AS DRAFT
  // ============================================

  Future<void> saveAsDraft() async {
    // Similar to createEvent but keeps status as draft
    // Implementation similar to above
  }
}
