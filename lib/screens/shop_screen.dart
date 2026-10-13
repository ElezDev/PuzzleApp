import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../l10n/app_strings.dart';
import '../models/shop_item.dart';
import '../models/app_background.dart';
import '../models/game_info.dart';
import '../providers/app_provider.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String _selectedSlot = AppProvider.globalBackgroundSlot;

  Future<void> _purchaseAndEquip({
    required BuildContext context,
    required AppProvider provider,
    required String id,
    required int price,
    required String name,
    required bool purchased,
    required bool equipped,
    required Future<void> Function() equip,
  }) async {
    final strings = AppStrings.of(context);
    if (equipped) return;

    if (purchased) {
      await equip();
      return;
    }

    if (provider.coins < price) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.notEnoughCoins),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final success = await provider.purchase(id, price);
    if (!context.mounted) return;
    if (success) {
      await equip();
      provider.sound.playCoin();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.avatarPurchased(name)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _slotLabel(AppStrings strings, String slot) {
    if (slot == AppProvider.globalBackgroundSlot) return strings.general;
    return strings.gameName(slot);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    final slots = [
      AppProvider.globalBackgroundSlot,
      ...GameInfo.allGames
          .where((g) => provider.level >= g.requiredLevel)
          .map((g) => g.id),
    ];

    final currentBackground = provider.backgroundFor(_selectedSlot);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.shop),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
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
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Text(strings.avatars,
                    style: theme.textTheme.titleMedium),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.82,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = ShopItem.avatars[index];
                    return _AvatarCard(
                      item: item,
                      purchased: provider.isPurchased(item.id),
                      equipped: provider.isEquipped(item.id),
                      affordable: provider.coins >= item.price,
                      onTap: () => _purchaseAndEquip(
                        context: context,
                        provider: provider,
                        id: item.id,
                        price: item.price,
                        name: strings.avatarName(item.id),
                        purchased: provider.isPurchased(item.id),
                        equipped: provider.isEquipped(item.id),
                        equip: () => provider.equipAvatar(item.id),
                      ),
                    );
                  },
                  childCount: ShopItem.avatars.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Text(strings.backgrounds,
                    style: theme.textTheme.titleMedium),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
                child: Text(strings.forScreen,
                    style: theme.textTheme.bodySmall),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: slots.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final slot = slots[index];
                    final selected = slot == _selectedSlot;
                    return ChoiceChip(
                      label: Text(_slotLabel(strings, slot)),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedSlot = slot),
                      selectedColor: theme.colorScheme.primary,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : null,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide.none,
                    );
                  },
                ),
              ),
            ),
            if (_selectedSlot != AppProvider.globalBackgroundSlot)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Row(
                    children: [
                      const Icon(Icons.layers_rounded,
                          size: 16, color: AppTheme.primaryLight),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          currentBackground == null
                              ? strings.inherited
                              : strings.backgroundName(currentBackground.id),
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            provider.equipBackground(_selectedSlot, null),
                        icon: const Icon(Icons.restart_alt_rounded, size: 16),
                        label: Text(strings.useGeneralBackground),
                      ),
                    ],
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.95,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = AppBackground.all[index];
                    final equipped = provider.isBackgroundEquipped(
                        _selectedSlot, item.id);
                    final inherited = provider.isBackgroundInherited(
                        _selectedSlot, item.id);
                    return _BackgroundCard(
                      item: item,
                      isDark: provider.isDarkMode,
                      equipped: equipped,
                      inherited: inherited,
                      onTap: () => _purchaseAndEquip(
                        context: context,
                        provider: provider,
                        id: item.id,
                        price: item.price,
                        name: strings.backgroundName(item.id),
                        purchased: provider.isPurchased(item.id),
                        equipped: equipped,
                        equip: () =>
                            provider.equipBackground(_selectedSlot, item.id),
                      ),
                    );
                  },
                  childCount: AppBackground.all.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _AvatarCard extends StatelessWidget {
  final ShopItem item;
  final bool purchased;
  final bool equipped;
  final bool affordable;
  final VoidCallback onTap;

  const _AvatarCard({
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
          _ActionButton(
            purchased: purchased,
            equipped: equipped,
            affordable: affordable,
            price: item.price,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _BackgroundCard extends StatelessWidget {
  final AppBackground item;
  final bool isDark;
  final bool equipped;
  final bool inherited;
  final VoidCallback onTap;

  const _BackgroundCard({
    required this.item,
    required this.isDark,
    required this.equipped,
    required this.inherited,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);
    final colors = isDark ? item.darkColors : item.lightColors;

    final borderColor = equipped
        ? AppTheme.success
        : (inherited ? AppTheme.primaryLight : Colors.transparent);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  ),
                ),
                child: (equipped || inherited)
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            equipped ? strings.equipped : strings.inherited,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              strings.backgroundName(item.id),
              style: theme.textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            _ActionButton(
              purchased: true,
              equipped: equipped,
              affordable: true,
              price: item.price,
              onTap: onTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final bool purchased;
  final bool equipped;
  final bool affordable;
  final int price;
  final VoidCallback onTap;

  const _ActionButton({
    required this.purchased,
    required this.equipped,
    required this.affordable,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    if (equipped) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.success.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded,
                size: 15, color: AppTheme.success),
            const SizedBox(width: 4),
            Text(
              strings.equipped,
              style: const TextStyle(
                color: AppTheme.success,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    if (purchased) {
      return SizedBox(
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
      );
    }

    return SizedBox(
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
            Text('$price'),
          ],
        ),
      ),
    );
  }
}
