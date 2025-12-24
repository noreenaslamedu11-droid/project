              import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'General';

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Add Unplanned Event', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: ['General', 'Academic', 'Sports', 'Cultural', 'Social', 'Workshop']
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            Row(
              children: [
                const Text('Date: '),
                TextButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                  child: Text('${_selectedDate.toLocal()}'.split(' ')[0]),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                await eventProvider.addEvent(
                  _titleController.text,
                  _descriptionController.text,
                  _selectedDate,
                  _locationController.text,
                  _selectedCategory,
                  true, // Unplanned event
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Event added and notifications sent!')),
                );
                _titleController.clear();
                _descriptionController.clear();
                _locationController.clear();
              },
              child: const Text('Add Event & Send Notifications'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await eventProvider.checkAndSendNotifications();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notifications checked and sent!')),
                );
              },
              child: const Text('Check & Send Upcoming Notifications'),
            ),
          ],
        ),
      ),
    );
  }
}
