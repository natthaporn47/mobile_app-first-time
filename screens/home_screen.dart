import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const[
          Icon( 
            Icons.search, 
            color: Colors.blue,
            size: 24.0,
            ),
            SizedBox(width:16),
            Icon(Icons.exit_to_app, 
            color: Colors.blue, 
            size: 24.0,
            ),
            SizedBox(width:16),
        ],
        title:const Center(child: Text('Demo Mobile App')),
        leading: Icon(
          Icons.menu, 
          color: Colors.blue,
          size: 24.0,
          ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              "First Line", 
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.blue
              ),),
            const SizedBox(height: 16),
            const Icon(
              Icons.settings, 
              color: Colors.blue, 
              size: 48.0),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 200,
                  height: 200,
                  color: Colors.red,
                  child: const Text("Hello"),
                ),
                Container(
                  width: 200,
                  height: 200,
                  color: Colors.blue,
                  child: const Text("Hello"),
                ),
                Container(
                  width: 200,
                  height: 200,
                  color: Colors.green,
                  child: const Text("Hello"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const CircleAvatar(
              radius: 52,
              backgroundColor: Color.fromARGB(255, 174, 226, 247),
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                'https://png.pngtree.com/thumb_back/fh260/background/20230805/pngtree-hillcovered-farmland-in-mountainous-landscape-with-clouds-image_13009507.jpg'
              ),
            ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.green[50],
        items: const [
          BottomNavigationBarItem(icon:  Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon:  Icon(Icons.school), label: 'Shool'),
          BottomNavigationBarItem(icon:  Icon(Icons.settings), label: 'Settings'),
          BottomNavigationBarItem(icon:  Icon(Icons.person), label: 'Profile'),          
      ],),
    );
  }
}
