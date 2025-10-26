import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vybzzz/screen/home_screen/event_feed_controller.dart';
import 'package:vybzzz/model/event_model/vybzzz_event_model.dart';
import 'package:vybzzz/common/widget/theme_blur_bg.dart';
import 'package:vybzzz/utilities/text_style_custom.dart';
import 'package:vybzzz/utilities/theme_res.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

/// Écran principal du feed d'événements VyBzzZ
class EventFeedScreen extends StatelessWidget {
  const EventFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventFeedController());

    return Scaffold(
      body: Stack(
        children: [
          const ThemeBlurBg(),
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(controller, context),

                // Filters
                _buildFilterTabs(controller, context),

                // Event List
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final events = controller.filteredEvents;

                    if (events.isEmpty) {
                      return _buildEmptyState(controller, context);
                    }

                    return RefreshIndicator(
                      onRefresh: controller.refreshEvents,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          return _EventCard(event: events[index]);
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/create-event'),
        backgroundColor: const Color(0xFFFFD700),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Concert'),
      ),
    );
  }

  Widget _buildHeader(EventFeedController controller, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VyBzzZ',
                  style: TextStyleCustom.unboundedBlack900(
                    fontSize: 28,
                    color: whitePure(context),
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() => Text(
                      controller.hasLiveEvents
                          ? '🔴 ${controller.totalLive} concerts live'
                          : '${controller.totalUpcoming} concerts à venir',
                      style: TextStyleCustom.outFitRegular400(
                        fontSize: 13,
                        color: controller.hasLiveEvents
                            ? const Color(0xFFE50914)
                            : whitePure(context).withValues(alpha: 0.7),
                      ),
                    )),
              ],
            ),
          ),
          // Search/Filter Icon
          IconButton(
            onPressed: () {
              // TODO: Show filter sheet
            },
            icon: Icon(
              Icons.tune,
              color: whitePure(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(EventFeedController controller, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: '🔥 Live',
                  count: controller.totalLive,
                  isSelected: controller.selectedFilter.value == 'live',
                  onTap: () => controller.changeFilter('live'),
                  context: context,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: '🎵 À venir',
                  count: controller.totalUpcoming,
                  isSelected: controller.selectedFilter.value == 'upcoming',
                  onTap: () => controller.changeFilter('upcoming'),
                  context: context,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: '📺 Replays',
                  count: controller.totalReplay,
                  isSelected: controller.selectedFilter.value == 'replay',
                  onTap: () => controller.changeFilter('replay'),
                  context: context,
                ),
              ],
            ),
          )),
    );
  }

  Widget _buildEmptyState(EventFeedController controller, BuildContext context) {
    String message;
    String emoji;

    switch (controller.selectedFilter.value) {
      case 'live':
        message = 'Aucun concert live pour le moment';
        emoji = '🎤';
        break;
      case 'replay':
        message = 'Aucun replay disponible';
        emoji = '📺';
        break;
      default:
        message = 'Aucun concert à venir';
        emoji = '🎵';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyleCustom.outFitMedium500(
              fontSize: 16,
              color: whitePure(context).withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final BuildContext context;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: ShapeDecoration(
          color: isSelected
              ? const Color(0xFFFFD700).withValues(alpha: 0.2)
              : whitePure(context).withValues(alpha: 0.05),
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius.all(
              SmoothRadius(cornerRadius: 20, cornerSmoothing: 1),
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
            Text(
              label,
              style: TextStyleCustom.outFitMedium500(
                fontSize: 14,
                color: isSelected
                    ? const Color(0xFFFFD700)
                    : whitePure(context).withValues(alpha: 0.8),
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFFD700)
                      : whitePure(context).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyleCustom.outFitMedium500(
                    fontSize: 11,
                    color: isSelected
                        ? Colors.black
                        : whitePure(context).withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final VyBzzZEvent event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('/event-details', arguments: {'event': event});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            _buildEventImage(context),

            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  if (event.status == EventStatus.live)
                    _buildLiveBadge(context),

                  // Title
                  Text(
                    event.title ?? 'Concert',
                    style: TextStyleCustom.outFitMedium500(
                      fontSize: 18,
                      color: whitePure(context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Artist
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: event.artistPhoto != null
                            ? CachedNetworkImageProvider(event.artistPhoto!)
                            : null,
                        child: event.artistPhoto == null
                            ? const Icon(Icons.person, size: 16)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.artistName ?? 'Artiste',
                          style: TextStyleCustom.outFitRegular400(
                            fontSize: 14,
                            color: whitePure(context).withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Date & Price
                  Row(
                    children: [
                      // Date
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: whitePure(context).withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatDate(event.startTime),
                              style: TextStyleCustom.outFitRegular400(
                                fontSize: 13,
                                color: whitePure(context).withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Price
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'dès ${_getMinPrice(event)}€',
                          style: TextStyleCustom.outFitMedium500(
                            fontSize: 14,
                            color: const Color(0xFFFFD700),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Happy Hour indicator
                  if (event.isHappyHour == true) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8C00).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('⚡', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            'Happy Hour -25%',
                            style: TextStyleCustom.outFitMedium500(
                              fontSize: 11,
                              color: const Color(0xFFFF8C00),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventImage(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: event.coverImageUrl != null
              ? CachedNetworkImage(
                  imageUrl: event.coverImageUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 180,
                    color: whitePure(context).withValues(alpha: 0.1),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 180,
                    color: whitePure(context).withValues(alpha: 0.1),
                    child: const Center(child: Icon(Icons.music_note, size: 48)),
                  ),
                )
              : Container(
                  height: 180,
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
                    child: Text('🎵', style: TextStyle(fontSize: 48)),
                  ),
                ),
        ),

        // Type badge
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              event.eventType?.displayName ?? '',
              style: TextStyleCustom.outFitMedium500(
                fontSize: 11,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveBadge(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE50914).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE50914),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFE50914),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'EN DIRECT',
            style: TextStyleCustom.outFitMedium500(
              fontSize: 11,
              color: const Color(0xFFE50914),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Date à définir';
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Demain ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE HH:mm', 'fr_FR').format(date);
    } else {
      return DateFormat('dd MMM HH:mm', 'fr_FR').format(date);
    }
  }

  String _getMinPrice(VyBzzZEvent event) {
    final prices = <double>[];
    if (event.ticketPriceVirtual != null) prices.add(event.ticketPriceVirtual!);
    if (event.ticketPricePhysical != null) prices.add(event.ticketPricePhysical!);
    if (event.ticketPriceFanbase != null) prices.add(event.ticketPriceFanbase!);

    if (prices.isEmpty) return '0';
    return prices.reduce((a, b) => a < b ? a : b).toStringAsFixed(0);
  }
}
