import 'package:flutter/material.dart';
import 'package:testify/custom/widgets/base_screen.dart';
import 'package:testify/models/exam.dart';
import 'package:testify/services/exam_service.dart';
import 'package:testify/services/profile_service.dart';
import 'package:testify/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:testify/models/profile_update.dart';
import 'package:testify/models/sub_exam.dart';
import 'package:testify/services/sub_exam_service.dart';
import 'package:testify/widgets/custom_toast.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  late final Future<ExamService> _examServiceFuture;
  late final Future<SubExamService> _subExamServiceFuture;

  List<Exam> _allExams = [];
  List<SubExam> _subExams = [];
  bool _isLoading = true;
  bool _isUpdating = false;
  bool _isLoadingMoreExams = false;
  bool _isLoadingMoreSubExams = false;
  String? _errorMessage;
  String? _selectedExamId;
  String? _selectedSubExamId;
  String? _activeSubExamParentId;
  bool _showingSubExams = false;
  static const int _pageSize = 6;
  int _examCurrentPage = 1;
  int _subExamCurrentPage = 1;
  bool _hasMoreExams = true;
  bool _hasMoreSubExams = true;

  @override
  void initState() {
    super.initState();
    _examServiceFuture = ExamService.create(context);
    _subExamServiceFuture = SubExamService.create(context);
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadSelectedExam();
    await _loadExams(reset: true);
  }

  Future<void> _loadExams({bool reset = false}) async {
    if (reset) {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
          _examCurrentPage = 1;
          _hasMoreExams = true;
        });
      }
    } else {
      if (_isLoadingMoreExams || !_hasMoreExams) return;
      if (mounted) {
        setState(() {
          _isLoadingMoreExams = true;
        });
      }
    }

    try {
      final examService = await _examServiceFuture;
      final nextPage = reset ? 1 : (_examCurrentPage + 1);
      final response = await examService.getAllExamsPaginated(
        page: nextPage,
        limit: _pageSize,
      );

      if (!mounted) return;

      setState(() {
        _allExams = reset ? response.items : [..._allExams, ...response.items];
        _examCurrentPage = response.pagination.currentPage;
        _hasMoreExams = response.pagination.hasNextPage;
        _isLoading = false;
        _isLoadingMoreExams = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to load exams right now.';
        _isLoading = false;
        _isLoadingMoreExams = false;
      });
    }
  }

  Future<void> _loadSelectedExam() async {
    final userProvider = context.read<UserProvider>();
    final examId = userProvider.user?.examId;
    if (examId != null) {
      setState(() {
        _selectedExamId = examId;
      });
    }
  }

  Future<void> _loadSubExams(
    String examId, {
    bool reset = false,
  }) async {
    if (reset) {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
          _showingSubExams = true;
          _activeSubExamParentId = examId;
          _subExamCurrentPage = 1;
          _hasMoreSubExams = true;
          _subExams = [];
        });
      }
    } else {
      if (_isLoadingMoreSubExams || !_hasMoreSubExams) return;
      if (mounted) {
        setState(() {
          _isLoadingMoreSubExams = true;
        });
      }
    }

    try {
      final subExamService = await _subExamServiceFuture;
      final nextPage = reset ? 1 : (_subExamCurrentPage + 1);
      final response = await subExamService.getSubExamsPaginated(
        examId,
        page: nextPage,
        limit: _pageSize,
      );

      if (!mounted) return;

      setState(() {
        _subExams = reset ? response.items : [..._subExams, ...response.items];
        _subExamCurrentPage = response.pagination.currentPage;
        _hasMoreSubExams = response.pagination.hasNextPage;
        _isLoading = false;
        _isLoadingMoreSubExams = false;
        _showingSubExams = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to load sub-exams right now.';
        _isLoading = false;
        _isLoadingMoreSubExams = false;
      });
    }
  }

  Future<void> _loadMoreExams() async {
    await _loadExams(reset: false);
  }

  Future<void> _loadMoreSubExams() async {
    final examId = _activeSubExamParentId;
    if (examId == null || examId.isEmpty) return;
    await _loadSubExams(examId, reset: false);
  }

  Future<void> _updateUserExam() async {
    if (_selectedExamId == null || _selectedSubExamId == null) return;

    setState(() {
      _isUpdating = true;
    });

    final ProfileService profileService = ProfileService();

    final updatedUser = await profileService.updateProfile(
      ProfileUpdate(
        examId: _selectedExamId,
        subExamId: _selectedSubExamId,
      ),
      context,
    );

    if (!mounted) return;

    if (updatedUser != null) {
      context.read<UserProvider>().setUser(updatedUser);
      CustomToast.show(context: context, message: 'Exam updated successfully');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) {
        return const BaseScreen();
      }));
    } else {
      CustomToast.show(
          context: context, message: 'Failed to update exam', isError: true);
    }

    setState(() {
      _isUpdating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                Expanded(child: _buildExamList()),
              ],
            ),
    );
  }

  Widget _buildHeader() {
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
            'Choose Your Exam',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _showingSubExams
                ? 'Select your specific exam category'
                : 'Select the exam you want to prepare for',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color!
                  .withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildHeaderStat(
                Icons.assignment_outlined,
                '${_allExams.length}',
                'Available\nExams',
                Colors.blue,
              ),
              const SizedBox(width: 16),
              _buildHeaderStat(
                Icons.category_outlined,
                '${_subExams.length}',
                'Sub\nCategories',
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(
      IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: color.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamList() {
    if (_errorMessage != null && _allExams.isEmpty && !_showingSubExams) {
      return _buildErrorState(
        _errorMessage!,
        onRetry: () => _loadExams(reset: true),
      );
    }

    if (_errorMessage != null && _subExams.isEmpty && _showingSubExams) {
      return _buildErrorState(
        _errorMessage!,
        onRetry: () {
          final examId = _activeSubExamParentId;
          if (examId != null && examId.isNotEmpty) {
            _loadSubExams(examId, reset: true);
          }
        },
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (!_showingSubExams) ...[
          _allExams.isEmpty
              ? Center(
                  child: Text(
                    'No Exams available',
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withValues(alpha: 0.7),
                    ),
                  ),
                )
              : Column(
                  children: [
                    _buildExamGrid(),
                    if (_hasMoreExams || _isLoadingMoreExams)
                      _buildLoadMoreButton(
                        _loadMoreExams,
                        isLoading: _isLoadingMoreExams,
                      ),
                  ],
                ),
        ] else ...[
          _subExams.isEmpty
              ? Center(
                  child: Text(
                    'No Sub Exams available',
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withValues(alpha: 0.7),
                    ),
                  ),
                )
              : Column(
                  children: [
                    _buildSubExamGrid(),
                    if (_hasMoreSubExams || _isLoadingMoreSubExams)
                      _buildLoadMoreButton(
                        _loadMoreSubExams,
                        isLoading: _isLoadingMoreSubExams,
                      ),
                  ],
                ),
        ],
        if (_showingSubExams && _selectedSubExamId != null)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: _buildUpdateButton(),
          ),
      ],
    );
  }

  Widget _buildExamGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: _allExams.length,
      itemBuilder: (context, index) {
        final exam = _allExams[index];
        final isSelected = _selectedExamId == exam.id;
        return _buildExamCard(exam, isSelected);
      },
    );
  }

  Widget _buildExamCard(Exam exam, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedExamId = exam.id;
          _selectedSubExamId = null;
        });
        _loadSubExams(exam.id, reset: true);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Image.network(
                exam.image,
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              exam.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              exam.description,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color!
                    .withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubExamGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: _subExams.length,
      itemBuilder: (context, index) {
        final subExam = _subExams[index];
        final isSelected = _selectedSubExamId == subExam.id;
        return _buildSubExamCard(subExam, isSelected);
      },
    );
  }

  Widget _buildLoadMoreButton(
    Future<void> Function() onPressed, {
    bool isLoading = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Center(
        child: OutlinedButton(
          onPressed: isLoading ? null : () => onPressed(),
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Load More'),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, {required VoidCallback onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubExamCard(SubExam subExam, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() => _selectedSubExamId = subExam.id);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (subExam.image != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Image.network(
                  subExam.image!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ),
            const SizedBox(height: 12),
            Text(
              subExam.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subExam.description,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color!
                    .withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return ElevatedButton(
      onPressed: _isUpdating ? null : _updateUserExam,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: const Size(double.infinity, 0),
      ),
      child: _isUpdating
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text(
              'Update Selection',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
