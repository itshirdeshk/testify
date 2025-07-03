import 'package:flutter/material.dart';

class CustomTestCard extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final String? subtitle;
  final List<Widget>? details;
  final VoidCallback? onTap;
  final Widget? trailing;
  final double progress;

  const CustomTestCard({
    super.key,
    required this.title,
    this.imageUrl,
    this.subtitle,
    this.details,
    this.onTap,
    this.trailing,
    this.progress = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageUrl!.startsWith('http') ||
                          imageUrl!.startsWith('https')
                      ? Image.network(
                          imageUrl!,
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 80,
                              width: 80,
                              color: Colors.grey[200],
                              child: Icon(Icons.error_outline,
                                  color: Colors.grey[400]),
                            );
                          },
                        )
                      : Image.asset(
                          imageUrl!,
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                        ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color!
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                    if (progress > 0) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor:
                            Theme.of(context).textTheme.bodyMedium?.color,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                    if (details != null) ...[
                      const SizedBox(height: 8),
                      ...details!,
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
