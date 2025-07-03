import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testify/models/user.dart';
import 'package:testify/providers/user_provider.dart';
import 'package:testify/views/home/home_screen.dart';
import 'package:testify/views/profile/profile_screen.dart';
import 'package:testify/views/resource/resource_screen.dart';
import 'package:testify/views/subscription/subscription.dart';
import 'package:testify/views/test/test_screen_main.dart';
import 'package:provider/provider.dart';
import 'package:testify/providers/theme_provider.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const HomeScreen(),
    const TestScreenMain(),
    const SubscriptionScreen(),
    const ResourcesScreen(),
    const ProfileScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onBottomNavItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      final user = userProvider.user;
      if (user == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        drawer: _buildDrawer(user, userProvider),
        body: PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            // Only build the current screen
            return _screens[index % _screens.length];
          },
          itemCount: _screens.length,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          pageSnapping: true,
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      );
    });
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu,
              color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Text(
        _getScreenTitle(),
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: FontWeight.bold,
        ),
      ),
      // actions: [
      //   IconButton(
      //     icon: Icon(
      //       Icons.notifications_outlined,
      //       color: Theme.of(context).textTheme.bodyLarge?.color,
      //     ),
      //     onPressed: () {
      //       // Handle notifications
      //     },
      //   ),
      // ],
    );
  }

  String _getScreenTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Tests';
      case 2:
        return 'Premium';
      case 3:
        return 'Resources';
      case 4:
        return 'Profile';
      default:
        return 'Testify';
    }
  }

  Widget _buildDrawer(User? user, UserProvider userProvider) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).cardColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildDrawerHeader(user),
            const SizedBox(height: 8),
            _buildDrawerItem(
              icon: Icons.home_outlined,
              title: 'Home',
              onTap: () => _navigateAndCloseDrawer(0),
            ),
            _buildDrawerItem(
              icon: Icons.assignment_outlined,
              title: 'Tests',
              onTap: () => _navigateAndCloseDrawer(1),
            ),
            _buildDrawerItem(
              icon: Icons.workspace_premium_outlined,
              title: 'Premium',
              onTap: () => _navigateAndCloseDrawer(2),
            ),
            _buildDrawerItem(
              icon: Icons.book_outlined,
              title: 'Resources',
              onTap: () => _navigateAndCloseDrawer(3),
            ),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) => SwitchListTile(
                title: Row(
                  children: [
                    Icon(
                      themeProvider.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Dark Mode',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.toggleTheme(),
                activeColor: Theme.of(context).primaryColor,
              ),
            ),
            const Divider(height: 32),
            _buildDrawerItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
            _buildDrawerItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {},
            ),
            _buildDrawerItem(
              icon: Icons.question_answer_outlined,
              title: 'FAQs',
              onTap: () => Navigator.pushNamed(context, '/faq'),
            ),
            _buildDrawerItem(
              icon: Icons.info_outline,
              title: 'About Us',
              onTap: () => Navigator.pushNamed(context, '/about-us'),
            ),
            _buildDrawerItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () => Navigator.pushNamed(context, '/privacy-policy'),
            ),
            _buildDrawerItem(
              icon: Icons.article_outlined,
              title: 'Terms & Conditions',
              onTap: () => Navigator.pushNamed(context, '/terms'),
            ),
            _buildDrawerItem(
              icon: Icons.exit_to_app,
              title: 'Logout',
              onTap: () => _onLogout(userProvider),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(User? user) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 24,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            child: user!.profilePicture.isEmpty
                ? Icon(
                    Icons.person,
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  )
                : ClipOval(
                    child: Image.network(
                      user.profilePicture,
                      fit: BoxFit.cover, // Ensures the image fills the circle
                      width: 80, // Match the container size
                      height: 80, // Match the container size
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome Back!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Continue your learning journey',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Theme.of(context).textTheme.bodyMedium?.color,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Tests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.workspace_premium_outlined),
            activeIcon: Icon(Icons.workspace_premium),
            label: 'Premium',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Resources',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _navigateAndCloseDrawer(int index) {
    Navigator.pop(context);
    _onBottomNavItemTapped(index);
  }

  Future<bool> _onLogout(UserProvider userProvider) async {
    return await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Logout from Testify!',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Are you sure you want to logout?',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _handleLogout(userProvider);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Logout'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _handleLogout(UserProvider userProvider) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await userProvider.clearUser();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }
}
