import 'package:flutter/material.dart';
import 'package:inventory/utilities/collections.dart';

class FilterCriteria {
  final String? status;
  final String? location;
  final RangeValues? priceRange;
  final Map<String, Set<String>> tagFilters;

  const FilterCriteria({
    this.status,
    this.location,
    this.priceRange,
    this.tagFilters = const {},
  });

  bool get hasActiveFilters {
    return status != null ||
        location != null ||
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
      final matchPrice = item.priceBetween(range.start, range.end);

      final matchTags = tagFilters.entries.every((entry) {
        final selectedOptions = entry.value;
        if (selectedOptions.isEmpty) return true;
        return selectedOptions.any(
          (option) => item.containsOption(entry.key, option),
        );
      });

      return matchStatus && matchLocation && matchPrice && matchTags;
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
  Map<String, Set<String>> tagFilters = {};
  late double maxPrice;
  late RangeValues _currentRangeValues;

  @override
  void initState() {
    super.initState();
    c = widget.c;
    status = widget.criteria.status;
    location = widget.criteria.location;
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
    final isFullPriceRange =
        _currentRangeValues.start <= 0 && _currentRangeValues.end >= maxPrice;

    return FilterCriteria(
      status: status,
      location: location,
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
        Text(title),
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

  @override
  Widget build(BuildContext context) {
    final statusOptions = c.getAllStatuses().toList()..sort();
    final locationOptions = c.getAllLocations().toList()..sort();
    final sortedTags = widget.c.tags.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final selectedStatus = status != null && statusOptions.contains(status)
        ? <String>{status!}
        : <String>{};
    final selectedLocation =
        location != null && locationOptions.contains(location)
        ? <String>{location!}
        : <String>{};

    return Drawer(
      width: 400,
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Padding(padding: EdgeInsets.only(top: 10)),
              Text("Filter"),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.chevron_left),
              ),
            ],
          ),
          Padding(padding: EdgeInsets.all(10)),
          Text("Status"),
          SegmentedButton<String>(
            showSelectedIcon: false,
            segments: statusOptions
                .map(
                  (value) =>
                      ButtonSegment<String>(value: value, label: Text(value)),
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
          Text("Location"),
          SegmentedButton<String>(
            showSelectedIcon: false,
            segments: locationOptions
                .map(
                  (value) =>
                      ButtonSegment<String>(value: value, label: Text(value)),
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
          Text("Price"),
          RangeSlider(
            values: _currentRangeValues,
            max: maxPrice,
            divisions:
                (maxPrice.round().toInt() -
                _currentRangeValues.start.round().toInt()),
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
          for (final tag in sortedTags)
            if (tag.options != null && tag.options!.isNotEmpty)
              _buildChipSection(
                title: tag.name,
                options: (tag.options!.toList()..sort()),
                selected: tagFilters[tag.name] ?? {},
                onChanged: (newValue) {
                  setState(() {
                    tagFilters = Map.from(tagFilters)..[tag.name] = newValue;
                  });
                  _filterList();
                },
              ),
        ],
      ),
    );
  }
}
