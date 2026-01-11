import 'package:flutter/material.dart';

import '../constant/my_constant.dart';
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
            const SizedBox(height: 20),
            const Stack(
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
            const SizedBox(height: 20),
            Text(
              "Natthaporn  Wangsuk", 
              style: headingTextStyle,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: lightBackgroundColor,
                ),
              onPressed:() {},
              child: Text("naththaphrnh@gmail.com", style: bodyTextStyle,),
               ),
              
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 25.0), //ซ้าย บน ขวา ล่าง หรือ all(8.0)
                child: Container(
                  width: double.infinity,
                  height: 40,
                  color: darkBackgroundColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 10,),
                      Icon(Icons.edit, color: primaryColor, size: 24.0,),
                      const SizedBox(width: 20,),
                      Text("Edit Profile", style: bodyTextStyle,),
                      const Spacer(),
                      Icon(Icons.arrow_forward_ios, color: primaryColor, size: 24.0,),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    
  }

  
}
