import 'package:flutter/material.dart';
import '../../models/faq.dart';
import '../../services/faq_service.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  late Future<List<FAQ>> _faqFuture;

  @override
  void initState() {
    super.initState();
    _faqFuture = _fetchFAQs();
  }

  Future<List<FAQ>> _fetchFAQs() async {
    final service = await FAQService.create(context);
    return service.fetchFAQs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQs'),
      ),
      body: FutureBuilder<List<FAQ>>(
        future: _faqFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load FAQs'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No FAQs available'));
          }
          final faqs = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: faqs
                .map((faq) => ExpansionTile(
                      title: Text(faq.question,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(faq.answer),
                        ),
                      ],
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}
