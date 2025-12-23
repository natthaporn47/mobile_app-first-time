import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(height: 20),
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/vector-1765372356010-60fd9de7d1ae?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHx0b3BpYy1mZWVkfDMzfHBJRjdsNV9oZ3hnfHxlbnwwfHx8fHw%3D',
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Color.fromARGB(255, 142, 202, 251),
                    child: Icon(
                      Icons.edit, 
                      color: Colors.white, 
                      size: 18.0),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "Natthaporn  Wangsuk", 
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 218, 179, 249),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              onPressed:() {},
               child: Text("naththaphrnh@gnail.com"),
               ),
          ],
        ),
      ),
    );

    
  }
}
