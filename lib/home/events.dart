import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          'Events',
          style: TextStyle(
            fontSize: 26,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 181, 17, 6),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('events')
                .orderBy('startTime', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading events.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No events found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final event =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              final String title = event['name'] ?? 'No Title';
              final String description =
                  event['description'] ?? 'No Description';
              final String imageUrl = event['image'] ?? '';
              final Timestamp? startTimestamp = event['startTime'];
              final Timestamp? endTimestamp = event['endTime'];

              final String startTime =
                  startTimestamp != null
                      ? '${DateTime.fromMillisecondsSinceEpoch(startTimestamp.millisecondsSinceEpoch).toLocal().toString().substring(0, 10)} at '
                          '${DateTime.fromMillisecondsSinceEpoch(startTimestamp.millisecondsSinceEpoch).toLocal().toString().substring(11, 16)}'
                      : 'Unknown';

              final String endTime =
                  endTimestamp != null
                      ? '${DateTime.fromMillisecondsSinceEpoch(endTimestamp.millisecondsSinceEpoch).toLocal().toString().substring(0, 10)} at '
                          '${DateTime.fromMillisecondsSinceEpoch(endTimestamp.millisecondsSinceEpoch).toLocal().toString().substring(11, 16)}'
                      : 'Unknown';
              return Center(
                child: SizedBox(
                  width:
                      MediaQuery.of(context).size.width *
                      0.6, // Adjust this value (0.9 = 90% of screen width)
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (imageUrl.isNotEmpty)
                          Container(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.3,
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(15),
                              ),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                                loadingBuilder: (
                                  BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      height: 150,
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 50,
                                        ),
                                      ),
                                    ),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB51106),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Start: $startTime',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      'End: $endTime',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
