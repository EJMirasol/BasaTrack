import 'package:flutter/material.dart';

/// Reminder card shown when user has missed days
class ReminderCard extends StatelessWidget {
  final int daysLate;

  const ReminderCard({
    required this.daysLate, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.shade300,
            Colors.red.shade200,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade200.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Warning Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Reminder Title
          const Text(
            'Reminder',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Late Message
          Text(
            'You are already ($daysLate) ${daysLate == 1 ? 'day' : 'days'} late. Please catch up.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Tagalog Message
          Text(
            'Naulahi naka ug ($daysLate) ka adlaw. Pag-apas palihug.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
