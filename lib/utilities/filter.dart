import 'package:flutter/material.dart';
import 'package:inventory/utilities/collections.dart';

class FilterCriteria {
  final String? status;
  final String? location;
  final RangeValues? priceRange;

  const FilterCriteria({this.status, this.location, this.priceRange});

  bool get hasActiveFilters {
    return status != null || location != null || priceRange != null;
  }

  Set<Item> apply(Set<Item> items, double maxPrice) {
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
      return matchStatus && matchLocation && matchPrice;
    }).toSet();
  }
}

class Filter extends StatefulWidget {
  final Collections c;
  final ValueChanged<Set<Item>> onFilterChanged;
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
  late Set<Item> filtered;
  String? status;
  String? location;
  late double maxPrice;
  late RangeValues _currentRangeValues;

  @override
  void initState() {
    super.initState();
    c = widget.c;
    status = widget.criteria.status;
    location = widget.criteria.location;
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
        padding: EdgeInsets.zero,
        children: [
          Row(
            children: [
              Text("Filter"),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.expand_more),
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
        ],
      ),
    );
  }
}
