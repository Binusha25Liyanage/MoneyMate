import 'package:flutter/material.dart';

class SavingsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> savingsGoals = [
    {'goal': 'New Laptop', 'target': 1500, 'saved': 700},
    {'goal': 'Vacation', 'target': 1000, 'saved': 450},
    {'goal': 'Emergency Fund', 'target': 2000, 'saved': 1200},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💰 Savings Goals')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: savingsGoals.length,
          itemBuilder: (context, index) {
            final goal = savingsGoals[index];
            double progress = goal['saved'] / goal['target'];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(2, 2),
                    blurRadius: 6,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal['goal'],
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    color: Colors.greenAccent,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Saved \$${goal['saved']} of \$${goal['target']}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new savings goal
        },
        backgroundColor: Colors.deepPurpleAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
