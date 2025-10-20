import 'package:flutter/material.dart';

class LandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to Finance Tracker',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                child: const Text('Get Started',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
