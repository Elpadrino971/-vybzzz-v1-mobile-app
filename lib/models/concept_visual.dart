class ConceptVisual {
  final String title;
  final String description;
  final String? imageUrl;
  final String? localImagePath;
  final String category;
  final List<String> tags;
  final bool isFeatured;
  final DateTime? createdAt;
  final String? author;
  final String? version;

  ConceptVisual({
    required this.title,
    required this.description,
    this.imageUrl,
    this.localImagePath,
    required this.category,
    required this.tags,
    this.isFeatured = false,
    this.createdAt,
    this.author,
    this.version,
  });

  // Factory constructor pour créer depuis JSON
  factory ConceptVisual.fromJson(Map<String, dynamic> json) {
    return ConceptVisual(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      localImagePath: json['localImagePath'],
      category: json['category'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      isFeatured: json['isFeatured'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      author: json['author'],
      version: json['version'],
    );
  }

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'localImagePath': localImagePath,
      'category': category,
      'tags': tags,
      'isFeatured': isFeatured,
      'createdAt': createdAt?.toIso8601String(),
      'author': author,
      'version': version,
    };
  }

  // Copier avec modifications
  ConceptVisual copyWith({
    String? title,
    String? description,
    String? imageUrl,
    String? localImagePath,
    String? category,
    List<String>? tags,
    bool? isFeatured,
    DateTime? createdAt,
    String? author,
    String? version,
  }) {
    return ConceptVisual(
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      author: author ?? this.author,
      version: version ?? this.version,
    );
  }

  @override
  String toString() {
    return 'ConceptVisual(title: $title, category: $category, isFeatured: $isFeatured)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConceptVisual &&
        other.title == title &&
        other.category == category &&
        other.isFeatured == isFeatured;
  }

  @override
  int get hashCode {
    return title.hashCode ^ category.hashCode ^ isFeatured.hashCode;
  }
}
