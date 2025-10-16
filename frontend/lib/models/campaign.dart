class Campaign {
  final String id;
  final String candidateName;
  final String candidatePhoto;
  final String biography;
  final String electionYear;
  final String slogan;
  final List<Priority> priorities;
  final DateTime createdAt;
  final DateTime updatedAt;

  Campaign({
    required this.id,
    required this.candidateName,
    required this.candidatePhoto,
    required this.biography,
    required this.electionYear,
    required this.slogan,
    required this.priorities,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'],
      candidateName: json['candidate_name'],
      candidatePhoto: json['candidate_photo'],
      biography: json['biography'],
      electionYear: json['election_year'],
      slogan: json['slogan'],
      priorities: (json['priorities'] as List)
          .map((priority) => Priority.fromJson(priority))
          .toList(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'candidate_name': candidateName,
      'candidate_photo': candidatePhoto,
      'biography': biography,
      'election_year': electionYear,
      'slogan': slogan,
      'priorities': priorities.map((priority) => priority.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Priority {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int order;
  final DateTime createdAt;

  Priority({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.order,
    required this.createdAt,
  });

  factory Priority.fromJson(Map<String, dynamic> json) {
    return Priority(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['image_url'],
      order: json['order'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'order': order,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
