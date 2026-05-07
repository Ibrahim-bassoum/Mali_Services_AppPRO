class Category {
  final int id;
  final String name;
  final String icon;

  Category({
    required this.id,
    required this.name,
    required this.icon,
  });

  // Cette méthode permet de transformer le JSON reçu de ton API Laravel en objet Flutter
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      icon: json['icon'] ?? '', // Évite les erreurs si l'icône est nulle
    );
  }
}