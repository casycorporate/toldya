import 'package:flutter/material.dart';
import 'package:bendemistim/helper/theme.dart';

/// Ortak boş durum içeriği: minimalist dark arka plan, ikon, başlık, alt yazı.
class EmptyStateContent extends StatelessWidget {
  const EmptyStateContent({
    Key? key,
    this.title = 'Henüz bir tahmin yok',
    this.subtitle = 'Yeni tahminler burada görünecek.\nAltta bulunan butona dokunarak tahmin oluşturabilirsiniz.',
  }) : super(key: key);

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MockupDesign.background,
      height: double.infinity,
      width: double.infinity,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MockupDesign.screenPadding * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 100,
                color: Colors.white.withOpacity(0.1),
              ),
              SizedBox(height: 32),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modern, minimalist empty state for "Ben Demiştim" social betting app.
/// Dark mode, readable, with FAB and BottomAppBar.
class EmptyStateScreen extends StatelessWidget {
  const EmptyStateScreen({
    Key? key,
    this.onMenuPressed,
    this.onHistoryPressed,
    this.onFabPressed,
    this.onHomePressed,
    this.onSearchPressed,
    this.onNotificationsPressed,
    this.onProfilePressed,
  }) : super(key: key);

  final VoidCallback? onMenuPressed;
  final VoidCallback? onHistoryPressed;
  final VoidCallback? onFabPressed;
  final VoidCallback? onHomePressed;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onNotificationsPressed;
  final VoidCallback? onProfilePressed;

  static const Color _background = Color(0xFF1C1C1E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Theme.of(context).colorScheme.onSurface),
          onPressed: onMenuPressed ?? () {},
        ),
        centerTitle: true,
        title: Text(
          'Ben demiştim',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
            onPressed: onHistoryPressed ?? () {},
          ),
        ],
      ),
      body: EmptyStateContent(),
    );
  }
}
