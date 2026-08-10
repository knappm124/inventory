import 'package:flutter/material.dart';
import 'package:inventory/utilities/collections.dart';

class FilterCriteria {
  static const int defaultLowStockThreshold = 5;

  final String? status;
  final String? location;
  final bool lowStockOnly;
  final int lowStockThreshold;
  final RangeValues? priceRange;
  final Map<String, Set<String>> tagFilters;

  const FilterCriteria({
    this.status,
    this.location,
    this.lowStockOnly = false,
    this.lowStockThreshold = defaultLowStockThreshold,
    this.priceRange,
    this.tagFilters = const {},
  });

  bool get hasActiveFilters {
    return status != null ||
        location != null ||
        lowStockOnly ||
        priceRange != null ||
        tagFilters.values.any((values) => values.isNotEmpty);
  }

  List<Item> apply(List<Item> items, double maxPrice) {
    final effectiveMaxPrice = maxPrice < 10 ? 10.0 : maxPrice;
    final range = priceRange ?? RangeValues(0, effectiveMaxPrice);

    return items.where((item) {
      bool matchStatus = true;
      if (status != null) {
        matchStatus = item.hasStatus(status!);
      }

      bool matchLocation = true;
      if (location != null) {
        matchLocation = item.hasLocation(location!);
      }
      final matchLowStock = !lowStockOnly || item.quantity <= lowStockThreshold;
      final matchPrice = item.priceBetween(range.start, range.end);

      final matchTags = tagFilters.entries.every((entry) {
        final selectedOptions = entry.value;
        if (selectedOptions.isEmpty) return true;
        return selectedOptions.any(
          (option) => item.containsOption(entry.key, option),
        );
      });

      return matchStatus &&
          matchLocation &&
          matchLowStock &&
          matchPrice &&
          matchTags;
    }).toList();
  }
}

class Filter extends StatefulWidget {
  final Collections c;
  final ValueChanged<List<Item>> onFilterChanged;
  final ValueChanged<FilterCriteria> onCriteriaChanged;
  final FilterCriteria criteria;

  const Filter({
    super.key,
    required this.c,
    required this.onFilterChanged,
    required this.onCriteriaChanged,
    required this.criteria,
  });

  @override
  State<StatefulWidget> createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  late Collections c;
  late List<Item> filtered;
  String? status;
  String? location;
  bool lowStockOnly = false;
  late int lowStockThreshold;
  Map<String, Set<String>> tagFilters = {};
  late double maxPrice;
  late RangeValues _currentRangeValues;

