import 'package:timezone/timezone.dart' as tz;

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String category;
  final String organizer;
  final String? imagePath;
  final List<String> participants;
  final Map<String, String> feedback;
  final bool isUnplanned;
  final String? city;
  final String? timeZone;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.category,
    required this.organizer,
    this.imagePath,
    required this.participants,
    required this.feedback,
    required this.isUnplanned,
    this.city,
    this.timeZone,
  });

  // Factory method for Realtime Database
  factory Event.fromMap(String id, Map<String, dynamic> data) {
    return Event(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: DateTime.parse(data['date']),
      location: data['location'] ?? '',
      category: data['category'] ?? 'General',
      organizer: data['organizer'] ?? '',
      imagePath: data['imagePath'],
      participants: List<String>.from(data['participants'] ?? []),
      feedback: Map<String, String>.from(data['feedback'] ?? {}),
      isUnplanned: data['isUnplanned'] ?? false,
      city: data['city'],
      timeZone: data['timeZone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'category': category,
      'organizer': organizer,
      'imagePath': imagePath,
      'participants': participants,
      'feedback': feedback,
      'isUnplanned': isUnplanned,
      'city': city,
      'timeZone': timeZone,
    };
  }

  // Convert Event to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'category': category,
      'organizer': organizer,
      'imagePath': imagePath,
      'participants': participants,
      'feedback': feedback,
      'isUnplanned': isUnplanned,
      'city': city,
      'timeZone': timeZone,
    };
  }

  // Create Event from JSON for local storage
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      location: json['location'],
      category: json['category'] ?? 'General',
      organizer: json['organizer'] ?? '',
      imagePath: json['imagePath'],
      participants: List<String>.from(json['participants']),
      feedback: Map<String, String>.from(json['feedback']),
      isUnplanned: json['isUnplanned'],
    );
  }
}
