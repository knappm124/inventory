import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utilities/collections.dart';
import 'utilities/filter.dart';
import 'utilities/itemwidgets.dart';
import 'utilities/menu.dart';
import 'utilities/newitem.dart';

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF0E7490),
    brightness: Brightness.light,
  );
  final baseTextTheme = GoogleFonts.dmSansTextTheme();
  final sectionShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(22),
  );
  final fieldShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: Color.alphaBlend(
      colorScheme.primary.withValues(alpha: 0.035),
      colorScheme.surface,
    ),
    canvasColor: colorScheme.surface,
    textTheme: baseTextTheme.copyWith(
      displaySmall: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
      titleLarge: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
      titleMedium: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
      labelLarge: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
      bodyMedium: GoogleFonts.dmSans(),
      bodySmall: GoogleFonts.dmSans(color: colorScheme.onSurface),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.spaceGrotesk(
        color: colorScheme.onSurface,
        fontSize: 23,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurface),
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.06),
      shape: sectionShape,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.38),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.error, width: 1.6),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      side: BorderSide(color: colorScheme.outlineVariant),
      backgroundColor: colorScheme.surfaceContainerLowest,
      selectedColor: colorScheme.primaryContainer.withValues(alpha: 0.75),
      checkmarkColor: colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(color: colorScheme.onSurface),
      secondaryLabelStyle: TextStyle(color: colorScheme.onPrimaryContainer),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant, size: 18),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: fieldShape,
        textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: fieldShape,
        side: BorderSide(color: colorScheme.outlineVariant),
        foregroundColor: colorScheme.onSurface,
        textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: fieldShape,
        foregroundColor: colorScheme.primary,
        textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        foregroundColor: colorScheme.onSurface,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(fieldShape),
        side: WidgetStatePropertyAll(
          BorderSide(color: colorScheme.outlineVariant),
        ),
        textStyle: WidgetStatePropertyAll(
          GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
        visualDensity: VisualDensity.standard,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant.withValues(alpha: 0.7),
      thickness: 1,
      space: 1,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      showDragHandle: true,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: GoogleFonts.dmSans(color: colorScheme.onInverseSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}

Future<void> main() async {
  Logger.root.level = Level.ALL;
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    // Keep this only for non-web platforms where path_provider is available.
    // The app now uses a web-safe fallback for Chrome.
  }
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  static const String _lowStockThresholdPrefKey = 'inventory.lowStockThreshold';

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Collections? _collections;
  List<Item>? _filteredItems;
  FilterCriteria? _filterCriteria;
  String? _loadErrorMessage;
  int _lowStockThreshold = FilterCriteria.defaultLowStockThreshold;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    try {
      final fileMethods = FileMethods();
      final savedItems = await fileMethods.readItems();
      final savedTags = await fileMethods.readTags();
      final savedLocations = await fileMethods.readLocations();
      final savedStatuses = await fileMethods.readStatuses();
      final prefs = await SharedPreferences.getInstance();
      final savedLowStockThreshold =
          prefs.getInt(_lowStockThresholdPrefKey) ??
          FilterCriteria.defaultLowStockThreshold;

      final loadedLocations = savedLocations.isEmpty
          ? _defaultLocations()
          : {...savedLocations, ..._defaultLocations()};
      final loadedStatuses = savedStatuses.isEmpty
          ? _defaultStatuses()
          : {...savedStatuses, ..._defaultStatuses()};

      final loadedCollections = Collections(
        savedItems.isEmpty ? _defaultItems() : savedItems,
        savedTags.isEmpty ? _defaultTags() : savedTags,
        loadedLocations,
        loadedStatuses,
        onPersistenceError: _handlePersistenceError,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _loadErrorMessage = null;
        _lowStockThreshold = savedLowStockThreshold > 0
            ? savedLowStockThreshold
            : FilterCriteria.defaultLowStockThreshold;
        _collections = loadedCollections;
        _applyCurrentFilters();
      });

      await _showLegacyMigrationNoticeIfNeeded();
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _collections = null;
        _loadErrorMessage = 'Failed to load inventory data.';
      });
    }
  }

  void _handlePersistenceError(Object error) {
    if (!mounted) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentContext =
          _scaffoldKey.currentContext ?? _navigatorKey.currentContext;
      if (currentContext == null) {
        return;
      }
      ScaffoldMessenger.of(currentContext).showSnackBar(
        const SnackBar(
          content: Text('Could not save changes. Please try again.'),
        ),
      );
    });
  }

  Future<void> _showLegacyMigrationNoticeIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final migrationDetected =
        prefs.getBool(FileMethods.legacyItemsMigrationDetectedKey) ?? false;
    final noticeShown =
        prefs.getBool(FileMethods.legacyItemsMigrationNoticeShownKey) ?? false;

    if (!migrationDetected || noticeShown || !mounted) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentContext = _scaffoldKey.currentContext;
      if (currentContext == null) {
        return;
      }
      ScaffoldMessenger.of(currentContext).showSnackBar(
        const SnackBar(
          content: Text(
            'Older inventory records were migrated to the latest format.',
          ),
        ),
      );
    });

    await prefs.setBool(FileMethods.legacyItemsMigrationNoticeShownKey, true);
    await prefs.setBool(FileMethods.legacyItemsMigrationDetectedKey, false);
  }

  Future<void> _openNewItem() async {
    if (_collections == null) {
      return;
    }

    final result = await _navigatorKey.currentState?.push<Item>(
      MaterialPageRoute(
        builder: (context) => NewItem(collections: _collections!),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _applyCurrentFilters();
    });
  }

  Future<void> _openSettings() async {
    if (_collections == null) {
      return;
    }

    await _navigatorKey.currentState?.push<void>(
      MaterialPageRoute(
        builder: (context) => Menu(
          c: _collections!,
          filteredItems: _filteredItems,
          lowStockThreshold: _lowStockThreshold,
          onLowStockThresholdChanged: _onLowStockThresholdChanged,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _applyCurrentFilters();
    });
  }

  Future<void> _openFiltersPanel() async {
    if (_collections == null) {
      return;
    }

    final currentContext =
        _scaffoldKey.currentContext ?? _navigatorKey.currentContext;
    if (currentContext == null) {
      return;
    }

    await showModalBottomSheet<void>(
      context: currentContext,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.8,
          child: Filter(
            c: _collections!,
            criteria:
                _filterCriteria ??
                FilterCriteria(lowStockThreshold: _lowStockThreshold),
            onCriteriaChanged: _onCriteriaChanged,
            onFilterChanged: _onFilterChanged,
          ),
        );
      },
    );
  }

  void _refreshItems() {
    if (!mounted) {
      return;
    }

    setState(() {
      _applyCurrentFilters();
    });
  }

  void _onFilterChanged(List<Item> filteredItems) {
    setState(() {
      final hasActiveFilters = _filterCriteria?.hasActiveFilters ?? false;
      _filteredItems = hasActiveFilters ? filteredItems : null;
    });
  }

  void _onCriteriaChanged(FilterCriteria criteria) {
    setState(() {
      _filterCriteria = FilterCriteria(
        status: criteria.status,
        location: criteria.location,
        lowStockOnly: criteria.lowStockOnly,
        lowStockThreshold: _lowStockThreshold,
        priceRange: criteria.priceRange,
        tagFilters: criteria.tagFilters,
      );
      _applyCurrentFilters();
    });
  }

  void _applyLowStockQuickFilter() {
    if (_collections == null) {
      return;
    }

    final baseCriteria =
        _filterCriteria ??
        FilterCriteria(lowStockThreshold: _lowStockThreshold);
    final nextLowStockOnly = !baseCriteria.lowStockOnly;

    setState(() {
      _filterCriteria = FilterCriteria(
        status: baseCriteria.status,
        location: baseCriteria.location,
        lowStockOnly: nextLowStockOnly,
        lowStockThreshold: _lowStockThreshold,
        priceRange: baseCriteria.priceRange,
        tagFilters: baseCriteria.tagFilters,
      );
      _applyCurrentFilters();
    });
  }

  void _clearAllFiltersQuickAction() {
    setState(() {
      _filterCriteria = null;
      _filteredItems = null;
    });
  }

  Future<void> _onLowStockThresholdChanged(int threshold) async {
    if (threshold <= 0) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lowStockThresholdPrefKey, threshold);

    if (!mounted) {
      return;
    }

    setState(() {
      _lowStockThreshold = threshold;
      if (_filterCriteria != null) {
        _filterCriteria = FilterCriteria(
          status: _filterCriteria!.status,
          location: _filterCriteria!.location,
          lowStockOnly: _filterCriteria!.lowStockOnly,
          lowStockThreshold: threshold,
          priceRange: _filterCriteria!.priceRange,
          tagFilters: _filterCriteria!.tagFilters,
        );
      }
      _applyCurrentFilters();
    });
  }

  void _applyCurrentFilters() {
    if (_collections == null) {
      _filteredItems = null;
      return;
    }

    if (_filterCriteria != null) {
      _filterCriteria = _normalizeCriteria(_filterCriteria!);
    }

    final activeCriteria =
        _filterCriteria ??
        FilterCriteria(lowStockThreshold: _lowStockThreshold);

    if (!activeCriteria.hasActiveFilters) {
      _filteredItems = null;
      return;
    }

    _filteredItems = activeCriteria.apply(
      _collections!.items,
      _collections!.maxPrice,
    );
  }

  FilterCriteria _normalizeCriteria(FilterCriteria criteria) {
    if (_collections == null) {
      return criteria;
    }

    final currentCollections = _collections!;
    final statusOptions = currentCollections.getAllStatuses();
    final locationOptions = currentCollections.getAllLocations();
    final availableTagOptions = <String, Set<String>>{};

    for (final tag in currentCollections.getAllTags()) {
      availableTagOptions[tag.name] = Set<String>.from(
        tag.options ?? <String>{},
      );
    }

    final normalizedTagFilters = <String, Set<String>>{};
    criteria.tagFilters.forEach((tagName, selectedOptions) {
      final optionsForTag = availableTagOptions[tagName];
      if (optionsForTag == null || selectedOptions.isEmpty) {
        return;
      }

      final validSelections = selectedOptions
          .where((option) => optionsForTag.contains(option))
          .toSet();
      if (validSelections.isNotEmpty) {
        normalizedTagFilters[tagName] = validSelections;
      }
    });

    return FilterCriteria(
      status: statusOptions.contains(criteria.status) ? criteria.status : null,
      location: locationOptions.contains(criteria.location)
          ? criteria.location
          : null,
      lowStockOnly: criteria.lowStockOnly,
      lowStockThreshold: criteria.lowStockThreshold,
      priceRange: criteria.priceRange,
      tagFilters: normalizedTagFilters,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_collections == null) {
      return MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          appBar: AppBar(title: const Text('My Inventory')),
          body: Center(
            child: _loadErrorMessage == null
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_loadErrorMessage!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          unawaited(_loadCollections());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
          ),
        ),
      );
    }

    return MaterialApp(
      theme: buildAppTheme(),
      navigatorKey: _navigatorKey,
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('My Inventory'),
          actions: [
            IconButton(
              onPressed: () {
                unawaited(_openSettings());
              },
              tooltip: 'Open settings',
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: const Icon(Icons.settings_outlined),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: SafeArea(
          child: Scroll(
            collections: _collections!,
            filteredItems: _filteredItems,
            onAddPressed: () {
              unawaited(_openNewItem());
            },
            onItemsChanged: _refreshItems,
            lowStockThreshold: _lowStockThreshold,
            onLowStockThresholdChanged: _onLowStockThresholdChanged,
            onItemsTilePressed: _clearAllFiltersQuickAction,
            lowStockFilterActive: _filterCriteria?.lowStockOnly ?? false,
            onLowStockTilePressed: _applyLowStockQuickFilter,
            onOpenFilters: () {
              unawaited(_openFiltersPanel());
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            unawaited(_openNewItem());
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Item'),
        ),
      ),
    );
  }
}

Set<String> _defaultLocations() {
  return {};
}

Set<String> _defaultStatuses() {
  return {};
}

List<Item> _defaultItems() {
  return [];
}

Set<Tag> _defaultTags() {
  return {};
}

class Scroll extends StatefulWidget {
  final Collections collections;
  final List<Item>? filteredItems;
  final VoidCallback onAddPressed;
  final VoidCallback onItemsChanged;
  final int lowStockThreshold;
  final ValueChanged<int> onLowStockThresholdChanged;
  final VoidCallback onItemsTilePressed;
  final bool lowStockFilterActive;
  final VoidCallback onLowStockTilePressed;
  final VoidCallback onOpenFilters;

  const Scroll({
    super.key,
    required this.collections,
    required this.filteredItems,
    required this.onAddPressed,
    required this.onItemsChanged,
    required this.lowStockThreshold,
    required this.onLowStockThresholdChanged,
    required this.onItemsTilePressed,
    required this.lowStockFilterActive,
    required this.onLowStockTilePressed,
    required this.onOpenFilters,
  });

  @override
  State<Scroll> createState() => _ScrollState();
}

enum SortOption { nameAsc, priceLowToHigh, priceHighToLow, statusAsc }

class _ScrollState extends State<Scroll> {
  static const String _searchPrefKey = 'inventory.searchQuery';
  static const String _sortPrefKey = 'inventory.sortOption';

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  SortOption _sortOption = SortOption.nameAsc;

  @override
  void initState() {
    super.initState();
    unawaited(_restoreListPreferences());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _restoreListPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSearch = prefs.getString(_searchPrefKey) ?? '';
    final savedSortIndex = prefs.getInt(_sortPrefKey);

    if (!mounted) {
      return;
    }

    final savedSort =
        savedSortIndex != null &&
            savedSortIndex >= 0 &&
            savedSortIndex < SortOption.values.length
        ? SortOption.values[savedSortIndex]
        : SortOption.nameAsc;

    setState(() {
      _searchQuery = savedSearch;
      _searchController.text = savedSearch;
      _sortOption = savedSort;
    });
  }

  Future<void> _persistListPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_searchPrefKey, _searchQuery);
    await prefs.setInt(_sortPrefKey, _sortOption.index);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
    unawaited(_persistListPreferences());
  }

  List<Item> _buildVisibleItems() {
    final baseItems = List<Item>.from(
      widget.filteredItems ?? widget.collections.items,
    );
    final query = _searchQuery.trim().toLowerCase();

    final filteredBySearch = query.isEmpty
        ? baseItems
        : baseItems.where((item) {
            return item.name.toLowerCase().contains(query) ||
                (item.location?.toLowerCase().contains(query) ?? false) ||
                (item.status?.toLowerCase().contains(query) ?? false);
          }).toList();

    switch (_sortOption) {
      case SortOption.nameAsc:
        filteredBySearch.sort((a, b) => a.name.compareTo(b.name));
        return filteredBySearch;
      case SortOption.priceLowToHigh:
        filteredBySearch.sort((a, b) => a.price.compareTo(b.price));
        return filteredBySearch;
      case SortOption.priceHighToLow:
        filteredBySearch.sort((a, b) => b.price.compareTo(a.price));
        return filteredBySearch;
      case SortOption.statusAsc:
        filteredBySearch.sort(
          (a, b) => (a.status ?? '').compareTo(b.status ?? ''),
        );
        return filteredBySearch;
    }
  }

  String _sortLabel(SortOption option) {
    switch (option) {
      case SortOption.nameAsc:
        return 'Name (A-Z)';
      case SortOption.priceLowToHigh:
        return 'Price (Low-High)';
      case SortOption.priceHighToLow:
        return 'Price (High-Low)';
      case SortOption.statusAsc:
        return 'Status (A-Z)';
    }
  }

  Widget _buildSortChip(SortOption option) {
    final selected = _sortOption == option;
    return ChoiceChip(
      label: Text(_sortLabel(option)),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) {
        setState(() {
          _sortOption = option;
        });
        unawaited(_persistListPreferences());
      },
    );
  }

  Widget _buildOverviewCard({
    required BuildContext context,
    required int totalItems,
    required int visibleItems,
    required int lowStockItems,
    required double inventoryValue,
    required bool hasFilters,
    required bool hasSearch,
    required bool lowStockFilterActive,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final isCompact = viewportWidth < 600;
    final heroHeight = viewportWidth >= 760
        ? 220.0
        : (isCompact ? 188.0 : 216.0);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: heroHeight),
      padding: EdgeInsets.all(isCompact ? 14 : 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.98),
            colorScheme.surfaceContainerHigh,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: isCompact ? -16 : -24,
            right: isCompact ? -14 : -18,
            child: IgnorePointer(
              child: Container(
                width: isCompact ? 96 : 140,
                height: isCompact ? 96 : 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withValues(alpha: 0.10),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 10 : 12,
                      vertical: isCompact ? 6 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warehouse_outlined,
                          size: isCompact ? 16 : 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          hasFilters || hasSearch
                              ? 'Focused inventory view'
                              : 'Inventory snapshot',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontSize: isCompact ? 13 : null,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasFilters)
                    _buildStatusPill(
                      context,
                      icon: Icons.tune,
                      label: 'Filters applied',
                    ),
                  if (hasSearch)
                    _buildStatusPill(
                      context,
                      icon: Icons.search,
                      label: 'Search active',
                    ),
                ],
              ),
              SizedBox(height: isCompact ? 12 : 18),
              Text(
                'Keep every item easy to scan and act on.',
                style:
                    (isCompact
                            ? theme.textTheme.titleLarge
                            : theme.textTheme.headlineSmall)
                        ?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
              ),
              SizedBox(height: isCompact ? 12 : 20),
              Wrap(
                spacing: isCompact ? 8 : 12,
                runSpacing: isCompact ? 8 : 12,
                children: [
                  _buildMetricCard(
                    context,
                    label: 'Items',
                    value: '$totalItems',
                    icon: Icons.inventory_2_outlined,
                    onTap: widget.onItemsTilePressed,
                    semanticHint: 'Clears quick filters and shows all items.',
                    compact: isCompact,
                  ),
                  _buildMetricCard(
                    context,
                    label: 'Low stock',
                    value: '$lowStockItems',
                    icon: Icons.warning_amber_outlined,
                    accentColor: lowStockItems > 0
                        ? colorScheme.tertiary
                        : colorScheme.primary,
                    isSelected: lowStockFilterActive,
                    onTap: widget.onLowStockTilePressed,
                    semanticHint: 'Toggles the low stock quick filter.',
                    compact: isCompact,
                  ),
                  _buildMetricCard(
                    context,
                    label: 'Value',
                    value: '\$${inventoryValue.toStringAsFixed(0)}',
                    icon: Icons.paid_outlined,
                    compact: isCompact,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    Color? accentColor,
    bool isSelected = false,
    VoidCallback? onTap,
    String? semanticHint,
    bool compact = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final resolvedAccent = accentColor ?? colorScheme.primary;

    final card = Container(
      constraints: BoxConstraints(minWidth: compact ? 110 : 132),
      padding: EdgeInsets.all(compact ? 10 : 14),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(compact ? 16 : 20),
        border: Border.all(
          color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: compact ? 30 : 36,
            height: compact ? 30 : 36,
            decoration: BoxDecoration(
              color: resolvedAccent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(compact ? 10 : 12),
            ),
            child: Icon(icon, size: compact ? 17 : 20, color: resolvedAccent),
          ),
          SizedBox(height: compact ? 8 : 12),
          Text(
            value,
            style:
                (compact
                        ? theme.textTheme.titleMedium
                        : theme.textTheme.titleLarge)
                    ?.copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: compact ? 2 : 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: compact ? 11.5 : null,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return card;
    }

    final radius = BorderRadius.circular(compact ? 16 : 20);
    return Semantics(
      button: true,
      selected: isSelected,
      label: '$label: $value',
      hint: semanticHint,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          canRequestFocus: true,
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.focused)) {
              return colorScheme.primary.withValues(alpha: 0.22);
            }
            if (states.contains(WidgetState.hovered)) {
              return colorScheme.primary.withValues(alpha: 0.08);
            }
            return null;
          }),
          onTap: onTap,
          child: card,
        ),
      ),
    );
  }

  Widget _buildControlPanel(
    BuildContext context, {
    required bool hasFilters,
    required bool hasSearch,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search inventory',
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search name, location, or status',
                    border: const OutlineInputBorder(),
                    suffixIcon: hasSearch
                        ? IconButton(
                            onPressed: _clearSearch,
                            icon: const Icon(Icons.clear),
                            tooltip: 'Clear search',
                            constraints: const BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    unawaited(_persistListPreferences());
                  },
                ),
              ),
              const SizedBox(width: 10),
              FilledButton.tonalIcon(
                onPressed: widget.onOpenFilters,
                icon: Badge.count(
                  isLabelVisible: hasFilters,
                  count: 1,
                  child: const Icon(Icons.tune),
                ),
                label: Text(hasFilters ? 'Filtered' : 'Filters'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Sort by',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in SortOption.values) _buildSortChip(option),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader(
    BuildContext context, {
    required int visibleCount,
    required int totalCount,
    required bool hasFilters,
    required bool hasSearch,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final subtitle = hasSearch
        ? 'Search is narrowing your inventory view.'
        : hasFilters
        ? 'Filters are highlighting a focused subset of items.'
        : 'Everything in your inventory, ready to browse.';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your items',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$visibleCount of $totalCount visible. $subtitle',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        if (hasSearch || hasFilters)
          TextButton.icon(
            onPressed: hasSearch ? _clearSearch : widget.onOpenFilters,
            icon: Icon(hasSearch ? Icons.close : Icons.tune),
            label: Text(hasSearch ? 'Clear search' : 'Edit filters'),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemsToDisplay = _buildVisibleItems();
    final hasFilters = widget.filteredItems != null;
    final hasSearch = _searchQuery.trim().isNotEmpty;
    final hasNoItems = widget.collections.items.isEmpty;
    final totalItems = widget.collections.items.length;
    final visibleCount = itemsToDisplay.length;
    final lowStockCount = widget.collections.items
        .where((item) => item.quantity <= widget.lowStockThreshold)
        .length;
    final inventoryValue = widget.collections.items.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    String emptyStateMessage = 'No items yet. Tap + to add your first item.';
    if (hasFilters) {
      emptyStateMessage = 'No items match your current filters.';
    }
    if (hasSearch) {
      emptyStateMessage = 'No items match your search.';
    }

    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: FocusTraversalOrder(
              order: const NumericFocusOrder(1),
              child: _buildOverviewCard(
                context: context,
                totalItems: totalItems,
                visibleItems: visibleCount,
                lowStockItems: lowStockCount,
                inventoryValue: inventoryValue,
                hasFilters: hasFilters,
                hasSearch: hasSearch,
                lowStockFilterActive: widget.lowStockFilterActive,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: FocusTraversalOrder(
              order: const NumericFocusOrder(2),
              child: _buildControlPanel(
                context,
                hasFilters: hasFilters,
                hasSearch: hasSearch,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Column(
              children: [
                _buildResultsHeader(
                  context,
                  visibleCount: visibleCount,
                  totalCount: totalItems,
                  hasFilters: hasFilters,
                  hasSearch: hasSearch,
                ),
                const SizedBox(height: 12),
                if (itemsToDisplay.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Center(
                      child: Container(
                        width: math.min(
                          MediaQuery.sizeOf(context).width - 48,
                          560,
                        ),
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primaryContainer
                                  .withValues(alpha: 0.38),
                              Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHigh,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 74,
                              height: 74,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surface.withValues(alpha: 0.72),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.inventory_2_outlined,
                                size: 36,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              hasNoItems
                                  ? 'Start building your inventory'
                                  : 'No items in this view',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              emptyStateMessage,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: widget.onAddPressed,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Item'),
                            ),
                            if (hasSearch)
                              TextButton(
                                onPressed: _clearSearch,
                                child: const Text('Clear Search'),
                              ),
                            if (hasFilters && !hasNoItems)
                              TextButton(
                                onPressed: widget.onOpenFilters,
                                child: const Text('Adjust Filters'),
                              ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: ListView.builder(
                      key: ValueKey(
                        '${itemsToDisplay.length}-${_sortOption.name}-${_searchQuery.trim()}',
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 12),
                      itemCount: itemsToDisplay.length,
                      itemBuilder: (context, index) {
                        final item = itemsToDisplay[index];
                        final durationMs = 180 + (index * 18).clamp(0, 180);

                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: Duration(milliseconds: durationMs),
                          curve: Curves.easeOutCubic,
                          child: ItemRow(
                            key: ValueKey(item.id),
                            i: item,
                            index: index,
                            collections: widget.collections,
                            onChanged: widget.onItemsChanged,
                            lowStockThreshold: widget.lowStockThreshold,
                          ),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, (1 - value) * 10),
                                child: child,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
