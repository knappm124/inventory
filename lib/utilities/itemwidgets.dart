import 'package:flutter/material.dart';
import 'package:inventory/utilities/editing.dart';

import 'collections.dart';
import 'image_utils.dart';

class ItemIcons extends StatelessWidget {
  final Item i;
  final Collections collections;
  final ValueChanged<Item> onItemUpdated;
  final VoidCallback onItemsChanged;

  const ItemIcons({
    super.key,
    required this.i,
    required this.collections,
    required this.onItemUpdated,
    required this.onItemsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: () async {
            final updatedItem = await Navigator.of(context).push<Item?>(
              MaterialPageRoute(
                builder: (context) =>
                    EditingItem(i: i, collections: collections),
              ),
            );
            if (updatedItem != null) {
              onItemUpdated(updatedItem);
            }
          },
          tooltip: 'Edit item',
          icon: const Icon(Icons.edit_outlined),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          onPressed: () async {
            final navigator = Navigator.of(context);
            final messenger = ScaffoldMessenger.of(context);
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Delete item?'),
                  content: Text('Delete "${i.name}" from your inventory?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                );
              },
            );

            if (confirmed != true) {
              return;
            }

            collections.removeItem(i);
            onItemsChanged();
            messenger.showSnackBar(
              SnackBar(
                content: Text('Deleted "${i.name}"'),
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    collections.addItem(i);
                    onItemsChanged();
                  },
                ),
              ),
            );
            navigator.pop();
          },
          tooltip: 'Delete item',
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }
}

class ItemRow extends StatelessWidget {
  final Item i;
  final int index;
  final Collections collections;
  final VoidCallback onChanged;
  final int lowStockThreshold;

