import 'package:flutter/material.dart';
import 'package:su/core/constants/app_colors.dart';
import 'package:su/core/constants/app_routes.dart';
import 'package:su/core/constants/app_text_styles.dart';
import 'package:su/pages/settings_page.dart' show AboutPage;
import 'package:su/pages/chat_page.dart';
import 'package:su/widgets/semester_box.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  static const _semesters = [
    _SemData('SEM 1', 'assets/1.png', AppColors.sem1, AppRoutes.sem1),
    _SemData('SEM 2', 'assets/2.png',     AppColors.sem2, AppRoutes.sem2),
    _SemData('SEM 3', 'assets/3.png',    AppColors.sem3, AppRoutes.sem3),
    _SemData('SEM 4', 'assets/4.png',  AppColors.sem4, AppRoutes.sem4),
    _SemData('SEM 5', 'assets/5.png',    AppColors.sem5, AppRoutes.sem5),
    _SemData('SEM 6', 'assets/6.png',   AppColors.sem6, AppRoutes.sem6),
  ];

  Widget get _currentPage => _currentIndex == 0
      ? _SemestersTab(semesters: _semesters)
      : _currentIndex == 1
          ? const ChatPage()
          : const AboutPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _currentIndex == 0
          ? AppBar(
              backgroundColor: AppColors.background,
              automaticallyImplyLeading: false,
              title: Text('SU', style: AppTextStyles.appBarTitle),
            )
          : null,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _currentPage,
        ),
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ── Semesters tab ─────────────────────────────────────────────────────────────
class _SemestersTab extends StatelessWidget {
  final List<_SemData> semesters;
  const _SemestersTab({required this.semesters});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:   2,
        crossAxisSpacing: 16,
        mainAxisSpacing:  16,
      ),
      itemCount: semesters.length,
      itemBuilder: (context, i) {
        final sem = semesters[i];
        return SemesterBox(
          label:     sem.label,
          imagePath: sem.image,
          color:     sem.color,
          onTap:     () => Navigator.pushNamed(context, sem.route),
        );
      },
    );
  }
}

// ── Bottom nav ────────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int              currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(
                icon:   Icons.school_rounded,
                label:  'HOME',
                active: currentIndex == 0,
                onTap:  () => onTap(0),
              ),
              _NavItem(
                icon:   Icons.chat_bubble_rounded,
                label:  'Chat',
                active: currentIndex == 1,
                onTap:  () => onTap(1),
              ),
              _NavItem(
                icon:   Icons.info_rounded,
                label:  'About',
                active: currentIndex == 2,
                onTap:  () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final bool         active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.subtle;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color:      color,
                fontSize:   12,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width:  active ? 24 : 0,
              decoration: BoxDecoration(
                color:        AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────
class _SemData {
  final String label;
  final String image;
  final Color  color;
  final String route;
  const _SemData(this.label, this.image, this.color, this.route);
}