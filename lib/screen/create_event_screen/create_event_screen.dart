import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vybzzz/screen/create_event_screen/create_event_controller.dart';
import 'package:vybzzz/model/event_model/vybzzz_event_model.dart';
import 'package:vybzzz/common/widget/text_button_custom.dart';
import 'package:vybzzz/common/widget/theme_blur_bg.dart';
import 'package:vybzzz/utilities/text_style_custom.dart';
import 'package:vybzzz/utilities/theme_res.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';

/// Écran de création d'événement VyBzzZ
class CreateEventScreen extends StatelessWidget {
  const CreateEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateEventController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: whitePure(context)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Créer un événement',
          style: TextStyleCustom.outFitMedium500(
            fontSize: 18,
            color: whitePure(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => controller.createEvent(),
            child: Obx(() => controller.isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'PUBLIER',
                    style: TextStyleCustom.outFitMedium500(
                      fontSize: 14,
                      color: const Color(0xFFFFD700),
                    ),
                  )),
          ),
        ],
      ),
      body: Stack(
        children: [
          const ThemeBlurBg(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover Image
                  _buildCoverImagePicker(controller, context),
                  const SizedBox(height: 24),

                  // Title
                  _buildTextField(
                    controller: controller.titleController,
                    label: 'Titre du concert',
                    hint: 'Ex: Live Session Acoustic',
                    context: context,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  _buildTextField(
                    controller: controller.descriptionController,
                    label: 'Description',
                    hint: 'Décrivez votre concert...',
                    maxLines: 4,
                    context: context,
                  ),
                  const SizedBox(height: 24),

                  // Event Type
                  _buildEventTypePicker(controller, context),
                  const SizedBox(height: 24),

                  // Dates
                  _buildDateTimePickers(controller, context),
                  const SizedBox(height: 24),

                  // Venue (if physical or hybrid)
                  Obx(() {
                    if (controller.eventType.value == EventType.physical ||
                        controller.eventType.value == EventType.hybrid) {
                      return Column(
                        children: [
                          _buildTextField(
                            controller: controller.venueNameController,
                            label: 'Nom de la salle',
                            hint: 'Ex: Accor Arena',
                            context: context,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: controller.venueAddressController,
                            label: 'Adresse',
                            hint: '8 Bd de Bercy, 75012 Paris',
                            context: context,
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  // Ticket Prices
                  _buildTicketPrices(controller, context),
                  const SizedBox(height: 24),

                  // Ticket Quantity
                  _buildTicketQuantity(controller, context),
                  const SizedBox(height: 24),

                  // Happy Hour Toggle
                  _buildHappyHourToggle(controller, context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImagePicker(
      CreateEventController controller, BuildContext context) {
    return Obx(() => GestureDetector(
          onTap: () => controller.pickCoverImage(),
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: ShapeDecoration(
              color: whitePure(context).withValues(alpha: 0.05),
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius.all(
                  SmoothRadius(cornerRadius: 20, cornerSmoothing: 1),
                ),
                side: BorderSide(
                  color: whitePure(context).withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: controller.coverImagePath.value.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 48,
                        color: whitePure(context).withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Ajouter une image de couverture',
                        style: TextStyleCustom.outFitRegular400(
                          fontSize: 14,
                          color: whitePure(context).withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      File(controller.coverImagePath.value),
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        ));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required BuildContext context,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyleCustom.outFitMedium500(
            fontSize: 14,
            color: whitePure(context),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyleCustom.outFitRegular400(
            fontSize: 16,
            color: whitePure(context),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyleCustom.outFitRegular400(
              fontSize: 16,
              color: whitePure(context).withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: whitePure(context).withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventTypePicker(
      CreateEventController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type d\'événement',
          style: TextStyleCustom.outFitMedium500(
            fontSize: 14,
            color: whitePure(context),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Row(
              children: EventType.values.map((type) {
                final isSelected = controller.eventType.value == type;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => controller.eventType.value = type,
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: ShapeDecoration(
                        color: isSelected
                            ? const Color(0xFFFFD700).withValues(alpha: 0.2)
                            : whitePure(context).withValues(alpha: 0.05),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius.all(
                            SmoothRadius(cornerRadius: 12, cornerSmoothing: 1),
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFFFFD700)
                                : whitePure(context).withValues(alpha: 0.1),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                      ),
                      child: Text(
                        type.displayName,
                        textAlign: TextAlign.center,
                        style: TextStyleCustom.outFitMedium500(
                          fontSize: 12,
                          color: isSelected
                              ? const Color(0xFFFFD700)
                              : whitePure(context).withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
      ],
    );
  }

  Widget _buildDateTimePickers(
      CreateEventController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dates et horaires',
          style: TextStyleCustom.outFitMedium500(
            fontSize: 14,
            color: whitePure(context),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateTimeButton(
                label: 'Début',
                value: controller.startDateTime,
                onTap: () => controller.selectStartDateTime(context),
                context: context,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateTimeButton(
                label: 'Fin',
                value: controller.endDateTime,
                onTap: () => controller.selectEndDateTime(context),
                context: context,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateTimeButton({
    required String label,
    required Rx<DateTime?> value,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return Obx(() => GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: ShapeDecoration(
              color: whitePure(context).withValues(alpha: 0.05),
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius.all(
                  SmoothRadius(cornerRadius: 12, cornerSmoothing: 1),
                ),
                side: BorderSide(
                  color: whitePure(context).withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyleCustom.outFitRegular400(
                    fontSize: 12,
                    color: whitePure(context).withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.value != null
                      ? '${value.value!.day}/${value.value!.month} ${value.value!.hour}:${value.value!.minute.toString().padLeft(2, '0')}'
                      : 'Sélectionner',
                  style: TextStyleCustom.outFitMedium500(
                    fontSize: 14,
                    color: value.value != null
                        ? whitePure(context)
                        : whitePure(context).withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildTicketPrices(
      CreateEventController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prix des billets (€)',
          style: TextStyleCustom.outFitMedium500(
            fontSize: 14,
            color: whitePure(context),
          ),
        ),
        const SizedBox(height: 12),
        _buildPriceSlider(
          label: '🎵 Virtuel',
          value: controller.virtualPrice,
          min: 5,
          max: 100,
          context: context,
        ),
        const SizedBox(height: 12),
        _buildPriceSlider(
          label: '🎫 Physique',
          value: controller.physicalPrice,
          min: 10,
          max: 200,
          context: context,
        ),
        const SizedBox(height: 12),
        _buildPriceSlider(
          label: '👥 Fanbase',
          value: controller.fanbasePrice,
          min: 3,
          max: 50,
          context: context,
        ),
      ],
    );
  }

  Widget _buildPriceSlider({
    required String label,
    required RxDouble value,
    required double min,
    required double max,
    required BuildContext context,
  }) {
    return Obx(() => Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyleCustom.outFitRegular400(
                    fontSize: 14,
                    color: whitePure(context).withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  '${value.value.toStringAsFixed(0)}€',
                  style: TextStyleCustom.outFitMedium500(
                    fontSize: 16,
                    color: const Color(0xFFFFD700),
                  ),
                ),
              ],
            ),
            Slider(
              value: value.value,
              min: min,
              max: max,
              divisions: ((max - min) ~/ 5),
              activeColor: const Color(0xFFFFD700),
              inactiveColor: whitePure(context).withValues(alpha: 0.2),
              onChanged: (newValue) => value.value = newValue,
            ),
          ],
        ));
  }

  Widget _buildTicketQuantity(
      CreateEventController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nombre de billets',
          style: TextStyleCustom.outFitMedium500(
            fontSize: 14,
            color: whitePure(context),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (controller.ticketQuantity.value > 10) {
                      controller.ticketQuantity.value -= 10;
                    }
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                  color: whitePure(context),
                ),
                Expanded(
                  child: Text(
                    '${controller.ticketQuantity.value}',
                    textAlign: TextAlign.center,
                    style: TextStyleCustom.outFitMedium500(
                      fontSize: 24,
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    controller.ticketQuantity.value += 10;
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  color: whitePure(context),
                ),
              ],
            )),
      ],
    );
  }

  Widget _buildHappyHourToggle(
      CreateEventController controller, BuildContext context) {
    return Obx(() => Container(
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: controller.enableHappyHour.value
                ? const Color(0xFFFFD700).withValues(alpha: 0.1)
                : whitePure(context).withValues(alpha: 0.05),
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius.all(
                SmoothRadius(cornerRadius: 12, cornerSmoothing: 1),
              ),
              side: BorderSide(
                color: controller.enableHappyHour.value
                    ? const Color(0xFFFFD700)
                    : whitePure(context).withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚡ Happy Hour',
                      style: TextStyleCustom.outFitMedium500(
                        fontSize: 16,
                        color: whitePure(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mercredi 20h - 25% de réduction pendant 15min',
                      style: TextStyleCustom.outFitRegular400(
                        fontSize: 12,
                        color: whitePure(context).withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: controller.enableHappyHour.value,
                onChanged: (value) => controller.enableHappyHour.value = value,
                activeColor: const Color(0xFFFFD700),
              ),
            ],
          ),
        ));
  }
}
