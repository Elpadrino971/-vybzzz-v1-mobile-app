import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:vybzzz/screen/vybz_shop_screen/vybz_shop_controller.dart';
import 'package:vybzzz/model/vybz_coin_model/vybz_coin_model.dart';
import 'package:vybzzz/common/widget/vybzzz_theme.dart';

/// Écran de la boutique VyBzzZ
///
/// Permet d'acheter des packs de Vybz avec Stripe
class VybzShopScreen extends StatelessWidget {
  const VybzShopScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VybzShopController());

    return Scaffold(
      backgroundColor: VyBzzZTheme.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return CustomScrollView(
          slivers: [
            // Header avec solde
            _buildHeader(controller),

            // Stats
            _buildStats(controller),

            // Packs
            _buildPacksGrid(controller),

            // Bottom spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        );
      }),
    );
  }

  // ============================================
  // HEADER
  // ============================================

  Widget _buildHeader(VybzShopController controller) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 24,
              cornerSmoothing: 1,
            ),
          ),
          shadows: [
            BoxShadow(
              color: Color(0xFFFFD700).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Titre
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Boutique ',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'VyBzzZ',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Icône
            const Text(
              '🐝',
              style: TextStyle(fontSize: 48),
            ),

            const SizedBox(height: 16),

            // Solde
            Obx(() => Column(
                  children: [
                    const Text(
                      'Votre solde',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          controller.userBalance.value.toString(),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Vybz',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '≈ ${controller.getBalanceInEur()}€',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  // ============================================
  // STATS
  // ============================================

  Widget _buildStats(VybzShopController controller) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            // Total dépensé
            Expanded(
              child: _buildStatCard(
                icon: '💸',
                label: 'Total dépensé',
                value: '${controller.totalSpent.value} Vybz',
              ),
            ),

            const SizedBox(width: 12),

            // Total acheté
            Expanded(
              child: _buildStatCard(
                icon: '💳',
                label: 'Total acheté',
                value: '${controller.totalPurchased.value.toStringAsFixed(0)}€',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: VyBzzZTheme.cardBackground,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 16,
            cornerSmoothing: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: VyBzzZTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: VyBzzZTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // PACKS GRID
  // ============================================

  Widget _buildPacksGrid(VybzShopController controller) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final pack = controller.packs[index];
            return _buildPackCard(pack, controller);
          },
          childCount: controller.packs.length,
        ),
      ),
    );
  }

  Widget _buildPackCard(VybzCoinPack pack, VybzShopController controller) {
    return GestureDetector(
      onTap: () => _showPurchaseConfirmation(pack, controller),
      child: Container(
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            colors: [
              Color(int.parse(pack.gradient1.replaceFirst('#', '0xFF'))),
              Color(int.parse(pack.gradient2.replaceFirst('#', '0xFF'))),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 20,
              cornerSmoothing: 1,
            ),
          ),
          shadows: [
            BoxShadow(
              color: Color(int.parse(pack.gradient1.replaceFirst('#', '0xFF')))
                  .withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Badge Popular
            if (pack.isPopular)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'POPULAIRE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

            // Contenu
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Haut
                  Column(
                    children: [
                      // Icône
                      Text(
                        pack.icon,
                        style: const TextStyle(fontSize: 48),
                      ),

                      const SizedBox(height: 8),

                      // Nom
                      Text(
                        pack.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Montant
                      Text(
                        '${pack.totalVybz}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      const Text(
                        'Vybz',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),

                      // Bonus
                      if (pack.bonusVybz > 0) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '+${pack.discountPercentage.toStringAsFixed(0)}% bonus',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Bas - Prix
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${pack.priceEur.toStringAsFixed(0)}€',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
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

  // ============================================
  // PURCHASE CONFIRMATION
  // ============================================

  void _showPurchaseConfirmation(
    VybzCoinPack pack,
    VybzShopController controller,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: VyBzzZTheme.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 24),

            // Icône
            Text(
              pack.icon,
              style: const TextStyle(fontSize: 64),
            ),

            const SizedBox(height: 16),

            // Titre
            Text(
              'Pack ${pack.name}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: VyBzzZTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 24),

            // Détails
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: VyBzzZTheme.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Montant de base', '${pack.vybzAmount} Vybz'),
                  if (pack.bonusVybz > 0) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Bonus offert',
                      '+${pack.bonusVybz} Vybz',
                      isBonus: true,
                    ),
                  ],
                  const Divider(height: 24),
                  _buildDetailRow(
                    'Total',
                    '${pack.totalVybz} Vybz',
                    isTotal: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Prix
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(int.parse(pack.gradient1.replaceFirst('#', '0xFF'))),
                    Color(int.parse(pack.gradient2.replaceFirst('#', '0xFF'))),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Prix: ',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    '${pack.priceEur.toStringAsFixed(2)}€',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Boutons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Annuler',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: controller.isPurchasing.value
                          ? null
                          : () async {
                              Get.back();
                              await controller.purchasePack(pack);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VyBzzZTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isPurchasing.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Acheter',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isBonus = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isBonus
                ? VyBzzZTheme.success
                : isTotal
                    ? VyBzzZTheme.textPrimary
                    : VyBzzZTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isBonus
                ? VyBzzZTheme.success
                : isTotal
                    ? VyBzzZTheme.primary
                    : VyBzzZTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
