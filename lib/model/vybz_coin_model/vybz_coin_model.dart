import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle pour la monnaie virtuelle VyBzzZ
///
/// Système de gamification:
/// - 10 Vybz = 1€
/// - Achats par packs avec bonus
/// - Animations selon le montant
/// - Plus ludique que les euros directs

class VybzCoin {
  String? id;
  int? userId;
  int amount; // En Vybz (10 Vybz = 1€)
  DateTime? createdAt;
  String? source; // 'purchase', 'bonus', 'refund'

  VybzCoin({
    this.id,
    this.userId,
    required this.amount,
    this.createdAt,
    this.source,
  });

  // Conversion helpers
  static double vybzToEur(int vybz) => vybz / 10.0;
  static int eurToVybz(double eur) => (eur * 10).round();

  factory VybzCoin.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return VybzCoin(
      id: doc.id,
      userId: data['user_id'] as int?,
      amount: data['amount'] as int? ?? 0,
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
      source: data['source'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'amount': amount,
      'created_at': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'source': source,
    };
  }
}

/// Pack d'achat de Vybz
class VybzCoinPack {
  final String id;
  final String name;
  final int vybzAmount; // Montant de base
  final int bonusVybz; // Bonus offert
  final double priceEur; // Prix en euros
  final String icon;
  final String gradient1;
  final String gradient2;
  final bool isPopular;

  VybzCoinPack({
    required this.id,
    required this.name,
    required this.vybzAmount,
    required this.bonusVybz,
    required this.priceEur,
    required this.icon,
    required this.gradient1,
    required this.gradient2,
    this.isPopular = false,
  });

  int get totalVybz => vybzAmount + bonusVybz;

  double get discountPercentage {
    if (bonusVybz == 0) return 0;
    return (bonusVybz / vybzAmount) * 100;
  }

  /// Packs prédéfinis
  static List<VybzCoinPack> get defaultPacks => [
        VybzCoinPack(
          id: 'starter',
          name: 'Starter',
          vybzAmount: 100,
          bonusVybz: 0,
          priceEur: 10.0,
          icon: '💫',
          gradient1: '#6B7FD7',
          gradient2: '#9B9BFF',
        ),
        VybzCoinPack(
          id: 'popular',
          name: 'Popular',
          vybzAmount: 500,
          bonusVybz: 50,
          priceEur: 50.0,
          icon: '🔥',
          gradient1: '#FF6B6B',
          gradient2: '#FF8E53',
          isPopular: true,
        ),
        VybzCoinPack(
          id: 'best_value',
          name: 'Best Value',
          vybzAmount: 1000,
          bonusVybz: 150,
          priceEur: 100.0,
          icon: '💎',
          gradient1: '#4ECDC4',
          gradient2: '#44A08D',
        ),
        VybzCoinPack(
          id: 'vip',
          name: 'VIP',
          vybzAmount: 2000,
          bonusVybz: 400,
          priceEur: 200.0,
          icon: '👑',
          gradient1: '#FFD700',
          gradient2: '#FF8C00',
        ),
        VybzCoinPack(
          id: 'ultimate',
          name: 'Ultimate',
          vybzAmount: 5000,
          bonusVybz: 1250,
          priceEur: 500.0,
          icon: '🚀',
          gradient1: '#B24592',
          gradient2: '#F15F79',
        ),
        VybzCoinPack(
          id: 'mega',
          name: 'Mega',
          vybzAmount: 10000,
          bonusVybz: 3000,
          priceEur: 1000.0,
          icon: '🌟',
          gradient1: '#00F260',
          gradient2: '#0575E6',
        ),
      ];
}

/// Animation tier pour les tips
enum VybzAnimationTier {
  small(1, 50, '🔥', 'Feu'),
  medium(51, 200, '⚡', 'Éclair'),
  large(201, 500, '💫', 'Étoiles'),
  huge(501, 1000, '💎', 'Diamant'),
  epic(1001, 5000, '👑', 'Couronne'),
  legendary(5001, 999999, '🚀', 'Fusée');

  final int minVybz;
  final int maxVybz;
  final String icon;
  final String name;

  const VybzAnimationTier(this.minVybz, this.maxVybz, this.icon, this.name);

  static VybzAnimationTier fromAmount(int vybz) {
    if (vybz >= legendary.minVybz) return legendary;
    if (vybz >= epic.minVybz) return epic;
    if (vybz >= huge.minVybz) return huge;
    if (vybz >= large.minVybz) return large;
    if (vybz >= medium.minVybz) return medium;
    return small;
  }

  bool get shouldShowFullScreenAnimation => this.index >= huge.index;
}

/// Quick tip amounts (boutons rapides)
class QuickTipAmount {
  final int vybz;
  final String icon;
  final String label;

  QuickTipAmount({
    required this.vybz,
    required this.icon,
    required this.label,
  });

  double get euros => VybzCoin.vybzToEur(vybz);

  static List<QuickTipAmount> get defaults => [
        QuickTipAmount(vybz: 10, icon: '🔥', label: '10'),
        QuickTipAmount(vybz: 50, icon: '⚡', label: '50'),
        QuickTipAmount(vybz: 100, icon: '💫', label: '100'),
        QuickTipAmount(vybz: 500, icon: '💎', label: '500'),
        QuickTipAmount(vybz: 1000, icon: '👑', label: '1K'),
        QuickTipAmount(vybz: 5000, icon: '🚀', label: '5K'),
      ];
}
