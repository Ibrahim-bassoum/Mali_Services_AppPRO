// lib/widgets/home/pending_demands_widget.dart
import 'package:flutter/material.dart';

class PendingDemandsWidget extends StatelessWidget {
  final List<Map<String, String>> demandsList;
  final ValueChanged<String> onDemandPressed; // Retourne l'ID de la demande

  const PendingDemandsWidget({
    super.key,
    required this.demandsList,
    required this.onDemandPressed,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryDark = const Color(0xFF00235B);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Demandes à proximité",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryDark),
            ),
            TextButton(
              onPressed: () {},
              child: const Text("Voir plus >", style: TextStyle(color: Color(0xFF2F66F6))),
            )
          ],
        ),
        // Si aucune demande (à coder plus tard)
        // const Text("Aucune demande en attente."), 
        
        // Liste dynamique des demandes
        ListView.builder(
          shrinkWrap: true, // IMPORTANT : nécessaire dans une SingleChildScrollView parent
          physics: const NeverScrollableScrollPhysics(), // IMPORTANT
          itemCount: demandsList.length,
          itemBuilder: (context, index) {
            final demand = demandsList[index];
            return _buildDemandCard(
              id: demand['id']!,
              serviceType: demand['serviceType']!,
              location: demand['location']!,
              timeAgo: demand['timeAgo']!,
              description: demand['description']!,
            );
          },
        ),
      ],
    );
  }

  Widget _buildDemandCard({
    required String id,
    required String serviceType,
    required String location,
    required String timeAgo,
    required String description,
  }) {
    return GestureDetector(
      onTap: () => onDemandPressed(id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(serviceType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(timeAgo, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.green, size: 16),
                const SizedBox(width: 5),
                Text(location, style: const TextStyle(color: Colors.green)),
              ],
            ),
            const SizedBox(height: 10),
            Text(description, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

