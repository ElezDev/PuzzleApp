import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../l10n/app_strings.dart';
import '../models/shop_item.dart';
import '../providers/app_provider.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  Future<void> _onItemTap(
    BuildContext context,
    AppProvider provider,
    ShopItem item,
  ) async {
    final strings = AppStrings.of(context);

    if (provider.isEquipped(item.id)) return;

    if (provider.isPurchased(item.id)) {
      await provider.equipAvatar(item.id);
      return;
    }

    if (provider.coins < item.price) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.notEnoughCoins),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final success = await provider.purchaseItem(item);
    if (!context.mounted) return;
    if (success) {
      await provider.equipAvatar(item.id);
      provider.sound.playCoin();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            strings.avatarPurchased(strings.avatarName(item.id)),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.shop),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.monetization_on_rounded,
                        color: AppTheme.warning, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(strings.shopSubtitle,
                            style: theme.textTheme.bodySmall),
                        Text(
                          '${provider.coins} ${strings.coins.toLowerCase()}',
                          style: theme.textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                physics: const BouncingScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.82,
                ),
                itemCount: ShopItem.avatars.length,
                itemBuilder: (context, index) {
                  final item = ShopItem.avatars[index];
                  return _ShopCard(
                    item: item,
                    purchased: provider.isPurchased(item.id),
                    equipped: provider.isEquipped(item.id),
                    affordable: provider.coins >= item.price,
                    onTap: () => _onItemTap(context, provider, item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  final ShopItem item;
  final bool purchased;
  final bool equipped;
  final bool affordable;
  final VoidCallback onTap;

  const _ShopCard({
    required this.item,
    required this.purchased,
    required this.equipped,
    required this.affordable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: equipped
            ? Border.all(color: AppTheme.success, width: 2)
            : Border.all(color: Colors.transparent, width: 2),
      ),
      child: Column(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [item.color, item.gradientEnd],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: item.color.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(item.icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 10),
          Text(
            strings.avatarName(item.id),
            style: theme.textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          if (equipped)
            _StatusBadge(
              label: strings.equipped,
              color: AppTheme.success,
              icon: Icons.check_circle_rounded,
            )
          else if (purchased)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: theme.colorScheme.primary),
                ),
                child: Text(strings.equip),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  backgroundColor: affordable
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on_rounded,
                        size: 15, color: Colors.white),
                    const SizedBox(width: 4),
                    Text('${item.price}'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
