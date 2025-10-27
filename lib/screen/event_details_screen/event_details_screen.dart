import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vybzzz/screen/event_details_screen/event_details_controller.dart';
import 'package:vybzzz/model/event_model/vybzzz_event_model.dart';
import 'package:vybzzz/common/widget/text_button_custom.dart';
import 'package:vybzzz/utilities/text_style_custom.dart';
import 'package:vybzzz/utilities/theme_res.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

/// Écran de détails d'événement avec achat de billets
class EventDetailsScreen extends StatelessWidget {
  const EventDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventDetailsController());

    return Scaffold(
      body: Obx(() {
        final event = controller.event.value;
        if (event == null) {
          return const Center(child: Text('Événement introuvable'));
        }

        return Stack(
          children: [
            // Content
            CustomScrollView(
              slivers: [
                // Cover Image
                _buildCoverImage(event, context),

                // Details
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Live/Upcoming badge
                        if (event.status == EventStatus.live)
                          _buildLiveBadge(context),

                        // Title
                        Text(
                          event.title ?? 'Concert',
                          style: TextStyleCustom.outFitMedium500(
                            fontSize: 28,
                            color: whitePure(context),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Artist
                        _buildArtistInfo(event, context),

                        const SizedBox(height: 24),

                        // Event Info
                        _buildEventInfo(event, context),

                        const SizedBox(height: 24),

                        // Description
                        if (event.description != null) ...[
                          Text(
                            'À propos',
                            style: TextStyleCustom.outFitMedium500(
                              fontSize: 18,
                              color: whitePure(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            event.description!,
                            style: TextStyleCustom.outFitRegular400(
                              fontSize: 15,
                              color: whitePure(context).withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Happy Hour
                        if (controller.isHappyHourActive)
                          _buildHappyHourBanner(context),

                        // Ticket Selection
                        _buildTicketSelection(controller, event, context),

                        const SizedBox(height: 100), // Space for bottom bar
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Bottom Purchase Bar
            _buildBottomPurchaseBar(controller, context),

            // Back button
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCoverImage(VyBzzZEvent event, BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: false,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: event.coverImageUrl != null
            ? CachedNetworkImage(
                imageUrl: event.coverImageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: whitePure(context).withValues(alpha: 0.1),
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFFD700).withValues(alpha: 0.3),
                        const Color(0xFFFF8C00).withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Text('🎵', style: TextStyle(fontSize: 80)),
                  ),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFFD700).withValues(alpha: 0.3),
                      const Color(0xFFFF8C00).withValues(alpha: 0.3),
                    ],
                  ),
                ),
                child: const Center(
                  child: Text('🎵', style: TextStyle(fontSize: 80)),
                ),
              ),
      ),
    );
  }

  Widget _buildLiveBadge(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: ShapeDecoration(
        color: const Color(0xFFE50914).withValues(alpha: 0.2),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.all(
            SmoothRadius(cornerRadius: 12, cornerSmoothing: 1),
          ),
          side: const BorderSide(
            color: Color(0xFFE50914),
            width: 2,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFFE50914),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'EN DIRECT MAINTENANT',
            style: TextStyleCustom.outFitMedium500(
              fontSize: 14,
              color: const Color(0xFFE50914),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistInfo(VyBzzZEvent event, BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: event.artistPhoto != null
              ? CachedNetworkImageProvider(event.artistPhoto!)
              : null,
          child: event.artistPhoto == null
              ? const Icon(Icons.person, size: 24)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.artistName ?? 'Artiste',
                style: TextStyleCustom.outFitMedium500(
                  fontSize: 16,
                  color: whitePure(context),
                ),
              ),
              Text(
                event.eventType?.displayName ?? '',
                style: TextStyleCustom.outFitRegular400(
                  fontSize: 13,
                  color: whitePure(context).withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        // Follow button could go here
      ],
    );
  }

  Widget _buildEventInfo(VyBzzZEvent event, BuildContext context) {
    return Column(
      children: [
        _buildInfoRow(
          icon: Icons.calendar_today,
          label: 'Date',
          value: event.startTime != null
              ? DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(event.startTime!)
              : 'À définir',
          context: context,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          icon: Icons.access_time,
          label: 'Heure',
          value: event.startTime != null
              ? DateFormat('HH:mm').format(event.startTime!)
              : 'À définir',
          context: context,
        ),
        if (event.venueName != null) ...[
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.location_on,
            label: 'Lieu',
            value: event.venueName!,
            context: context,
          ),
        ],
        const SizedBox(height: 12),
        _buildInfoRow(
          icon: Icons.people,
          label: 'Billets vendus',
          value: '${event.ticketsSold ?? 0} / ${event.ticketQuantity ?? 0}',
          context: context,
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required BuildContext context,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFFFFD700),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyleCustom.outFitRegular400(
                  fontSize: 12,
                  color: whitePure(context).withValues(alpha: 0.6),
                ),
              ),
              Text(
                value,
                style: TextStyleCustom.outFitMedium500(
                  fontSize: 15,
                  color: whitePure(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHappyHourBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF8C00),
            Color(0xFFFFD700),
          ],
        ),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.all(
            SmoothRadius(cornerRadius: 16, cornerSmoothing: 1),
          ),
        ),
      ),
      child: Row(
        children: [
          const Text('⚡', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HAPPY HOUR EN COURS !',
                  style: TextStyleCustom.outFitMedium500(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '-25% sur tous les billets pendant 15 minutes',
                  style: TextStyleCustom.outFitRegular400(
                    fontSize: 13,
                    color: Colors.black.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketSelection(
    EventDetailsController controller,
    VyBzzZEvent event,
    BuildContext context,
  ) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choisir vos billets',
              style: TextStyleCustom.outFitMedium500(
                fontSize: 20,
                color: whitePure(context),
              ),
            ),
            const SizedBox(height: 16),

            // Virtual Ticket
            if (event.ticketPriceVirtual != null)
              _buildTicketOption(
                type: TicketType.virtual,
                price: event.getCurrentPrice(TicketType.virtual),
                controller: controller,
                context: context,
              ),

            const SizedBox(height: 12),

            // Physical Ticket
            if (event.ticketPricePhysical != null)
              _buildTicketOption(
                type: TicketType.physical,
                price: event.getCurrentPrice(TicketType.physical),
                controller: controller,
                context: context,
              ),

            const SizedBox(height: 12),

            // Fanbase Ticket
            if (event.ticketPriceFanbase != null)
              _buildTicketOption(
                type: TicketType.fanbase,
                price: event.getCurrentPrice(TicketType.fanbase),
                controller: controller,
                context: context,
              ),

            // Quantity selector
            if (controller.selectedTicketType.value != null) ...[
              const SizedBox(height: 24),
              _buildQuantitySelector(controller, context),
            ],
          ],
        ));
  }

  Widget _buildTicketOption({
    required TicketType type,
    required double? price,
    required EventDetailsController controller,
    required BuildContext context,
  }) {
    final isSelected = controller.selectedTicketType.value == type;

    return GestureDetector(
      onTap: () => controller.selectTicketType(type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: isSelected
              ? const Color(0xFFFFD700).withValues(alpha: 0.2)
              : whitePure(context).withValues(alpha: 0.05),
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius.all(
              SmoothRadius(cornerRadius: 16, cornerSmoothing: 1),
            ),
            side: BorderSide(
              color: isSelected
                  ? const Color(0xFFFFD700)
                  : whitePure(context).withValues(alpha: 0.1),
              width: isSelected ? 2 : 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: ShapeDecoration(
                color: isSelected
                    ? const Color(0xFFFFD700).withValues(alpha: 0.3)
                    : whitePure(context).withValues(alpha: 0.1),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius.all(
                    SmoothRadius(cornerRadius: 12, cornerSmoothing: 1),
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  _getTicketEmoji(type),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.displayName,
                    style: TextStyleCustom.outFitMedium500(
                      fontSize: 16,
                      color: isSelected
                          ? const Color(0xFFFFD700)
                          : whitePure(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    type.description,
                    style: TextStyleCustom.outFitRegular400(
                      fontSize: 12,
                      color: whitePure(context).withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Price
            Text(
              '${price?.toStringAsFixed(2) ?? '0'}€',
              style: TextStyleCustom.outFitMedium500(
                fontSize: 18,
                color: isSelected
                    ? const Color(0xFFFFD700)
                    : whitePure(context),
              ),
            ),

            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xFFFFD700),
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector(
    EventDetailsController controller,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: whitePure(context).withValues(alpha: 0.05),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.all(
            SmoothRadius(cornerRadius: 16, cornerSmoothing: 1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Quantité',
            style: TextStyleCustom.outFitMedium500(
              fontSize: 16,
              color: whitePure(context),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: controller.decrementQuantity,
                icon: const Icon(Icons.remove_circle_outline),
                color: whitePure(context),
              ),
              Container(
                width: 50,
                alignment: Alignment.center,
                child: Obx(() => Text(
                      controller.ticketQuantity.value.toString(),
                      style: TextStyleCustom.outFitMedium500(
                        fontSize: 20,
                        color: const Color(0xFFFFD700),
                      ),
                    )),
              ),
              IconButton(
                onPressed: controller.incrementQuantity,
                icon: const Icon(Icons.add_circle_outline),
                color: whitePure(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPurchaseBar(
    EventDetailsController controller,
    BuildContext context,
  ) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: whitePure(context).withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: Obx(() => Row(
              children: [
                // Price
                if (controller.selectedTicketType.value != null) ...[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total',
                          style: TextStyleCustom.outFitRegular400(
                            fontSize: 13,
                            color: whitePure(context).withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          '${controller.totalPrice.toStringAsFixed(2)}€',
                          style: TextStyleCustom.outFitMedium500(
                            fontSize: 24,
                            color: const Color(0xFFFFD700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                ],

                // Button
                Expanded(
                  flex: 2,
                  child: controller.isEventLive
                      ? TextButtonCustom(
                          name: 'REJOINDRE LE LIVE',
                          onTap: () {
                            // TODO: Navigate to live concert
                          },
                          backgroundColor: const Color(0xFFE50914),
                          textColor: Colors.white,
                        )
                      : TextButtonCustom(
                          name: controller.isPurchasing.value
                              ? 'ACHAT...'
                              : 'ACHETER',
                          onTap: controller.canPurchase && !controller.isPurchasing.value
                              ? controller.purchaseTicket
                              : null,
                          backgroundColor: controller.canPurchase
                              ? const Color(0xFFFFD700)
                              : Colors.grey,
                          textColor: Colors.black,
                        ),
                ),
              ],
            )),
      ),
    );
  }

  String _getTicketEmoji(TicketType type) {
    switch (type) {
      case TicketType.virtual:
        return '🎵';
      case TicketType.physical:
        return '🎫';
      case TicketType.fanbase:
        return '👥';
    }
  }
}
