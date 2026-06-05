class Collections {
  Set<Item> items;
  Set<Tag> tags;
  Set<String> locations;
  Set<String> status;

  Collections(this.items,this.tags, this.locations, this.status);

  Collections addItem(Item i) {
    items.add(i);
    return this;
  }

  Collections addTag(Tag t) {
    tags.add(t);
    return this;
  }

  Collections addLocation(String l) {
    locations.add(l);
    return this;
  }

  Collections addStatus(String s) {
    status.add(s);
    return this;
  }

  Collections removeItem(Item i) {
    items.remove(i);
    return this;
  }

  Collections removeTag(Tag t) {
    tags.remove(t);
    return this;
  }

  Collections removeLocation(String l) {
    locations.remove(l);
    return this;
  }

  Collections removeStatus(String s) {
    status.remove(s);
    return this;
  }

  Collections editTag(Tag t) {
    tags.removeWhere((Tag tag) => tag.id == t.id);
    tags.add(t);
    return this;
  }

  Collections editItem(Item i) {
    items.removeWhere((Item item) => item.id == i.id);
    items.add(i);
    return this;
  }
}

class Item {
  String id;
  String name;
  double price;
  String location;
  String status;
  Map<String, Set<String>> tags;

  Item(this.id, this.name, this.price, this.location, this.status, this.tags);
}

class Tag {
  String id;
  String name;
  Set<String> options;

  Tag(this.id, this.name, this.options);

  @override
  String toString() {
    return "$name: $options";
  }

  Tag addOption(String o) {
    if (!options.contains(o)) {
      options.add(o);
    }
    return this;
  }

  Tag removeOption(String o) {
    options.remove(o);
    return this;
  }
}