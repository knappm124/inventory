import '../utilities/collections.dart';

Set<String> locations = {"Etsy", "Home", "General Store"};

Set<String> status = {"WIP", "Sold", "Listed", "Returned"};

Tag t1 = Tag("1", "Color", {"red", "orange", "yellow", "green", "blue", "purple"});
Tag t2 = Tag("2", "Size", {"quail", "chicken", "duck", "goose", "ostrich"});
Tag t3 = Tag("3", "Season", {"Easter", "Christmas", "Fall", "Spring"});
Tag t4 = Tag("4", "Symbols", {"star", "deer", "chicken", "flower", "cross", "fish"});
Tag t5 = Tag("5", "Division", {"star", "band", "triangles", "diagonal"});

Set<Tag> tags = {t1, t2, t3, t4, t5};

Item i1 = Item("1", "Bird Egg", 20, "Etsy", "WIP", {"Color": {"red", "blue"}, "Size": {"chicken"}});
Item i2 = Item("2", "Star Egg", 20, "Etsy", "Listed", {"Color": {"yellow", "red"}, "Symbols": {"star"}});
Item i3 = Item("3", "Deer Egg", 20, "Etsy", "Sold", {"Season": {"fall"}, "Size": {"quail"}});
Item i4 = Item("4", "Cross Egg", 20, "Etsy", "Returned", {"Color": {"green", "blue"}, "Season": {"easter"}, "Symbols": {"cross"}});

Set<Item> items = {i1, i2, i3, i4};

Collections collections = Collections(items, tags, locations, status);