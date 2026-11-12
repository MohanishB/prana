import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations_x.dart';
import '../../../core/theme/app_sizes.dart';

class PranaShell extends StatelessWidget {
  const PranaShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _select(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: navigationShell,
      // A tab name never wraps: it stays on one line and shrinks slightly on
      // narrow screens or with a large-text setting (see _NavItem).
      bottomNavigationBar: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.2,
        child: _PranaNavBar(
          selectedIndex: navigationShell.currentIndex,
          onSelected: _select,
          items: [
            _NavEntry(Icons.home_outlined, Icons.home, l10n.home),
            _NavEntry(Icons.school_outlined, Icons.school, l10n.masterclass),
            _NavEntry(
              Icons.monitor_heart_outlined,
              Icons.monitor_heart,
              l10n.consult,
            ),
            _NavEntry(
              Icons.video_library_outlined,
              Icons.video_library,
              l10n.library,
            ),
            _NavEntry(Icons.person_outline, Icons.person, l10n.account),
          ],
        ),
      ),
    );
  }
}

class _NavEntry {
  const _NavEntry(this.icon, this.selectedIcon, this.label);

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Bottom bar that looks like the Material 3 NavigationBar but keeps every
/// label on a single line.
class _PranaNavBar extends StatelessWidget {
  const _PranaNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_NavEntry> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainer,
      elevation: 3,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSizes.navigationBarHeight,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavItem(
                    entry: items[i],
                    selected: i == selectedIndex,
                    onTap: () => onSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.entry,
    required this.selected,
    required this.onTap,
  });

  final _NavEntry entry;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      label: entry.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? scheme.secondaryContainer : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                selected ? entry.selectedIcon : entry.icon,
                size: 24,
                color: selected
                    ? scheme.onSecondaryContainer
                    : scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  entry.label,
                  maxLines: 1,
                  softWrap: false,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
