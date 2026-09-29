// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Hello, Ready to get started?",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text('Login to continue',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),  
          SizedBox(height: 40),

          _TextField(
            controller: _emailController,
            obscureText: false,
            labelText: 'Email',
            prefixIcon: Icons.email),
          const SizedBox(height: 20),

          _TextField(
            controller: _passwordController,
            obscureText: true,
            labelText: 'Password',
            prefixIcon: Icons.lock),
          const SizedBox(height: 40),

          ElevatedButton(
            onPressed: () {
              // Handle login logic here
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 200, vertical: 15),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Login'),
          ),

          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {},
            label: const Text('Login with Google'),
            icon: const Icon(Icons.login),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.login)),
        ],
      ),
    );
  }
}

class _TextField extends StatelessWidget {

  final TextEditingController controller;
  final bool obscureText;
  final String labelText; 
  final IconData prefixIcon;
  
  const _TextField({
    Key? key,
    required this.controller,
    required this.obscureText,
    required this.labelText,
    required this.prefixIcon,
  });


  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration( 
        labelText: labelText,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(prefixIcon),
      ),
      keyboardType: TextInputType.emailAddress,
      onChanged: (value) {},
    );
  }
}
