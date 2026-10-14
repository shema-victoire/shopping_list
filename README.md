# Shopping List+

A feature-rich, interactive Flutter shopping list application built for **Week 2 · Session 3 · Shopping List+**.

## Features Implemented

1. **Empty State:** Displays a centered "Your list is empty" message when the list contains no items (with contextual empty-filter messages when filtering).
2. **Quantities & Plus/Minus Controls:** Default quantity starts at 1, with plus and minus buttons to adjust quantities, ensuring quantity never drops below 1.
3. **Duplicate Prevention:** Case-insensitive and whitespace-trimmed name comparison when adding items. If an item already exists, its quantity is automatically incremented and a SnackBar notification is shown.
4. **Undo Deletion:** Deleting an item removes it and shows a SnackBar with an **UNDO** action that restores the item to its exact original position with its quantity and bought status preserved.
5. **Shopping List Filters:** Filter chips for **All**, **To buy**, and **Bought**. In **All** view, bought items automatically sink to the bottom. All operations (deletion, toggling, editing) remain fully robust across all filters.
6. **Item Details Screen:** Long-press any item to open a dedicated details screen where you can edit the item name, add notes, select categories (Food, Drinks, Home), save changes, or discard edits on back navigation.

## Setup & Running

1. Ensure Flutter SDK is installed.
2. Get dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

---

## Assignment Think Questions & Answers

### 1. Why deleting by displayed index can delete the wrong item when filtering, and how deleting by item identity solves it.
When filtering items (e.g., viewing only "To buy" items), the displayed list is a subset of the master list. If you delete an item using its position (index) in the filtered list, that index might correspond to a completely different item in the master list, resulting in deleting the wrong item or throwing an out-of-bounds error. Deleting by **item identity** (passing the actual `Item` object reference and finding its index in the master list via `items.indexOf(item)`) ensures that we always locate and remove the exact correct item from the master list regardless of the current active filter.

### 2. Why `name` must be mutable for editing while most other fields can remain final.
The `name` represents the primary label of the item. When editing an item in the details screen, the user changes its name text. Because `Item` instances are maintained in a persistent list state, the `name` property needs to be mutable (`String name` instead of `final String name`) so that edits made on the details screen update the existing object reference without needing to replace or re-instantiate the object in the list.

### 3. Why adding a field to the model can require a hot restart, while ordinary value changes generally do not.
Ordinary value changes (like updating `isBought` or `quantity`) modify the *state data* of existing object instances at runtime. However, adding a **new field** or changing the class structure (constructor signature or field definitions) alters the compiled code schema and object layout. Flutter's runtime needs to re-initialize the app's state and widget tree structure (a hot restart) to accommodate the new class structure and default values.

### 4. Why the list needs `setState` after returning from the details screen, and what this demonstrates about Flutter redraws.
When navigating to the item details screen and saving changes, the modification is made directly to the shared `Item` object reference. However, when `Navigator.pop()` returns to the home screen, Flutter does not automatically know that data outside the widget tree changed unless notified. Calling `setState()` in the `async` return handler tells Flutter's framework that the state has updated and forces the `HomeScreen` to rebuild its widget tree, reflecting the updated item name, category, or note on the screen. This demonstrates that Flutter's declarative UI relies on explicit state changes (`setState`) to trigger redraws when asynchronous navigation results return.