  @override
  void initState() {
    super.initState();
    c = widget.c;
    status = widget.criteria.status;
    location = widget.criteria.location;
    lowStockOnly = widget.criteria.lowStockOnly;
    lowStockThreshold = widget.criteria.lowStockThreshold;
    tagFilters = widget.criteria.tagFilters.map(
      (key, value) => MapEntry(key, Set<String>.from(value)),
    );
    maxPrice = c.maxPrice;
    if (maxPrice < 10) {
      maxPrice = 10;
    }
    _currentRangeValues =
        widget.criteria.priceRange ?? RangeValues(0, maxPrice);
    filtered = widget.criteria.apply(c.items, maxPrice);
    // Notify parent of initial filtered items
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCriteriaChanged(widget.criteria);
      widget.onFilterChanged(filtered);
    });
  }

  @override
  void didUpdateWidget(covariant Filter oldWidget) {
    super.didUpdateWidget(oldWidget);

    c = widget.c;
    final previousMaxPrice = maxPrice;
    maxPrice = c.maxPrice;
    if (maxPrice < 10) {
      maxPrice = 10;
    }

    final oldRangeCoveredMax = _currentRangeValues.end >= previousMaxPrice;
    final updatedEnd = oldRangeCoveredMax
        ? maxPrice
        : _currentRangeValues.end.clamp(0.0, maxPrice).toDouble();
    final updatedStart = _currentRangeValues.start
        .clamp(0.0, updatedEnd)
        .toDouble();
    _currentRangeValues = RangeValues(updatedStart, updatedEnd);

    if (oldWidget.criteria != widget.criteria) {
      status = widget.criteria.status;
      location = widget.criteria.location;
      lowStockOnly = widget.criteria.lowStockOnly;
      lowStockThreshold = widget.criteria.lowStockThreshold;
      tagFilters = widget.criteria.tagFilters.map(
        (key, value) => MapEntry(key, Set<String>.from(value)),
      );
      _currentRangeValues =
          widget.criteria.priceRange ?? RangeValues(0, maxPrice);
    }

    final criteria = _buildCriteria();
    filtered = criteria.apply(c.items, maxPrice);
  }

  FilterCriteria _buildCriteria() {
    final statusOptions = c.getAllStatuses();
    final locationOptions = c.getAllLocations();
    final effectiveStatus = status != null && statusOptions.contains(status)
        ? status
        : null;
    final effectiveLocation =
        location != null && locationOptions.contains(location)
        ? location
        : null;
    final isFullPriceRange =
        _currentRangeValues.start <= 0 && _currentRangeValues.end >= maxPrice;

    return FilterCriteria(
      status: effectiveStatus,
      location: effectiveLocation,
      lowStockOnly: lowStockOnly,
      lowStockThreshold: lowStockThreshold,
      priceRange: isFullPriceRange ? null : _currentRangeValues,
      tagFilters: tagFilters,
    );
  }

  Widget _buildChipSection({
    required String title,
    required List<String> options,
    required Set<String> selected,
    required ValueChanged<Set<String>> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            return FilterChip(
              label: Text(option),
              showCheckmark: false,
              selected: selected.contains(option),
              onSelected: (isSelected) {
                final updated = Set<String>.from(selected);
                if (isSelected) {
                  updated.add(option);
                } else {
                  updated.remove(option);
                }
                onChanged(updated);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  void _filterList() {
    setState(() {
      final criteria = _buildCriteria();
      filtered = criteria.apply(c.items, maxPrice);
      widget.onCriteriaChanged(criteria);
      widget.onFilterChanged(filtered);
    });
  }

  void _resetFilters() {
    setState(() {
      status = null;
      location = null;
      lowStockOnly = false;
      tagFilters = {};
      _currentRangeValues = RangeValues(0, maxPrice);
      final criteria = _buildCriteria();
      filtered = criteria.apply(c.items, maxPrice);
      widget.onCriteriaChanged(criteria);
      widget.onFilterChanged(filtered);
    });
  }

  @override
  Widget build(BuildContext context) {
    final statusOptions = c.getAllStatuses().toList()..sort();
    final locationOptions = c.getAllLocations().toList()..sort();
    final sortedTags = widget.c.tags.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedStatus = status != null && statusOptions.contains(status)
        ? <String>{status!}
        : <String>{};
    final selectedLocation =
        location != null && locationOptions.contains(location)
        ? <String>{location!}
        : <String>{};
    final hasActiveFilters = _buildCriteria().hasActiveFilters;
    final sectionTitleStyle = Theme.of(context).textTheme.titleSmall;

    return Material(
      color: colorScheme.surface,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [
                  colorScheme.primaryContainer.withValues(alpha: 0.95),
                  colorScheme.surfaceContainerHigh,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.85),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filters',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Narrow down your inventory list and focus on the items you need right now.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (hasActiveFilters)
                      TextButton.icon(
                        onPressed: _resetFilters,
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('Reset'),
                      ),
                    if (hasActiveFilters) const SizedBox(height: 6),
                    IconButton.filledTonal(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      tooltip: 'Close filters',
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          if (statusOptions.isNotEmpty) ...[
            _FilterSectionCard(
              title: 'Status',
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Semantics(
                      container: true,
                      label: 'Filter by status',
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SegmentedButton<String>(
                          showSelectedIcon: false,
                          segments: statusOptions
                              .map(
                                (value) => ButtonSegment<String>(
                                  value: value,
                                  label: Text(value),
                                ),
                              )
                              .toList(),
                          emptySelectionAllowed: true,
                          selected: selectedStatus,
                          onSelectionChanged: ((Set<String> newValue) {
                            setState(() {
                              status = newValue.firstOrNull;
                            });
                            _filterList();
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (locationOptions.isNotEmpty) ...[
            const SizedBox(height: 8),
            _FilterSectionCard(
              title: 'Location',
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Semantics(
                      container: true,
                      label: 'Filter by location',
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SegmentedButton<String>(
                          showSelectedIcon: false,
                          segments: locationOptions
                              .map(
                                (value) => ButtonSegment<String>(
                                  value: value,
                                  label: Text(value),
                                ),
                              )
                              .toList(),
                          emptySelectionAllowed: true,
                          selected: selectedLocation,
                          onSelectionChanged: ((Set<String> newValue) {
                            setState(() {
                              location = newValue.firstOrNull;
                            });
                            _filterList();
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          _FilterSectionCard(
            title: 'Stock & Price',
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('Low stock only (<= $lowStockThreshold)'),
                  subtitle: const Text(
                    'Show only items at or below your stock threshold.',
                  ),
                  value: lowStockOnly,
                  onChanged: (value) {
                    setState(() {
                      lowStockOnly = value;
                    });
                    _filterList();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Price', style: sectionTitleStyle),
                      const SizedBox(height: 4),
                      Text(
                        'Set a price band to limit the results.',
                        style: theme.textTheme.bodySmall,
                      ),
                      RangeSlider(
                        values: _currentRangeValues,
                        max: maxPrice,
                        divisions: maxPrice.round().toInt(),
                        labels: RangeLabels(
                          _currentRangeValues.start.round().toString(),
                          _currentRangeValues.end.round().toString(),
                        ),
                        onChanged: (RangeValues values) {
                          setState(() {
                            _currentRangeValues = values;
                            _filterList();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          for (final tag in sortedTags)
            if (tag.options != null && tag.options!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _FilterSectionCard(
                  title: tag.name,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildChipSection(
                      title: 'Options',
                      options: (tag.options!.toList()..sort()),
                      selected: tagFilters[tag.name] ?? {},
                      onChanged: (newValue) {
                        setState(() {
                          tagFilters = Map.from(tagFilters)
                            ..[tag.name] = newValue;
                        });
                        _filterList();
                      },
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _FilterSectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _FilterSectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