  const ItemRow({
    super.key,
    required this.i,
    required this.index,
    required this.collections,
    required this.onChanged,
    required this.lowStockThreshold,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLowStock = i.quantity <= lowStockThreshold;
    final imageCount = i.images.isNotEmpty
        ? i.images.length
        : ((i.img?.isNotEmpty ?? false) ? 1 : 0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () async {
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => EditableItem(
                  i: i,
                  collections: collections,
                  onItemsChanged: onChanged,
                ),
              ),
            );
            if (result == true) {
              onChanged();
            }
          },
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: colorScheme.outlineVariant),
              gradient: LinearGradient(
                colors: [
                  colorScheme.surface,
                  colorScheme.surfaceContainerLowest,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 108,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primaryContainer.withValues(
                                alpha: 0.72,
                              ),
                              colorScheme.surfaceContainerHigh,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: buildInventoryImage(
                            source: i.img ?? '',
                            width: 96,
                            height: 108,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (imageCount > 1)
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surface.withValues(
                                alpha: 0.92,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.photo_library_outlined,
                                  size: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$imageCount',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    i.name,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    i.location ?? 'No location set',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${i.price.toStringAsFixed(2)}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text('Value', style: theme.textTheme.bodySmall),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 14,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _buildInlineMeta(
                              context,
                              icon: Icons.inventory_2_outlined,
                              label: 'Qty ${i.quantity}',
                            ),
                            _buildInlineMeta(
                              context,
                              icon: Icons.label_important_outline,
                              label: i.status ?? 'No status',
                            ),
                            if (isLowStock)
                              _buildInfoPill(
                                context,
                                icon: Icons.warning_amber_outlined,
                                label: 'Low stock',
                                accentColor: colorScheme.errorContainer,
                                foregroundColor: colorScheme.onErrorContainer,
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                imageCount > 1
                                    ? '$imageCount photos attached'
                                    : 'Tap to open item details',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EditableItem extends StatefulWidget {
  final Item i;
  final Collections collections;
  final VoidCallback onItemsChanged;

  const EditableItem({
    super.key,
    required this.i,
    required this.collections,
    required this.onItemsChanged,
  });

  @override
  State<EditableItem> createState() => _EditableItemState();
}

class _EditableItemState extends State<EditableItem> {
  late Item _item;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _item = widget.i;
  }

  void _handleItemUpdated(Item updatedItem) {
    setState(() {
      _item = updatedItem;
      _selectedImageIndex = 0;
    });
    widget.onItemsChanged();
  }

  String _activeImage() {
    final images = _item.images;
    if (images.isEmpty) {
      return _item.img ?? '';
    }

    if (_selectedImageIndex < 0 || _selectedImageIndex >= images.length) {
      _selectedImageIndex = 0;
    }

    return images[_selectedImageIndex];
  }

  void _adjustQuantity(int delta) {
    final nextQuantity = (_item.quantity + delta).clamp(1, 9999999);
    if (nextQuantity == _item.quantity) {
      return;
    }

    final updatedItem = Item(
      _item.id,
      _item.name,
      _item.price,
      nextQuantity,
      _item.location,
      _item.status,
      _item.img,
      _item.images,
      _item.tags,
    );

    widget.collections.editItem(updatedItem);
    setState(() {
      _item = updatedItem;
    });
    widget.onItemsChanged();
  }

  @override
  Widget build(BuildContext context) {
    final sortedTagNames = (_item.tags?.keys.toList() ?? <String>[])..sort();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final images = _item.images;
    final isLowStock = _item.quantity <= 5;

    return Scaffold(
      appBar: AppBar(title: const Text('Item Details')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 760;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primaryContainer.withValues(
                              alpha: 0.95,
                            ),
                            colorScheme.surfaceContainerHigh,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.85,
                          ),
                        ),
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        runSpacing: 16,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _item.name,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _item.location ?? 'No location assigned',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 10,
                                  children: [
                                    _buildInlineMeta(
                                      context,
                                      icon: Icons.paid_outlined,
                                      label:
                                          '\$${_item.price.toStringAsFixed(2)}',
                                    ),
                                    _buildInlineMeta(
                                      context,
                                      icon: Icons.inventory_2_outlined,
                                      label: 'Qty ${_item.quantity}',
                                    ),
                                    _buildInlineMeta(
                                      context,
                                      icon: Icons.label_important_outline,
                                      label: _item.status ?? 'No status',
                                    ),
                                    if (isLowStock)
                                      _buildInfoPill(
                                        context,
                                        icon: Icons.warning_amber_outlined,
                                        label: 'Low stock',
                                        accentColor: colorScheme.errorContainer,
                                        foregroundColor:
                                            colorScheme.onErrorContainer,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surface.withValues(
                                alpha: 0.72,
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              images.length > 1
                                  ? '${images.length} photos saved'
                                  : 'Single photo view',
                              style: theme.textTheme.labelLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Flex(
                      direction: isWide ? Axis.horizontal : Axis.vertical,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: isWide ? 2 : 0,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: colorScheme.outlineVariant,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.shadow.withValues(
                                    alpha: 0.04,
                                  ),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    gradient: LinearGradient(
                                      colors: [
                                        colorScheme.primaryContainer.withValues(
                                          alpha: 0.5,
                                        ),
                                        colorScheme.surfaceContainerHigh,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Center(
                                    child: buildInventoryImage(
                                      source: _activeImage(),
                                      width: isWide ? 400 : 300,
                                      height: 280,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                if (images.length > 1) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    'Gallery',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 92,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: images.length,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(width: 10),
                                      itemBuilder: (context, index) {
                                        final selected =
                                            _selectedImageIndex == index;
                                        return InkWell(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          onTap: () {
                                            setState(() {
                                              _selectedImageIndex = index;
                                            });
                                          },
                                          child: Container(
                                            width: 92,
                                            padding: const EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: selected
                                                    ? colorScheme.primary
                                                    : colorScheme
                                                          .outlineVariant,
                                                width: selected ? 2 : 1,
                                              ),
                                              color: selected
                                                  ? colorScheme.primaryContainer
                                                        .withValues(alpha: 0.35)
                                                  : colorScheme
                                                        .surfaceContainerLowest,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(13),
                                              child: buildInventoryImage(
                                                source: images[index],
                                                width: 86,
                                                height: 86,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: isWide ? 16 : 0,
                          height: isWide ? 0 : 16,
                        ),
                        Expanded(
                          flex: isWide ? 1 : 0,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: colorScheme.outlineVariant,
                              ),
                            ),
                            child: EditableItemHeader(
                              i: _item,
                              collections: widget.collections,
                              onItemUpdated: _handleItemUpdated,
                              onItemsChanged: widget.onItemsChanged,
                              onAdjustQuantity: _adjustQuantity,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Inventory Details',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _buildDetailStat(
                                context,
                                label: 'Price',
                                value: '\$${_item.price.toStringAsFixed(2)}',
                                icon: Icons.paid_outlined,
                              ),
                              _buildDetailStat(
                                context,
                                label: 'Quantity',
                                value: '${_item.quantity}',
                                icon: Icons.inventory_2_outlined,
                              ),
                              _buildDetailStat(
                                context,
                                label: 'Location',
                                value: _item.location ?? 'Not set',
                                icon: Icons.place_outlined,
                              ),
                              _buildDetailStat(
                                context,
                                label: 'Status',
                                value: _item.status ?? 'Not set',
                                icon: Icons.label_important_outline,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (sortedTagNames.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tags',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 14),
                            for (final name in sortedTagNames)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: theme.textTheme.labelLarge,
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        for (final option
                                            in ((_item.tags?[name]?.toList() ??
                                                  <String>[])
                                              ..sort()))
                                          _buildInfoPill(
                                            context,
                                            icon: Icons.sell_outlined,
                                            label: option,
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class EditableItemHeader extends StatelessWidget {
  final Item i;
  final Collections collections;
  final ValueChanged<Item> onItemUpdated;
  final VoidCallback onItemsChanged;
  final ValueChanged<int> onAdjustQuantity;

  const EditableItemHeader({
    super.key,
    required this.i,
    required this.collections,
    required this.onItemUpdated,
    required this.onItemsChanged,
    required this.onAdjustQuantity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Adjust quantity or jump into editing without leaving this screen.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Quantity', style: theme.textTheme.labelLarge),
              const SizedBox(height: 10),
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: () => onAdjustQuantity(-1),
                    icon: const Icon(Icons.remove),
                    tooltip: 'Decrease quantity',
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${i.quantity}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    onPressed: () => onAdjustQuantity(1),
                    icon: const Icon(Icons.add),
                    tooltip: 'Increase quantity',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ItemIcons(
          i: i,
          collections: collections,
          onItemUpdated: onItemUpdated,
          onItemsChanged: onItemsChanged,
        ),
      ],
    );
  }
}

Widget _buildInfoPill(
  BuildContext context, {
  required IconData icon,
  required String label,
  bool emphasized = false,
  Color? accentColor,
  Color? foregroundColor,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final backgroundColor =
      accentColor ??
      (emphasized
          ? colorScheme.primaryContainer.withValues(alpha: 0.58)
          : colorScheme.surfaceContainerLowest);
  final textColor =
      foregroundColor ??
      (emphasized
          ? colorScheme.onPrimaryContainer
          : colorScheme.onSurfaceVariant);

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(
        color: emphasized ? Colors.transparent : colorScheme.outlineVariant,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: textColor),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

Widget _buildInlineMeta(
  BuildContext context, {
  required IconData icon,
  required String label,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
      const SizedBox(width: 6),
      Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

Widget _buildDetailStat(
  BuildContext context, {
  required String label,
  required String value,
  required IconData icon,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  return Container(
    constraints: const BoxConstraints(minWidth: 150),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: colorScheme.outlineVariant),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colorScheme.primary),
        const SizedBox(height: 10),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
}
