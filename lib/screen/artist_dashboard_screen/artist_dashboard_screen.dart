import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vybzzz/screen/artist_dashboard_screen/artist_dashboard_controller.dart';
import 'package:vybzzz/model/event_model/vybzzz_event_model.dart';
import 'package:vybzzz/common/widget/theme_blur_bg.dart';
import 'package:vybzzz/utilities/text_style_custom.dart';
import 'package:vybzzz/utilities/theme_res.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:intl/intl.dart';

/// Dashboard Artiste VyBzzZ
class ArtistDashboardScreen extends StatelessWidget {
  const ArtistDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ArtistDashboardController());

    return Scaffold(
      body: Stack(
        children: [
          const ThemeBlurBg(),
          SafeArea(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return RefreshIndicator(
                onRefresh: controller.refreshDashboard,
                child: CustomScrollView(
                  slivers: [
                    // Header
                    _buildHeader(controller, context),

                    // Stats Cards
                    SliverToBoxAdapter(
                      child: _buildStatsSection(controller, context),
                    ),

                    // Next Payout
                    SliverToBoxAdapter(
                      child: _buildNextPayoutCard(controller, context),
                    ),

                    // Events Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Mes événements',
                              style: TextStyleCustom.outFitMedium500(
                                fontSize: 20,
                                color: whitePure(context),
                              ),
                            ),
                            TextButton(
                              onPressed: controller.goToCreateEvent,
                              child: Row(
                                children: [
                                  const Icon(Icons.add, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Créer',
                                    style: TextStyleCustom.outFitMedium500(
                                      fontSize: 14,
                                      color: const Color(0xFFFFD700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Events List
                    _buildEventsList(controller, context),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      ArtistDashboardController controller, BuildContext context) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Dashboard Artiste',
          style: TextStyleCustom.outFitMedium500(
            fontSize: 20,
            color: whitePure(context),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(
      ArtistDashboardController controller, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Main stats row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  label: 'Total gains',
                  value: '${controller.totalEarnings.value.toStringAsFixed(0)}€',
                  icon: Icons.euro,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                  ),
                  context: context,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  label: 'Ce mois',
                  value: '${controller.monthEarnings.value.toStringAsFixed(0)}€',
                  icon: Icons.calendar_today,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00D4FF), Color(0xFF0099FF)],
                  ),
                  context: context,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Secondary stats row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  label: 'Billets vendus',
                  value: controller.totalTicketsSold.value.toString(),
                  icon: Icons.confirmation_number,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFE50914).withValues(alpha: 0.8),
                      const Color(0xFFE50914),
                    ],
                  ),
                  context: context,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  label: 'Pourboires',
                  value: '${controller.totalTips.value.toStringAsFixed(0)}€',
                  icon: Icons.volunteer_activism,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
                  ),
                  context: context,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Gradient gradient,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        gradient: gradient,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.all(
            SmoothRadius(cornerRadius: 16, cornerSmoothing: 1),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyleCustom.outFitMedium500(
              fontSize: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyleCustom.outFitRegular400(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextPayoutCard(
      ArtistDashboardController controller, BuildContext context) {
    if (!controller.hasNextPayout) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF2A2A2A),
          ],
        ),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.all(
            SmoothRadius(cornerRadius: 20, cornerSmoothing: 1),
          ),
          side: BorderSide(
            color: const Color(0xFFFFD700).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD700),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.access_time,
                  color: Colors.black,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prochain paiement',
                      style: TextStyleCustom.outFitRegular400(
                        fontSize: 13,
                        color: whitePure(context).withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      controller.nextPayoutDate ?? 'Bientôt',
                      style: TextStyleCustom.outFitMedium500(
                        fontSize: 16,
                        color: const Color(0xFFFFD700),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${controller.nextPayoutAmount?.toStringAsFixed(2)}€',
                    style: TextStyleCustom.outFitMedium500(
                      fontSize: 24,
                      color: whitePure(context),
                    ),
                  ),
                  Text(
                    'Net à recevoir',
                    style: TextStyleCustom.outFitRegular400(
                      fontSize: 11,
                      color: whitePure(context).withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Payout details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: whitePure(context).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPayoutDetail(
                  'Revenus bruts',
                  '${controller.nextPayout.value?.grossRevenue?.toStringAsFixed(2)}€',
                  context,
                ),
                _buildPayoutDetail(
                  'Commission',
                  '-${controller.nextPayout.value?.platformFee?.toStringAsFixed(2)}€',
                  context,
                ),
                _buildPayoutDetail(
                  'Frais Stripe',
                  '-${controller.nextPayout.value?.stripeFees?.toStringAsFixed(2)}€',
                  context,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 14,
                color: Color(0xFFFFD700),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Paiement automatique tous les lundis (J+14)',
                  style: TextStyleCustom.outFitRegular400(
                    fontSize: 11,
                    color: whitePure(context).withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutDetail(
      String label, String value, BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyleCustom.outFitMedium500(
            fontSize: 14,
            color: whitePure(context),
          ),
        ),
        Text(
          label,
          style: TextStyleCustom.outFitRegular400(
            fontSize: 10,
            color: whitePure(context).withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildEventsList(
      ArtistDashboardController controller, BuildContext context) {
    final events = controller.scheduledEvents;

    if (events.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              const Text('🎤', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                'Aucun événement programmé',
                style: TextStyleCustom.outFitMedium500(
                  fontSize: 16,
                  color: whitePure(context).withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Créez votre premier concert !',
                style: TextStyleCustom.outFitRegular400(
                  fontSize: 14,
                  color: whitePure(context).withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _EventCard(
            event: events[index],
            controller: controller,
          );
        },
        childCount: events.length,
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final VyBzzZEvent event;
  final ArtistDashboardController controller;

  const _EventCard({
    required this.event,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.goToEventDetails(event),
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: whitePure(context).withValues(alpha: 0.05),
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius.all(
              SmoothRadius(cornerRadius: 16, cornerSmoothing: 1),
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
            // Title & Status
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.title ?? 'Concert',
                    style: TextStyleCustom.outFitMedium500(
                      fontSize: 16,
                      color: whitePure(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (event.status == EventStatus.live)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE50914),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'LIVE',
                          style: TextStyleCustom.outFitMedium500(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Date & Stats
            Row(
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
                const Spacer(),
                Text(
                  '${event.ticketsSold ?? 0} billets',
                  style: TextStyleCustom.outFitMedium500(
                    fontSize: 13,
                    color: const Color(0xFFFFD700),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Revenue
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Revenus',
                    style: TextStyleCustom.outFitRegular400(
                      fontSize: 13,
                      color: whitePure(context).withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    '${event.totalRevenue?.toStringAsFixed(2) ?? '0.00'}€',
                    style: TextStyleCustom.outFitMedium500(
                      fontSize: 16,
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Date à définir';
    return DateFormat('EEEE d MMM • HH:mm', 'fr_FR').format(date);
  }
}
