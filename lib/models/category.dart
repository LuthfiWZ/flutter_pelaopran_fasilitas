class Category {
  final int id;
  final String name;
  final String? description;
  final int reportsCount;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.reportsCount = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      reportsCount: (json['reports_count'] as num?)?.toInt() ?? 0,
    );
  }
}
