import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vybzzz/screen/my_tickets_screen/my_tickets_controller.dart';
import 'package:vybzzz/model/ticket_model/ticket_model.dart';
import 'package:vybzzz/common/widget/theme_blur_bg.dart';
import 'package:vybzzz/utilities/text_style_custom.dart';
import 'package:vybzzz/utilities/theme_res.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:intl/intl.dart';

/// Écran Mes Billets avec QR codes
class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyTicketsController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Mes Billets',
          style: TextStyleCustom.outFitMedium500(
            fontSize: 20,
            color: whitePure(context),
          ),
        ),
      ),
      body: Stack(
        children: [
          const ThemeBlurBg(),
          SafeArea(
            child: Column(
              children: [
                // Stats Bar
                _buildStatsBar(controller, context),

                // Filters
                _buildFilterTabs(controller, context),

                // Tickets List
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final tickets = controller.filteredTickets;

                    if (tickets.isEmpty) {
                      return _buildEmptyState(controller, context);
                    }

                    return RefreshIndicator(
                      onRefresh: controller.refreshTickets,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: tickets.length,
                        itemBuilder: (context, index) {
                          return _TicketCard(
                            ticket: tickets[index],
                            controller: controller,
                          );
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
    );
  }

  Widget _buildStatsBar(MyTicketsController controller, BuildContext context) {
    return Obx(() => Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFD700),
                Color(0xFFFF8C00),
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
              Expanded(
                child: _buildStatItem(
                  label: 'Total',
                  value: controller.totalTickets.toString(),
                  context: context,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.black.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildStatItem(
                  label: 'À venir',
                  value: controller.upcomingCount.toString(),
                  context: context,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.black.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildStatItem(
                  label: 'Dépensé',
                  value: '${controller.totalSpent.toStringAsFixed(0)}€',
                  context: context,
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required BuildContext context,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyleCustom.outFitMedium500(
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyleCustom.outFitRegular400(
            fontSize: 12,
            color: Colors.black.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs(MyTicketsController controller, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Obx(() => Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  label: 'À venir',
                  isSelected: controller.selectedFilter.value == 'upcoming',
                  onTap: () => controller.changeFilter('upcoming'),
                  context: context,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip(
                  label: 'Passés',
                  isSelected: controller.selectedFilter.value == 'past',
                  onTap: () => controller.changeFilter('past'),
                  context: context,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip(
                  label: 'Tous',
                  isSelected: controller.selectedFilter.value == 'all',
                  onTap: () => controller.changeFilter('all'),
                  context: context,
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
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
          label,
          textAlign: TextAlign.center,
          style: TextStyleCustom.outFitMedium500(
            fontSize: 14,
            color: isSelected
                ? const Color(0xFFFFD700)
                : whitePure(context).withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(MyTicketsController controller, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎫', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'Aucun billet',
            style: TextStyleCustom.outFitMedium500(
              fontSize: 18,
              color: whitePure(context).withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Achetez des billets pour voir des concerts !',
            style: TextStyleCustom.outFitRegular400(
              fontSize: 14,
              color: whitePure(context).withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final MyTicketsController controller;

  const _TicketCard({
    required this.ticket,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final timeUntil = controller.getTimeUntilEvent(ticket);
    final isUpcoming = timeUntil != null;

    return GestureDetector(
      onTap: () => _showTicketDetails(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: ShapeDecoration(
          gradient: isUpcoming
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFD700),
                    Color(0xFFFF8C00),
                  ],
                )
              : null,
          color: isUpcoming ? null : whitePure(context).withValues(alpha: 0.05),
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius.all(
              SmoothRadius(cornerRadius: 20, cornerSmoothing: 1),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Mini QR Code Preview
              Container(
                width: 80,
                height: 80,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ticket.qrCode != null
                    ? PrettyQrView.data(
                        data: ticket.qrCode!,
                        decoration: const PrettyQrDecoration(),
                      )
                    : const Icon(Icons.qr_code, size: 40),
              ),

              const SizedBox(width: 16),

              // Ticket Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Title
                    Text(
                      ticket.eventTitle ?? 'Concert',
                      style: TextStyleCustom.outFitMedium500(
                        fontSize: 16,
                        color: isUpcoming ? Colors.black : whitePure(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Ticket Type
                    Row(
                      children: [
                        Text(
                          _getTicketTypeEmoji(),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ticket.ticketTypeName,
                          style: TextStyleCustom.outFitRegular400(
                            fontSize: 13,
                            color: isUpcoming
                                ? Colors.black.withValues(alpha: 0.7)
                                : whitePure(context).withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Date or Countdown
                    if (isUpcoming)
                      _buildCountdown(timeUntil, context)
                    else
                      Text(
                        _formatDate(ticket.eventStartTime),
                        style: TextStyleCustom.outFitRegular400(
                          fontSize: 12,
                          color: isUpcoming
                              ? Colors.black.withValues(alpha: 0.6)
                              : whitePure(context).withValues(alpha: 0.6),
                        ),
                      ),
                  ],
                ),
              ),

              // Status Badge
              _buildStatusBadge(context, isUpcoming),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountdown(Duration duration, BuildContext context) {
    if (duration.inDays > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Dans ${duration.inDays}j ${duration.inHours % 24}h',
          style: TextStyleCustom.outFitMedium500(
            fontSize: 12,
            color: Colors.black,
          ),
        ),
      );
    } else if (duration.inHours > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Dans ${duration.inHours}h ${duration.inMinutes % 60}min',
          style: TextStyleCustom.outFitMedium500(
            fontSize: 12,
            color: Colors.red.shade900,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Bientôt !',
          style: TextStyleCustom.outFitMedium500(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      );
    }
  }

  Widget _buildStatusBadge(BuildContext context, bool isUpcoming) {
    if (ticket.status == TicketStatus.used) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: whitePure(context).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Utilisé',
          style: TextStyleCustom.outFitMedium500(
            fontSize: 11,
            color: whitePure(context).withValues(alpha: 0.7),
          ),
        ),
      );
    }

    return Icon(
      Icons.chevron_right,
      color: isUpcoming ? Colors.black : whitePure(context),
    );
  }

  void _showTicketDetails(BuildContext context) {
    Get.bottomSheet(
      _TicketDetailSheet(
        ticket: ticket,
        controller: controller,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  String _getTicketTypeEmoji() {
    switch (ticket.ticketType) {
      case TicketType.virtual:
        return '🎵';
      case TicketType.physical:
        return '🎫';
      case TicketType.fanbase:
        return '👥';
      default:
        return '🎫';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Date inconnue';
    return DateFormat('dd MMM yyyy • HH:mm', 'fr_FR').format(date);
  }
}

class _TicketDetailSheet extends StatelessWidget {
  final TicketModel ticket;
  final MyTicketsController controller;

  const _TicketDetailSheet({
    required this.ticket,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: ShapeDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        shape: const SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.vertical(
            top: SmoothRadius(cornerRadius: 30, cornerSmoothing: 1),
          ),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: whitePure(context).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Title
                  Text(
                    ticket.eventTitle ?? 'Concert',
                    style: TextStyleCustom.outFitMedium500(
                      fontSize: 24,
                      color: whitePure(context),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // QR Code
                  Container(
                    width: 280,
                    height: 280,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ticket.qrCode != null
                        ? PrettyQrView.data(
                            data: ticket.qrCode!,
                            decoration: const PrettyQrDecoration(
                              shape: PrettyQrSmoothSymbol(
                                color: Colors.black,
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.qr_code, size: 100),
                          ),
                  ),

                  const SizedBox(height: 24),

                  // Ticket Info
                  _buildInfoRow(
                    'Type',
                    ticket.ticketTypeName,
                    context,
                  ),
                  _buildInfoRow(
                    'Prix payé',
                    '${ticket.pricePaid?.toStringAsFixed(2)}€',
                    context,
                  ),
                  _buildInfoRow(
                    'Date',
                    ticket.eventStartTime != null
                        ? DateFormat('EEEE d MMMM yyyy', 'fr_FR')
                            .format(ticket.eventStartTime!)
                        : 'À définir',
                    context,
                  ),
                  _buildInfoRow(
                    'Heure',
                    ticket.eventStartTime != null
                        ? DateFormat('HH:mm').format(ticket.eventStartTime!)
                        : 'À définir',
                    context,
                  ),
                  _buildInfoRow(
                    'Statut',
                    ticket.statusDisplayName,
                    context,
                  ),

                  const SizedBox(height: 24),

                  // Actions
                  if (controller.canRefund(ticket))
                    OutlinedButton(
                      onPressed: () {
                        Get.back();
                        controller.requestRefund(ticket.id!);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Demander un remboursement'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyleCustom.outFitRegular400(
              fontSize: 14,
              color: whitePure(context).withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: TextStyleCustom.outFitMedium500(
              fontSize: 14,
              color: whitePure(context),
            ),
          ),
        ],
      ),
    );
  }
}
