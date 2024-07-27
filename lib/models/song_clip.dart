class SongClip {
  final String id;
  final String title;
  final String audioUrl;
  final String createdAt;
  final String modelName;
  final String status;

  SongClip({
    required this.id,
    required this.title,
    required this.audioUrl,
    required this.createdAt,
    required this.modelName,
    required this.status,
  });

  factory SongClip.fromJson(Map<String, dynamic> json) {
    return SongClip(
      id: json['id'],
      title: json['title'],
      audioUrl: json['audio_url'],
      createdAt: json['created_at'],
      modelName: json['model_name'],
      status: json['status'],
    );
  }
}
