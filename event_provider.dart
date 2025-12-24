import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/event.dart';

class EventProvider extends ChangeNotifier {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  List<Event> _events = [];
  bool _isLoading = false;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;

  EventProvider() {
    _loadEventsFromLocal();
    _fetchEventsFromFirebase();
  }

  // Load events from local storage first
  Future<void> _loadEventsFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? eventsJson = prefs.getString('events');
      if (eventsJson != null) {
        List<dynamic> eventsList = jsonDecode(eventsJson);
        _events = eventsList.map((e) => Event.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading events from local: $e");
    }
  }

  // Fetch events from Firebase and update local storage
  Future<void> _fetchEventsFromFirebase() async {
    try {
      _isLoading = true;
      notifyListeners();

      DatabaseEvent snapshot = await _database.ref('events').once();
      Map<dynamic, dynamic>? data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        List<Event> firebaseEvents = [];
        data.forEach((key, value) {
          firebaseEvents.add(Event.fromMap(key, Map<String, dynamic>.from(value)));
        });

        _events = firebaseEvents;
        await _saveEventsToLocal(_events);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching events from Firebase: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save events to local storage
  Future<void> _saveEventsToLocal(List<Event> events) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String eventsJson = jsonEncode(events.map((e) => e.toJson()).toList());
      await prefs.setString('events', eventsJson);
    } catch (e) {
      debugPrint("Error saving events to local: $e");
    }
  }

  // Add event to both local and Firebase
  Future<void> addEvent(
      String title, String description, DateTime date, String location, String category, String organizer, String? imagePath, bool isUnplanned, String? city, String? timeZone) async {
    try {
      // Create event object
      String eventId = _database.ref('events').push().key!;
      Event newEvent = Event(
        id: eventId,
        title: title,
        description: description,
        date: date,
        location: location,
        category: category,
        organizer: organizer,
        imagePath: imagePath,
        participants: [],
        feedback: {},
        isUnplanned: isUnplanned,
        city: city,
        timeZone: timeZone,
      );

      // Add to local storage immediately
      _events.add(newEvent);
      await _saveEventsToLocal(_events);
      notifyListeners();

      // Save to Firebase
      await _database.ref('events/$eventId').set(newEvent.toMap());

    } catch (e) {
      debugPrint("Error adding event: $e");
      // Remove from local if Firebase save failed
      _events.removeWhere((event) => event.id == newEvent.id);
      await _saveEventsToLocal(_events);
      notifyListeners();
      rethrow;
    }
  }

  // Update event participation
  Future<void> toggleParticipation(String eventId, String userId) async {
    try {
      Event event = _events.firstWhere((e) => e.id == eventId);
      List<String> participants = List.from(event.participants);

      if (participants.contains(userId)) {
        participants.remove(userId);
      } else {
        participants.add(userId);
      }

      // Update local
      event.participants.clear();
      event.participants.addAll(participants);
      await _saveEventsToLocal(_events);
      notifyListeners();

      // Update Firebase
      await _database.ref('events/$eventId/participants').set(participants);

    } catch (e) {
      debugPrint("Error toggling participation: $e");
      rethrow;
    }
  }

  // Add feedback
  Future<void> addFeedback(String eventId, String userId, String feedback) async {
    try {
      Event event = _events.firstWhere((e) => e.id == eventId);
      Map<String, String> eventFeedback = Map.from(event.feedback);
      eventFeedback[userId] = feedback;

      // Update local
      event.feedback.clear();
      event.feedback.addAll(eventFeedback);
      await _saveEventsToLocal(_events);
      notifyListeners();

      // Update Firebase
      await _database.ref('events/$eventId/feedback').set(eventFeedback);

    } catch (e) {
      debugPrint("Error adding feedback: $e");
      rethrow;
    }
  }

  // Refresh events from Firebase
  Future<void> refreshEvents() async {
    await _fetchEventsFromFirebase();
  }

  // Get events by category
  List<Event> getEventsByCategory(String category) {
    if (category == 'All') return _events;
    return _events.where((event) => event.category == category).toList();
  }

  // Get upcoming events
  List<Event> getUpcomingEvents() {
    DateTime now = DateTime.now();
    return _events.where((event) => event.date.isAfter(now)).toList();
  }

  // Search events
  void searchEvents(String query) {
    if (query.isEmpty) {
      refreshEvents();
    } else {
      _events = _events.where((event) =>
        event.title.toLowerCase().contains(query.toLowerCase()) ||
        event.description.toLowerCase().contains(query.toLowerCase()) ||
        event.location.toLowerCase().contains(query.toLowerCase())
      ).toList();
      notifyListeners();
    }
  }

  // Filter events by date range
  void filterEventsByDateRange(DateTime start, DateTime end) {
    _events = _events.where((event) =>
      event.date.isAfter(start.subtract(const Duration(days: 1))) &&
      event.date.isBefore(end.add(const Duration(days: 1)))
    ).toList();
    notifyListeners();
  }

  // Filter participated events
  void filterParticipatedEvents(String userId) {
    _events = _events.where((event) => event.participants.contains(userId)).toList();
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    refreshEvents();
  }

  // Filter events by category
  void filterEventsByCategory(String category) {
    if (category == 'All') {
      refreshEvents();
    } else {
      _events = _events.where((event) => event.category == category).toList();
      notifyListeners();
    }
  }

  // Participate in event (alias for toggleParticipation)
  Future<void> participateInEvent(String eventId, String userId) async {
    await toggleParticipation(eventId, userId);
  }

  // Submit feedback (alias for addFeedback)
  Future<void> submitFeedback(String eventId, String userId, String feedback) async {
    await addFeedback(eventId, userId, feedback);
  }

  // Check and send notifications (placeholder)
  Future<void> checkAndSendNotifications() async {
    // Placeholder for notification logic
    debugPrint("Checking and sending notifications...");
  }
}
