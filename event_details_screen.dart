import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';

class EventDetailsScreen extends StatelessWidget {
  final Event event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);

    // Firebase User ID
    final userId = authProvider.user!.uid;

    // Check if user has already participated
    final hasParticipated = event.participants.contains(userId);

    // Check if user has given feedback
    final userFeedback = event.feedback[userId];

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text('Location: ${event.location}'),
            Text('Date: ${event.date.toLocal()}'.split(' ')[0]),
            const SizedBox(height: 20),
            // Participation Button
            ElevatedButton(
              onPressed: hasParticipated
                  ? null
                  : () {
                      eventProvider.participateInEvent(event.id, userId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('You are now participating!')),
                      );
                    },
              child: Text(hasParticipated ? 'Already Participating' : 'Participate'),
            ),
            const SizedBox(height: 20),
            // Feedback Section
            Text(
              'Feedback:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Column(
              children: [
                FeedbackButton(
                  label: 'Event well organized',
                  selected: userFeedback == 'Event well organized',
                  onTap: userFeedback == null
                      ? () {
                          eventProvider.submitFeedback(event.id, userId, 'Event well organized');
                        }
                      : null,
                ),
                FeedbackButton(
                  label: 'Some mistakes happened',
                  selected: userFeedback == 'Some mistakes happened',
                  onTap: userFeedback == null
                      ? () {
                          eventProvider.submitFeedback(event.id, userId, 'Some mistakes happened');
                        }
                      : null,
                ),
                FeedbackButton(
                  label: 'We are satisfied',
                  selected: userFeedback == 'We are satisfied',
                  onTap: userFeedback == null
                      ? () {
                          eventProvider.submitFeedback(event.id, userId, 'We are satisfied');
                        }
                      : null,
                ),
                FeedbackButton(
                  label: 'We are not satisfied',
                  selected: userFeedback == 'We are not satisfied',
                  onTap: userFeedback == null
                      ? () {
                          eventProvider.submitFeedback(event.id, userId, 'We are not satisfied');
                        }
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Feedback Button Widget
class FeedbackButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const FeedbackButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: selected ? Colors.green : null,
        ),
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}
