import 'package:flutter/material.dart';
import 'bulletin_screen.dart';
import 'announcements_screen.dart';
import 'events_calendar_screen.dart';
import 'contacts_screen.dart';
import 'duty_roster_screen.dart'; // Import DutyRosterScreen
import '../widgets/app_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    BulletinScreen(),
    AnnouncementsScreen(),
    EventsCalendarScreen(),
    ContactsScreen(),
    DutyRosterScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          automaticallyImplyLeading: false, // Hide back button if needed
          flexibleSpace: const SafeArea(child: AppHeader()),
          elevation: 0,
          backgroundColor: const Color(0xFF18345E),
          foregroundColor: Colors.white, // For icons/text if added to header
        ),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Needed for 4+ items
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Program'),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: 'Announce',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_ind),
            label: 'Roster',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF18345E), // Theme color
        onTap: _onItemTapped,
      ),
    );
  }
}
