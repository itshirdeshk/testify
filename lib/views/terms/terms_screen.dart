import 'package:flutter/material.dart';
import '../../models/terms.dart';
import '../../services/terms_service.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  late Future<List<Terms>> _termsFuture;

  @override
  void initState() {
    super.initState();
    _termsFuture = _fetchTerms();
  }

  Future<List<Terms>> _fetchTerms() async {
    final service = await TermsService.create(context);
    return service.fetchTerms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
      ),
      body: FutureBuilder<List<Terms>>(
        future: _termsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load Terms'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Terms available'));
          }
          final terms = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: terms.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, i) => Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(terms[i].title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(terms[i].content),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
