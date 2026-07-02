import 'package:flutter/material.dart';
import 'package:inventory/utilities/editing.dart';
import 'collections.dart';
import 'image_utils.dart';

class ItemIcons extends StatelessWidget {
  final Item i;
  final Collections collections;
  final ValueChanged<Item> onItemUpdated;

  const ItemIcons({
    super.key,
    required this.i,
    required this.collections,
    required this.onItemUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
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
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          icon: Icon(Icons.edit),
        ),
        IconButton(
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
            await messenger
                .showSnackBar(
                  SnackBar(
                    content: Text('Deleted "${i.name}"'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        collections.addItem(i);
                      },
                    ),
                  ),
                )
                .closed;
            navigator.pop(true);
          },
          tooltip: 'Delete item',
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          icon: Icon(Icons.delete),
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
    final isLowStock = i.quantity <= lowStockThreshold;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ColoredBox(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: buildInventoryImage(
                    source: i.img ?? '',
                    width: 86,
                    height: 86,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      i.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text('\$${i.price.toStringAsFixed(2)}')),
                        Chip(label: Text('Qty ${i.quantity}')),
                        Chip(label: Text(i.location ?? 'No location')),
                        Chip(label: Text(i.status ?? 'No status')),
                        if (isLowStock)
                          Chip(
                            avatar: Icon(
                              Icons.warning_amber_outlined,
                              size: 15,
                              color: theme.colorScheme.onErrorContainer,
                            ),
                            label: const Text('Low Stock'),
                            backgroundColor: theme.colorScheme.errorContainer
                                .withValues(alpha: 0.72),
                            side: BorderSide.none,
                            labelStyle: TextStyle(
                              color: theme.colorScheme.onErrorContainer,
                              fontWeight: FontWeight.w500,
                            ),
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

  @override
  void initState() {
    super.initState();
    _item = widget.i;
  }

  void _handleItemUpdated(Item updatedItem) {
    setState(() {
      _item = updatedItem;
    });
    widget.onItemsChanged();
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

    return Scaffold(
      appBar: AppBar(title: Text(_item.name)),
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
                    Flex(
                      direction: isWide ? Axis.horizontal : Axis.vertical,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: isWide ? 2 : 0,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Center(
                                child: buildInventoryImage(
                                  source: _item.img ?? '',
                                  width: isWide ? 360 : 280,
                                  height: 220,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: isWide ? 12 : 0,
                          height: isWide ? 0 : 12,
                        ),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: EditableItemHeader(
                              i: _item,
                              collections: widget.collections,
                              onItemUpdated: _handleItemUpdated,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Inventory Details',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Chip(
                                  label: Text(
                                    '\$${_item.price.toStringAsFixed(2)}',
                                  ),
                                ),
                                Chip(
                                  label: Text(_item.location ?? 'No location'),
                                ),
                                Chip(label: Text(_item.status ?? 'No status')),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Text('Quantity'),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => _adjustQuantity(-1),
                                  tooltip: 'Decrease quantity',
                                  constraints: const BoxConstraints(
                                    minWidth: 48,
                                    minHeight: 48,
                                  ),
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                                Text(
                                  '${_item.quantity}',
                                  style: theme.textTheme.titleMedium,
                                ),
                                IconButton(
                                  onPressed: () => _adjustQuantity(1),
                                  tooltip: 'Increase quantity',
                                  constraints: const BoxConstraints(
                                    minWidth: 48,
                                    minHeight: 48,
                                  ),
                                  icon: const Icon(Icons.add_circle_outline),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (sortedTagNames.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tags',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              for (final s in sortedTagNames)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s,
                                        style: theme.textTheme.labelLarge,
                                      ),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          for (final o
                                              in ((_item.tags?[s]?.toList() ??
                                                    <String>[])..sort()))
                                            Chip(label: Text(o)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
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

  const EditableItemHeader({
    super.key,
    required this.i,
    required this.collections,
    required this.onItemUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ItemIcons(
          i: i,
          collections: collections,
          onItemUpdated: onItemUpdated,
        ),
      ],
    );
  }
}
