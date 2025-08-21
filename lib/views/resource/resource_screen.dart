import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testify/models/resource.dart';
import 'package:testify/providers/user_provider.dart';
import 'package:testify/services/resource_service.dart';
import 'package:open_file/open_file.dart';
import 'package:testify/utils/permission_handler_utils.dart';
import 'package:testify/widgets/custom_toast.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  bool _isLoading = false;
  List<Resource> _resources = [];
  List<Resource> _filteredResources = [];
  Set<String> downloadingResources = {}; // Track downloading resources by ID
  late final ResourceService _resourceService;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initService();
    _searchController.addListener(_filterResources);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initService() async {
    _resourceService = await ResourceService.create(context);
    _fetchResources();
  }

  Future<void> _fetchResources() async {
    setState(() => _isLoading = true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final subExamId = userProvider.user?.subExamId;
    try {
      final resources = await _resourceService.getResources(subExamId!);
      if (!mounted) return;
      setState(() {
        _resources = resources;
        _filteredResources = resources; // Initialize filtered list
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching resources: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterResources() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredResources = _resources;
      } else {
        _filteredResources = _resources.where((resource) {
          return resource.title.toLowerCase().contains(query) ||
              resource.description.toLowerCase().contains(query) ||
              resource.type.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> downloadAndOpenResource(
      String url, String title, String type, String resourceId) async {
    setState(() => downloadingResources.add(resourceId));

    // Skip permission check on web
    if (!kIsWeb) {
      final PermissionManager permissionManager = PermissionManager();
      bool hasPermission =
          await permissionManager.checkAndRequestStoragePermission(context);
      if (!hasPermission) {
        setState(() => downloadingResources.remove(resourceId));
        if (mounted) {
          CustomToast.show(
            context: context,
            message: 'Storage Permission denied',
            isError: true,
          );
        }
        return;
      }
    }

    if (!mounted) return;
    try {
      final filePath =
          await _resourceService.downloadResource(url, title, type, context);
      setState(() => downloadingResources.remove(resourceId));

      // Only try to open file on non-web platforms
      if (!kIsWeb) {
        OpenFile.open(filePath);
      } else {
        // Show success message on web since we can't open files
        if (mounted) {
          CustomToast.show(
            context: context,
            message: 'File downloaded successfully',
            isError: false,
          );
        }
      }
    } catch (e) {
      setState(() => downloadingResources.remove(resourceId));
      if (mounted) {
        CustomToast.show(
          context: context,
          message: 'Download failed',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 10),
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildSearchBar(context),
                const SizedBox(height: 16),
                _buildFilterChips(context),
                const SizedBox(height: 16),
                _filteredResources.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isNotEmpty
                              ? 'No resources found matching "${_searchController.text}"'
                              : 'No resources available',
                          style: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withValues(alpha: 0.7),
                          ),
                        ),
                      )
                    : Expanded(
                        child: _buildResourceList(),
                      ),
              ],
            ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Study Resources',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Access free study materials for your exam preparation',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withValues(alpha: 0.7),
            ),
          ),
          // const SizedBox(height: 16),
          // Row(
          //   children: [
          //     _buildStatCard(
          //       Icons.file_copy_outlined,
          //       '${_resources.length}',
          //       'Available\nResources',
          //       Colors.blue,
          //     ),
          //     const SizedBox(width: 16),
          //     _buildStatCard(
          //       Icons.download_outlined,
          //       '4K+',
          //       'Total\nDownloads',
          //       Colors.green,
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  // Widget _buildStatCard(
  //     IconData icon, String value, String label, Color color) {
  //   return Expanded(
  //     child: Container(
  //       padding: const EdgeInsets.all(16),
  //       decoration: BoxDecoration(
  //         color: color.withValues(alpha:0.1),
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(color: color.withValues(alpha:0.2)),
  //       ),
  //       child: Row(
  //         children: [
  //           Icon(icon, color: color, size: 24),
  //           const SizedBox(width: 12),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   value,
  //                   style: TextStyle(
  //                     fontSize: 20,
  //                     fontWeight: FontWeight.bold,
  //                     color: color,
  //                   ),
  //                 ),
  //                 Text(
  //                   label,
  //                   style: TextStyle(
  //                     fontSize: 12,
  //                     color: color.withValues(alpha:0.8),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search resources...',
          prefixIcon: Icon(Icons.search,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color!
                  .withValues(alpha: 0.7)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color!
                          .withValues(alpha: 0.7)),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip('All', true, context),
          // _buildFilterChip('PDF', false, context),
          // _buildFilterChip('Videos', false, context),
          // _buildFilterChip('Practice Sets', false, context),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (bool value) {},
        backgroundColor: Theme.of(context).cardColor,
        selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildResourceList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredResources.length,
      itemBuilder: (context, index) {
        final resource = _filteredResources[index];
        return _buildResourceCard(resource, context);
      },
    );
  }

  Widget _buildResourceCard(Resource resource, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.file_copy,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          resource.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              resource.description,
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildResourceInfo(
                    Icons.description, resource.type.toUpperCase(), context),
                const SizedBox(width: 16),
                _buildResourceInfo(
                    Icons.data_usage, '${resource.size} MB', context),
                // const SizedBox(width: 16),
                // _buildResourceInfo(
                //     Icons.download, '${resource.downloads} downloads', context),
              ],
            ),
          ],
        ),
        trailing: downloadingResources.contains(resource.id)
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : IconButton(
                icon: const Icon(Icons.download_outlined),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  // Implement download logic
                  downloadAndOpenResource(
                      resource.url, resource.title, resource.type, resource.id);
                },
              ),
      ),
    );
  }

  Widget _buildResourceInfo(IconData icon, String text, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }
}
