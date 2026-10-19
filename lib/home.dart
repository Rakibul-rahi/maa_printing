import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login.dart';
import 'danar_party_hishab.dart';
import 'customer_hishab.dart';
import 'daily_production_hishab.dart';
import 'stock_hishab.dart';
import 'notifications_page.dart';
import 'ready_goods.dart';
import 'chat/chat_list_screen.dart';
import 'chat/chat_models.dart';
import 'chat/chat_providers.dart';
import 'l10n/l10n.dart';
import 'settings/settings_sheet.dart';
import 'theme/app_theme.dart';
import 'theme/app_widgets.dart';

class HomePage extends StatefulWidget {
  final String uid;
  const HomePage({super.key, required this.uid});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _roleFilter = '';
  String _role = '';

  @override
  void initState() {
    super.initState();
    _initializeUserRole();
  }

  Future<void> _initializeUserRole() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
    final role = doc.data()?['role'] ?? 'User';
    setState(() {
      _roleFilter = role;
      _role = role;
    });
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'owner':
        return Colors.blue;
      case 'admin':
        return Colors.redAccent;
      case 'editor':
        return Colors.green;
      default:
        return Colors.indigo;
    }
  }

  String _getWelcomeMessage(AppLocalizations l10n, String role) {
    switch (role) {
      case 'owner':
        return l10n.welcomeOwner;
      case 'admin':
        return l10n.welcomeAdmin;
      case 'editor':
        return l10n.welcomeEditor;
      default:
        return l10n.welcomeDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_role.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final l10n = context.l10n;
    final roleColor = _getRoleColor(_role);

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {},
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.appName),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(
                children: [
                  if (_role == 'owner' || _role == 'admin')
                    IconButton(
                      icon: const Icon(Icons.notifications),
                      tooltip: l10n.viewNotifications,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationsPage(roleFilter: _roleFilter),
                          ),
                        );
                      },
                    ),
                  if (chatRoles.contains(_role.toLowerCase()))
                    Consumer(
                      builder: (context, ref, _) {
                        final unread = ref.watch(totalUnreadProvider);
                        return IconButton(
                          tooltip: l10n.chat,
                          icon: Badge(
                            isLabelVisible: unread > 0,
                            label: Text(unread > 99 ? '99+' : '$unread'),
                            child: const Icon(Icons.chat),
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ChatListScreen()),
                          ),
                        );
                      },
                    ),
                  const SettingsButton(),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: l10n.signOut,
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                              (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _buildWelcomeCard(l10n, roleColor),
            const SizedBox(height: 16),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _buildPartyDueCard()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildCustomerReceivableCard()),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildAccountingButtons(context, _role),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(AppLocalizations l10n, Color roleColor) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(14), child: _buildLogoSection()),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getWelcomeMessage(l10n, _role),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: roleColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.role(_role),
                      style: TextStyle(color: roleColor, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(l10n.managementSystem, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Image.asset(
      'assets/maa.png',
      width: 72,
      height: 72,
      errorBuilder: (context, error, stackTrace) =>
      const Icon(Icons.factory, size: 64, color: Colors.blue),
    );
  }

  Widget _buildPartyDueCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('partyAccounts').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return _ErrorText(context.l10n.errorFetchingParty);
        if (snapshot.connectionState == ConnectionState.waiting) return const _LoadingIndicator();

        double totalDue = 0;
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final totalBill = (data['totalBill'] as num?)?.toDouble() ?? 0.0;
          final totalPaid = (data['totalPaid'] as num?)?.toDouble() ?? 0.0;
          final due = totalBill - totalPaid;
          if (due > 0) totalDue += due;
        }

        return _AmountCard(
          title: context.l10n.totalDueToParties,
          amount: totalDue,
          color: Colors.redAccent,
          icon: Icons.hourglass_bottom_sharp,
        );
      },
    );
  }

  Widget _buildCustomerReceivableCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('customerAccounts').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return _ErrorText(context.l10n.errorFetchingCustomer);
        if (snapshot.connectionState == ConnectionState.waiting) return const _LoadingIndicator();

        double totalReceivable = 0;
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final totalBill = (data['totalBill'] as num?)?.toDouble() ?? 0.0;
          final totalPaid = (data['totalPaid'] as num?)?.toDouble() ?? 0.0;
          final due = totalBill - totalPaid;
          if (due > 0) totalReceivable += due;
        }

        return _AmountCard(
          title: context.l10n.totalReceivableFromCustomers,
          amount: totalReceivable,
          color: Colors.green,
          icon: Icons.attach_money,
        );
      },
    );
  }

  Widget _buildAccountingButtons(BuildContext context, String role) {
    final items = <_MenuItem>[
      _MenuItem(Icons.account_balance_wallet, context.l10n.menuDanarParty, Colors.deepOrange, const DanarPartyHishab()),
      _MenuItem(Icons.groups, context.l10n.menuCustomer, Colors.teal, const CustomerHishab()),
      _MenuItem(Icons.bar_chart, context.l10n.menuDailyProduction, Colors.indigo, const DailyProductionHishab()),
      _MenuItem(Icons.add_business, context.l10n.menuPowder, Colors.purple, const HomeStockView()),
      _MenuItem(Icons.inventory, context.l10n.menuReadyGoods, Colors.blue, const ReadyGoodsInventoryScreen()),
    ];
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisExtent: 128,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      children: [
        for (final m in items)
          _MenuTile(
            item: m,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => m.page)),
          ),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final Widget page;
  const _MenuItem(this.icon, this.label, this.color, this.page);
}

class _MenuTile extends StatelessWidget {
  final _MenuItem item;
  final VoidCallback onTap;
  const _MenuTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconBadge(icon: item.icon, color: item.color, size: 48),
              Text(
                item.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const _AmountCard({required this.title, required this.amount, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconBadge(icon: icon, color: color, size: 38),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                context.money(amount),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
    );
  }
}

class _ErrorText extends StatelessWidget {
  final String message;
  const _ErrorText(this.message);

  @override
  Widget build(BuildContext context) {
    return Text(message, style: TextStyle(color: context.dangerColor));
  }
}
