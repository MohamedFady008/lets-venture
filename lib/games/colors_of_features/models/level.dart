class Level {
  final int id;
  final String name;
  final bool isUnlocked;
  final String imageAsset;
  final String description;

  Level({
    required this.id,
    required this.name,
    this.isUnlocked = true,
    this.imageAsset = '',
    this.description = '',
  });
}

final List<Level> levelList = [
  Level(id: 0, name: 'Giza Pyramid', description: 'Ancient wonder of Egypt.'),
  Level(id: 1, name: 'Sphinx', description: 'Mythical creature statue.'),
];
