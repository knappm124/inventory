import 'package:flutter/material.dart';
import 'package:inventory/utilities/collections.dart';

class FilterCriteria {
  final String? status;
  final String? location;
  final RangeValues? priceRange;
  final Set<String> color;
  final Set<String> size;
  final Set<String> occasion;
  final Set<String> symbols;
  final Set<String> division;

  const FilterCriteria({
    this.status,
    this.location,
    this.priceRange,
    this.color = const {},
    this.size = const {},
    this.occasion = const {},
    this.symbols = const {},
    this.division = const {},
  });

  bool get hasActiveFilters {
    return status != null ||
        location != null ||
        priceRange != null ||
        color.isNotEmpty ||
        size.isNotEmpty ||
        occasion.isNotEmpty ||
        symbols.isNotEmpty ||
        division.isNotEmpty;
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
      bool matchColor = true;
      if (color.isNotEmpty) {
        matchColor = color.any((c) => item.containsTag('Color', c));
      }
      bool matchSize = true;
      if (size.isNotEmpty) {
        matchSize = size.any((s) => item.containsTag('Size', s));
      }
      bool matchOccasion = true;
      if (occasion.isNotEmpty) {
        matchOccasion = occasion.any((o) => item.containsTag('Occasion', o));
      }
      bool matchSymbols = true;
      if (symbols.isNotEmpty) {
        matchSymbols = symbols.any((s) => item.containsTag('Symbols', s));
      }
      bool matchDivision = true;
      if (division.isNotEmpty) {
        matchDivision = division.any((d) => item.containsTag('Division', d));
      }
      return matchStatus &&
          matchLocation &&
          matchPrice &&
          matchColor &&
          matchSize &&
          matchOccasion &&
          matchSymbols &&
          matchDivision;
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
  Set<String> color = {};
  Set<String> size = {};
  Set<String> occasion = {};
  Set<String> symbols = {};
  Set<String> division = {};
  late double maxPrice;
  late RangeValues _currentRangeValues;

  @override
  void initState() {
    super.initState();
    c = widget.c;
    status = widget.criteria.status;
    location = widget.criteria.location;
    color = Set<String>.from(widget.criteria.color);
    size = Set<String>.from(widget.criteria.size);
    occasion = Set<String>.from(widget.criteria.occasion);
    symbols = Set<String>.from(widget.criteria.symbols);
    division = Set<String>.from(widget.criteria.division);
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
      color = Set<String>.from(widget.criteria.color);
      size = Set<String>.from(widget.criteria.size);
      occasion = Set<String>.from(widget.criteria.occasion);
      symbols = Set<String>.from(widget.criteria.symbols);
      division = Set<String>.from(widget.criteria.division);
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
      color: color,
      size: size,
      occasion: occasion,
      symbols: symbols,
      division: division,
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
            segments: const <ButtonSegment<String>>[
              ButtonSegment<String>(value: 'WIP', label: Text('WIP')),
              ButtonSegment<String>(value: 'Listed', label: Text('Listed')),
              ButtonSegment<String>(value: 'Sold', label: Text('Sold')),
              ButtonSegment<String>(value: 'Returned', label: Text('Returned')),
            ],
            emptySelectionAllowed: true,
            selected: <String>{?status},
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
            segments: const <ButtonSegment<String>>[
              ButtonSegment<String>(value: 'Home', label: Text('Home')),
              ButtonSegment<String>(value: 'Etsy', label: Text('Etsy')),
              ButtonSegment<String>(
                value: 'General Store',
                label: Text('General Store'),
              ),
            ],
            emptySelectionAllowed: true,
            selected: <String>{?location},
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
          _buildChipSection(
            title: "Color",
            options: const [
              'Red',
              'Orange',
              'Yellow',
              'Green',
              'Blue',
              'Purple',
              'Pink',
              'Brown',
              'Black',
            ],
            selected: color,
            onChanged: (newValue) {
              setState(() {
                color = newValue;
              });
              _filterList();
            },
          ),
          _buildChipSection(
            title: "Size",
            options: const [
              'Quail',
              'Pullet',
              'Chicken',
              'Duck',
              'Goose',
              'Rhea',
              'Ostrich',
            ],
            selected: size,
            onChanged: (newValue) {
              setState(() {
                size = newValue;
              });
              _filterList();
            },
          ),
          _buildChipSection(
            title: "Occasion",
            options: const [
              'Baby',
              'Christmas',
              'Easter',
              'Fall',
              'Spring',
              'Wedding',
            ],
            selected: occasion,
            onChanged: (newValue) {
              setState(() {
                occasion = newValue;
              });
              _filterList();
            },
          ),
          _buildChipSection(
            title: "Symbols",
            options: const ['Animal', 'Person', 'Plants', 'Religious', 'Star'],
            selected: symbols,
            onChanged: (newValue) {
              setState(() {
                symbols = newValue;
              });
              _filterList();
            },
          ),
          _buildChipSection(
            title: "Division",
            options: const [
              'Band',
              'Circles',
              'Diagonal Band',
              'Four Panels',
              'Star',
            ],
            selected: division,
            onChanged: (newValue) {
              setState(() {
                division = newValue;
              });
              _filterList();
            },
          ),
        ],
      ),
    );
  }
}
