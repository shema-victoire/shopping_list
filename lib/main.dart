import 'package:flutter/material.dart';

void main() {
  runApp(const ShoppingApp());
}

// STEP 1: The app
class ShoppingApp extends StatelessWidget {
  const ShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      home: const HomeScreen(title: 'Shopping List+'),
    );
  }
}

// STEP 2: The model for each shopping item
class Item {
  Item({
    required this.name,
    this.quantity = 1,
    this.isBought = false,
    this.note = '',
    this.category = 'Food',
  });

  String name;
  int quantity;
  bool isBought;
  String note;
  String category;
}

// STEP 3: The home screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// STEP 4: The screen's data and logic
class _HomeScreenState extends State<HomeScreen> {
  final List<Item> items = [
    Item(name: 'Milk', category: 'Food'),
    Item(name: 'Bread', category: 'Food'),
    Item(name: 'Rice', category: 'Food'),
  ];

  final TextEditingController controller = TextEditingController();
  String currentFilter = 'All';

  int get itemsLeft => items.where((item) => !item.isBought).length;

  List<Item> get filteredItems {
    if (currentFilter == 'All') {
      final unbought = items.where((i) => !i.isBought).toList();
      final bought = items.where((i) => i.isBought).toList();
      return [...unbought, ...bought];
    } else if (currentFilter == 'To buy') {
      return items.where((i) => !i.isBought).toList();
    } else if (currentFilter == 'Bought') {
      return items.where((i) => i.isBought).toList();
    }
    return items;
  }

  // STEP 5: Add an item with duplicate prevention
  void addItem() {
    final rawName = controller.text.trim();

    if (rawName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Type an item first'),
        ),
      );
      return;
    }

    final normalizedNew = rawName.toLowerCase();

    // Check duplicate ignoring case and surrounding whitespace
    final existingIndex = items.indexWhere(
      (item) => item.name.trim().toLowerCase() == normalizedNew,
    );

    setState(() {
      if (existingIndex != -1) {
        items[existingIndex].quantity += 1;
        final existingName = items[existingIndex].name;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Increased quantity of $existingName'),
          ),
        );
      } else {
        items.add(Item(name: rawName));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$rawName added'),
          ),
        );
      }
    });

    controller.clear();
  }

  // STEP 6: Delete an item with Undo support using item identity & original index
  void deleteItem(Item item) {
    final int originalIndex = items.indexOf(item);
    if (originalIndex == -1) return;

    setState(() {
      items.removeAt(originalIndex);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} removed'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            setState(() {
              int insertIndex = originalIndex.clamp(0, items.length);
              items.insert(insertIndex, item);
            });
          },
        ),
      ),
    );
  }

  // STEP 7: Mark an item as bought or undo it
  void toggleBought(Item item) {
    setState(() {
      item.isBought = !item.isBought;
    });
  }

  // STEP 8: Clear all bought items
  void clearBoughtItems() {
    final boughtCount = items.where((item) => item.isBought).length;

    if (boughtCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No bought items to clear'),
        ),
      );
      return;
    }

    setState(() {
      items.removeWhere((item) => item.isBought);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bought items cleared'),
      ),
    );
  }

  // Open item details screen
  Future<void> _openDetails(Item item) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailsScreen(item: item),
      ),
    );
    if (updated == true) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // STEP 9: Build the screen with filters and empty states
  @override
  Widget build(BuildContext context) {
    final displayList = filteredItems;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.title} ($itemsLeft left)',
        ),
        actions: [
          IconButton(
            tooltip: 'Clear bought items',
            onPressed: clearBoughtItems,
            icon: const Icon(Icons.cleaning_services),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    onSubmitted: (_) => addItem(),
                    decoration: const InputDecoration(
                      hintText: 'Add an item',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: addItem,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          // Filter Chips Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: Row(
              children: [
                const Text('Filter:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('All'),
                  selected: currentFilter == 'All',
                  onSelected: (selected) {
                    if (selected) setState(() => currentFilter = 'All');
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('To buy'),
                  selected: currentFilter == 'To buy',
                  onSelected: (selected) {
                    if (selected) setState(() => currentFilter = 'To buy');
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Bought'),
                  selected: currentFilter == 'Bought',
                  onSelected: (selected) {
                    if (selected) setState(() => currentFilter = 'Bought');
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text('Your list is empty'),
                  )
                : displayList.isEmpty
                    ? Center(
                        child: Text(
                          currentFilter == 'To buy'
                              ? 'No items to buy'
                              : currentFilter == 'Bought'
                                  ? 'No bought items'
                                  : 'No items found',
                        ),
                      )
                    : ListView.builder(
                        itemCount: displayList.length,
                        itemBuilder: (context, index) {
                          final item = displayList[index];

                          return ListTile(
                            onTap: () => toggleBought(item),
                            onLongPress: () => _openDetails(item),
                            leading: Icon(
                              item.isBought
                                  ? Icons.check_circle
                                  : Icons.shopping_basket,
                              color: item.isBought ? Colors.green : null,
                            ),
                            title: Text(
                              item.name,
                              style: TextStyle(
                                decoration: item.isBought
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: item.isBought ? Colors.grey : null,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Category: ${item.category}'),
                                if (item.note.isNotEmpty)
                                  Text('Note: ${item.note}'),
                              ],
                            ),
                            isThreeLine: item.note.isNotEmpty,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                                  onPressed: item.quantity > 1
                                      ? () {
                                          setState(() {
                                            item.quantity--;
                                          });
                                        }
                                      : null,
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      item.quantity++;
                                    });
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Delete item',
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => deleteItem(item),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// STEP 10: Item Details Screen
class ItemDetailsScreen extends StatefulWidget {
  const ItemDetailsScreen({super.key, required this.item});

  final Item item;

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _noteController;
  late String _selectedCategory;

  final List<String> categories = ['Food', 'Drinks', 'Home'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _noteController = TextEditingController(text: widget.item.note);
    _selectedCategory = categories.contains(widget.item.category)
        ? widget.item.category
        : 'Food';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item name cannot be empty'),
        ),
      );
      return;
    }

    widget.item.name = newName;
    widget.item.note = _noteController.text.trim();
    widget.item.category = _selectedCategory;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Item Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save',
            onPressed: _save,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: categories.map((cat) {
                return ChoiceChip(
                  label: Text(cat),
                  selected: _selectedCategory == cat,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
