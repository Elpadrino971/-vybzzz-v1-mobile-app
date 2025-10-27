import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vybzzz/screen/main_navigation_screen/main_navigation_controller.dart';
import 'package:vybzzz/screen/home_screen/event_feed_screen.dart';
import 'package:vybzzz/screen/my_tickets_screen/my_tickets_screen.dart';
import 'package:vybzzz/screen/artist_dashboard_screen/artist_dashboard_screen.dart';
import 'package:vybzzz/screen/create_event_screen/create_event_screen.dart';
import 'package:vybzzz/utilities/theme_res.dart';
import 'package:vybzzz/utilities/text_style_custom.dart';

/// Écran de navigation principale avec bottom nav
class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainNavigationController());

    return Scaffold(
      body: Obx(() {
        return IndexedStack(
          index: controller.currentIndex.value,
          children: _getScreens(controller),
        );
      }),
      bottomNavigationBar: Obx(() {
        return _buildBottomNavigationBar(controller, context);
      }),
    );
  }

  /// Retourne les écrans selon le type d'utilisateur
  List<Widget> _getScreens(MainNavigationController controller) {
    if (controller.isArtist) {
      return const [
        EventFeedScreen(), // Home
        ArtistDashboardScreen(), // Dashboard
        CreateEventScreen(), // Create Event
        MyTicketsScreen(), // My Tickets
      ];
    }

    // Fan, Business Bringer, Regional Manager
    return const [
      EventFeedScreen(), // Home
      MyTicketsScreen(), // My Tickets
    ];
  }

  /// Bottom navigation bar avec design VyBzzZ
  Widget _buildBottomNavigationBar(
    MainNavigationController controller,
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: whitePure(context).withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _getNavItems(controller, context),
          ),
        ),
      ),
    );
  }

  /// Retourne les items de navigation selon le type d'utilisateur
  List<Widget> _getNavItems(
    MainNavigationController controller,
    BuildContext context,
  ) {
    if (controller.isArtist) {
      return [
        _NavItem(
          icon: Icons.home_rounded,
          label: 'Accueil',
          index: 0,
          currentIndex: controller.currentIndex.value,
          onTap: () => controller.changeTab(0),
        ),
        _NavItem(
          icon: Icons.bar_chart_rounded,
          label: 'Dashboard',
          index: 1,
          currentIndex: controller.currentIndex.value,
          onTap: () => controller.changeTab(1),
        ),
        _NavItem(
          icon: Icons.add_circle,
          label: 'Créer',
          index: 2,
          currentIndex: controller.currentIndex.value,
          isHighlight: true,
          onTap: () => controller.changeTab(2),
        ),
        _NavItem(
          icon: Icons.confirmation_number_rounded,
          label: 'Billets',
          index: 3,
          currentIndex: controller.currentIndex.value,
          onTap: () => controller.changeTab(3),
        ),
      ];
    }

    // Fan, Business Bringer, etc.
    return [
      _NavItem(
        icon: Icons.home_rounded,
        label: 'Accueil',
        index: 0,
        currentIndex: controller.currentIndex.value,
        onTap: () => controller.changeTab(0),
      ),
      _NavItem(
        icon: Icons.confirmation_number_rounded,
        label: 'Mes Billets',
        index: 1,
        currentIndex: controller.currentIndex.value,
        onTap: () => controller.changeTab(1),
      ),
    ];
  }
}

/// Item de navigation
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;
  final bool isHighlight;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;

    if (isHighlight) {
      // Special highlight style for "Create" button
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.black, size: 22),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyleCustom.outFitMedium500(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFFFFD700)
                  : whitePure(context).withValues(alpha: 0.5),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyleCustom.outFitRegular400(
                fontSize: 11,
                color: isSelected
                    ? const Color(0xFFFFD700)
                    : whitePure(context).withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
