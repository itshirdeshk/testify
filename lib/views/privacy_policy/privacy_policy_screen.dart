import 'package:flutter/material.dart';
import '../../models/privacy_policy.dart';
import '../../services/privacy_policy_service.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late Future<List<PrivacyPolicy>> _privacyFuture;

  @override
  void initState() {
    super.initState();
    _privacyFuture = _fetchPrivacyPolicies();
  }

  Future<List<PrivacyPolicy>> _fetchPrivacyPolicies() async {
    final service = await PrivacyPolicyService.create(context);
    return service.fetchPrivacyPolicies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: FutureBuilder<List<PrivacyPolicy>>(
        future: _privacyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load Privacy Policy'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Privacy Policy available'));
          }
          final policies = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: policies.length,
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
                    Text(policies[i].title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(policies[i].content),
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
