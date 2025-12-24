import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../models/event.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userRole;
  String _selectedCategory = 'All';

  // Form fields for My Event dialog
  final _formKey = GlobalKey<FormState>();
  final _organizedByController = TextEditingController();
  final _venueController = TextEditingController();
  final _timeController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedEventCategory = 'General';
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final role = await authProvider.getRole();
    setState(() => userRole = role);
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8360C3),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      eventProvider.addEvent(
        'My Event', // title
        'Event created by user', // description
        _selectedDate!,
        _venueController.text,
        _selectedEventCategory,
        _organizedByController.text,
        _selectedImage?.path,
        false, // isUnplanned
        '', // city
        null, // timeZone
      );
      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event added successfully!')),
      );
      // Reset form
      _formKey.currentState!.reset();
      _organizedByController.clear();
      _venueController.clear();
      _timeController.clear();
      setState(() {
        _selectedDate = null;
        _selectedEventCategory = 'General';
        _selectedImage = null;
      });
    }
  }

  void _showMyEventDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Welcome'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Date
                  const Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    readOnly: true,
                    onTap: _selectDate,
                    decoration: InputDecoration(
                      hintText: _selectedDate == null
                          ? 'Select date'
                          : '${_selectedDate!.toLocal().toString().split(' ')[0]}',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    validator: (value) {
                      if (_selectedDate == null) {
                        return 'Please select a date';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Category
                  const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedEventCategory,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: ['General', 'Academic', 'Sports', 'Cultural', 'Social', 'Workshop']
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedEventCategory = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Organized By
                  const Text('Organized By', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _organizedByController,
                    decoration: InputDecoration(
                      hintText: 'Enter organizer name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter organizer name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Venue
                  const Text('Venue', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _venueController,
                    decoration: InputDecoration(
                      hintText: 'Enter venue',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter venue';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Time
                  const Text('Time', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _timeController,
                    decoration: InputDecoration(
                      hintText: 'Enter time (e.g., 10:00 AM)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter time';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Picture
                  const Text('Event Picture', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Pick from Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2EBF91),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  if (_selectedImage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _selectedImage!,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _submitForm(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8360C3),
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // ===== GRADIENT BACKGROUND =====
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8360C3), Color(0xFF2EBF91)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ===== MAIN CONTENT =====
          Column(
            children: [
              // ===== APP BAR =====
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'University Event Notifier',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                actions: [
                  if (userRole == 'Admin')
                    IconButton(
                      icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
                      onPressed: () => Navigator.pushNamed(context, '/admin'),
                    ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () async {
                      await authProvider.signOut();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ],
              ),

              // ===== BODY CONTENT =====
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      // ===== WELCOME SECTION =====
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            // Decorative top line
                            Container(
                              height: 3,
                              width: 50,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF8360C3), Color(0xFF2EBF91)],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Welcome Text
                            const Text(
                              'Welcome to',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // UNIVERSITY LOGO
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                gradient: LinearGradient(
                                  colors: [Colors.white, Colors.grey.shade50],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  'assets/university_logo.png',
                                  height: 70,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Decorative bottom line
                            Container(
                              height: 3,
                              width: 50,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF2EBF91), Color(0xFF8360C3)],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ===== SEARCH BAR =====
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          onChanged: (value) => eventProvider.searchEvents(value),
                          decoration: InputDecoration(
                            hintText: 'Search events...',
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF8360C3)),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          ),
                        ),
                      ),

                      // ===== FILTER BUTTONS =====
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      DateTimeRange? picked = await showDateRangePicker(
                                        context: context,
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now().add(const Duration(days: 365)),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: const ColorScheme.light(
                                                primary: Color(0xFF8360C3),
                                                onPrimary: Colors.white,
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (picked != null) {
                                        eventProvider.filterEventsByDateRange(picked.start, picked.end);
                                      }
                                    },
                                    icon: const Icon(Icons.date_range),
                                    label: const Text('Date Filter'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2EBF91),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () => eventProvider.filterParticipatedEvents(authProvider.user!.uid),
                                  icon: const Icon(Icons.check_circle),
                                  label: const Text('My Events'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8360C3),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: _showMyEventDialog,
                                  icon: const Icon(Icons.event),
                                  label: const Text('My Event'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2EBF91),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => eventProvider.clearFilters(),
                                  icon: const Icon(Icons.clear, color: Colors.white),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text('Category: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                DropdownButton<String>(
                                  value: _selectedCategory,
                                  items: ['All', 'General', 'Academic', 'Sports', 'Cultural', 'Social', 'Workshop']
                                      .map((category) => DropdownMenuItem(
                                            value: category,
                                            child: Text(category),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCategory = value!;
                                    });
                                    if (value == 'All') {
                                      eventProvider.clearFilters();
                                    } else {
                                      eventProvider.filterEventsByCategory(value!);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ===== IMAGE SLIDER =====
                      CarouselSlider(
                        options: CarouselOptions(
                          height: 200,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 3), // Reduced frequency
                          enlargeCenterPage: true,
                          viewportFraction: 0.9,
                        ),
                        items: List.generate(5, (index) => index + 1).map((i) { // Reduced to 5 images
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              width: double.infinity,
                              height: 200,
                              child: Image.asset(
                                'assets/images/$i.jpg',
                                fit: BoxFit.cover,
                                cacheWidth: 400, // Optimize image loading
                                cacheHeight: 200,
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 14),

                      // ===== TITLE =====
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Upcoming Events',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // ===== EVENT LIST =====
                      Expanded(
                        child: eventProvider.events.isEmpty
                            ? const Center(
                                child: Text(
                                  'No events available',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                itemCount: eventProvider.events.length,
                                itemBuilder: (context, index) {
                                  final Event event = eventProvider.events[index];
                                  final bool participated = event.participants
                                      .contains(authProvider.user?.uid);

                                  return Card(
                                    elevation: 6,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    shadowColor: Colors.black.withOpacity(0.2),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: LinearGradient(
                                          colors: [Colors.white, Colors.grey.shade50],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          children: [
                                            // EVENT IMAGE
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: event.imagePath != null
                                                  ? Image.file(
                                                      File(event.imagePath!),
                                                      width: 70,
                                                      height: 70,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Image.asset(
                                                      'assets/images/${(index % 10) + 1}.jpg',
                                                      width: 70,
                                                      height: 70,
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),

                                            const SizedBox(width: 12),

                                            // EVENT INFO
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    event.title,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Venue: ${event.location}',
                                                    style:
                                                        const TextStyle(color: Colors.grey),
                                                  ),
                                                  Text(
                                                    'Date: ${event.date.toLocal().toString().split(' ')[0]}',
                                                    style:
                                                        const TextStyle(color: Colors.grey),
                                                  ),
                                                  Text(
                                                    'Category: ${event.category}',
                                                    style: TextStyle(
                                                      color: _getCategoryColor(event.category),
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),

                                                  // PARTICIPATION STATUS
                                                  Row(
                                                    children: [
                                                      Container(
                                                        height: 6,
                                                        width: 40,
                                                        decoration: BoxDecoration(
                                                          color: participated
                                                              ? Colors.green
                                                              : Colors.red,
                                                          borderRadius:
                                                              BorderRadius.circular(5),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        participated
                                                            ? 'Participated'
                                                            : 'Not Participated',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: participated
                                                              ? Colors.green
                                                              : Colors.red,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // PARTICIPATE BUTTON
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: participated ? Colors.grey : const Color(0xFF8360C3),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                              onPressed: participated
                                                  ? null
                                                  : () {
                                                      eventProvider.participateInEvent(event.id, authProvider.user!.uid);
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(content: Text('Participated successfully!')),
                                                      );
                                                    },
                                              child: Text(participated ? 'Participated' : 'Participate'),
                                            ),
                                            const SizedBox(width: 8),
                                            // FEEDBACK BUTTON
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF2EBF91),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  '/event_details',
                                                  arguments: event,
                                                );
                                              },
                                              child: const Text('Feedback'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ===== ADMIN ADD BUTTON =====
          Positioned(
            bottom: 20,
            right: 20,
            child: userRole == 'Admin'
                ? FloatingActionButton(
                    backgroundColor: const Color(0xFF8360C3),
                    onPressed: () => Navigator.pushNamed(context, '/admin'),
                    child: const Icon(Icons.add),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'academic':
        return Colors.blue;
      case 'sports':
        return Colors.green;
      case 'cultural':
        return Colors.purple;
      case 'social':
        return Colors.orange;
      case 'workshop':
        return Colors.red;
      case 'general':
      default:
        return Colors.grey;
    }
  }
}
