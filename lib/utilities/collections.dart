class Collections {
  Set<Item> items;
  Set<Tag> tags;
  Set<String> locations;
  Set<String> status;

  Collections(this.items,this.tags, this.locations, this.status);
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
}