import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dio/dio.dart';
import '../../models/admin_dashboard.dart';
import '../../models/group.dart';
import '../../services/admin_service.dart';
import '../../widgets/admin/stat_card.dart';
import '../../widgets/admin/recent_groups_card.dart';
import '../../widgets/admin/recent_payments_card.dart';
import '../../widgets/admin/chart_card.dart';
import '../../widgets/admin/create_group_dialog.dart';
import '../../widgets/admin/animated_section.dart';
import '../../widgets/admin/pulse_card.dart';
import '../../widgets/admin/animated_progress_indicator.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  AdminDashboard? _dashboard;
  bool _isLoading = true;
  String? _error;
  int _selectedIndex = 0;

  final List<SidebarItem> _sidebarItems = [
    SidebarItem(
      title: 'Tableau de Bord',
      icon: Icons.dashboard,
      description: 'Vue d\'ensemble de votre activité',
      route: '/admin/dashboard',
    ),
    SidebarItem(
      title: 'Gestion des Groupes',
      icon: Icons.group,
      description: 'Créez et gérez vos groupes',
      route: '/admin/groups',
    ),
    SidebarItem(
      title: 'Gestion des Membres',
      icon: Icons.people,
      description: 'Ajoutez et gérez vos membres',
      route: '/admin/members',
    ),
    SidebarItem(
      title: 'Suivi des Cotisations',
      icon: Icons.receipt,
      description: 'Surveillez les paiements',
      route: '/admin/contributions',
    ),
    SidebarItem(
      title: 'Rapports et Export',
      icon: Icons.analytics,
      description: 'Générez des rapports détaillés',
      route: '/admin/reports',
    ),
    SidebarItem(
      title: 'Paramètres',
      icon: Icons.settings,
      description: 'Configurez votre application',
      route: '/admin/settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Créer une instance Dio configurée
      final dio = Dio(BaseOptions(
        baseUrl: 'http://127.0.0.1:8000/api',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));
      
      final adminService = AdminService(
        dio: dio,
        baseUrl: 'http://127.0.0.1:8000',
      );

      final dashboard = await adminService.getDashboard();
      setState(() {
        _dashboard = dashboard;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(),
          
          // Contenu principal
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFb22222).withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header du sidebar
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFb22222),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/ad.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DONS Admin',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Interface d\'administration',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Menu items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _sidebarItems.length,
              itemBuilder: (context, index) {
                final item = _sidebarItems[index];
                final isSelected = _selectedIndex == index;
                
                return _buildSidebarItem(item, index, isSelected);
              },
            ),
          ),
          
          // Footer du sidebar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // Profil utilisateur
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFb22222).withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        color: const Color(0xFFb22222),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Administrateur',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'admin@dons.com',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Bouton de déconnexion
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Déconnexion'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFb22222),
                      side: const BorderSide(color: Color(0xFFb22222)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(SidebarItem item, int index, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Naviguer directement vers la route
            _navigateToRoute(item.route);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected 
                  ? const Color(0xFFb22222).withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: const Color(0xFFb22222).withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  color: isSelected 
                      ? const Color(0xFFb22222)
                      : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected 
                              ? const Color(0xFFb22222)
                              : Colors.grey[800],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        item.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.arrow_forward_ios,
                    color: const Color(0xFFb22222),
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFb22222).withOpacity(0.05),
            Colors.white,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header du contenu avec boutons d'action
            Row(
              children: [
                Icon(
                  _sidebarItems[_selectedIndex].icon,
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _sidebarItems[_selectedIndex].title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        _sidebarItems[_selectedIndex].description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Boutons d'action
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadDashboard,
                      tooltip: 'Actualiser',
                    ),
                    const SizedBox(width: 8),
                    if (_selectedIndex == 1) // Gestion des Groupes
                      ElevatedButton.icon(
                        onPressed: _showCreateGroupDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Nouveau Groupe'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Contenu principal
            Expanded(
              child: _buildContentForSelectedItem(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentForSelectedItem() {
    switch (_selectedIndex) {
      case 0: // Tableau de Bord
        return _buildDashboardContent();
      case 1: // Gestion des Groupes - Rediriger vers la page des groupes
        return _buildRedirectToGroups();
      case 2: // Gestion des Membres
        return _buildMembersContent();
      case 3: // Suivi des Cotisations
        return _buildContributionsContent();
      case 4: // Rapports et Export
        return _buildReportsContent();
      case 5: // Paramètres
        return _buildSettingsContent();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFb22222)),
            ),
            SizedBox(height: 16),
            Text(
              'Chargement du tableau de bord...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    
    if (_error != null) {
      return _buildErrorWidget();
    }

    if (_dashboard == null) {
      return const Center(child: Text('Aucune donnée disponible'));
    }

    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cartes de statistiques
            _buildStatsGrid(),

            const SizedBox(height: 24),

            // Graphiques
            _buildChartsSection(),

            const SizedBox(height: 32),

            // Indicateurs de progression
            _buildProgressIndicators(),

            const SizedBox(height: 32),

            // Groupes récents
            _buildRecentGroupsSection(),

            const SizedBox(height: 24),

            // Paiements récents
            _buildRecentPaymentsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildRedirectToGroups() {
    // Rediriger automatiquement vers la page des groupes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushNamed(context, '/admin/groups');
    });
    
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildMembersContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people,
            size: 80,
            color: Theme.of(context).primaryColor.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Gestion des Membres',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/admin/members'),
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Accéder à la gestion des membres'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributionsContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt,
            size: 80,
            color: Theme.of(context).primaryColor.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Suivi des Cotisations',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/admin/contributions'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Accéder aux Cotisations'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics,
            size: 80,
            color: Theme.of(context).primaryColor.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Rapports et Export',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/admin/reports'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Accéder aux Rapports'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.settings,
            size: 80,
            color: Theme.of(context).primaryColor.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Paramètres',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/admin/settings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Accéder aux Paramètres'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadDashboard,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        StatCard(
          title: 'Groupes',
          value: _dashboard!.totalGroups.toString(),
          icon: Icons.group,
          color: Colors.blue,
          index: 0,
          onTap: () {
            Navigator.pushNamed(context, '/admin/groups');
          },
        ),
        StatCard(
          title: 'Membres',
          value: _dashboard!.totalMembers.toString(),
          icon: Icons.people,
          color: Colors.green,
          index: 1,
          onTap: () {
            Navigator.pushNamed(context, '/admin/groups');
          },
        ),
        StatCard(
          title: 'Cotisations',
          value: _dashboard!.totalContributions.toString(),
          icon: Icons.receipt,
          color: Colors.orange,
          index: 2,
          onTap: () {
            Navigator.pushNamed(context, '/admin/contributions');
          },
        ),
        StatCard(
          title: 'Montant Total',
          value: '${_dashboard!.totalAmountCollected.toStringAsFixed(0)} FCFA',
          icon: Icons.monetization_on,
          color: Colors.purple,
          index: 3,
          onTap: () {
            Navigator.pushNamed(context, '/admin/reports');
          },
        ),
      ],
    );
  }

  Widget _buildChartsSection() {
    return AnimatedSection(
      title: 'Statistiques',
      subtitle: 'Vue d\'ensemble des paiements et cotisations',
      index: 1,
      accentColor: Colors.blue,
      child: Row(
        children: [
          Expanded(
            child: ChartCard(
              title: 'Paiements en attente',
              value: _dashboard!.pendingPayments.toString(),
              color: Colors.orange,
              index: 0,
              chartData: _buildPendingPaymentsChart(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ChartCard(
              title: 'Paiements en retard',
              value: _dashboard!.overduePayments.toString(),
              color: Colors.red,
              index: 1,
              chartData: _buildOverduePaymentsChart(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingPaymentsChart() {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: _dashboard!.pendingPayments.toDouble(),
            title: 'En attente',
            color: Colors.orange,
            radius: 40,
          ),
          PieChartSectionData(
            value: (_dashboard!.totalContributions - _dashboard!.pendingPayments).toDouble(),
            title: 'Payés',
            color: Colors.green,
            radius: 40,
          ),
        ],
        centerSpaceRadius: 20,
      ),
    );
  }

  Widget _buildOverduePaymentsChart() {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: _dashboard!.overduePayments.toDouble(),
            title: 'En retard',
            color: Colors.red,
            radius: 40,
          ),
          PieChartSectionData(
            value: (_dashboard!.totalContributions - _dashboard!.overduePayments).toDouble(),
            title: 'À jour',
            color: Colors.blue,
            radius: 40,
          ),
        ],
        centerSpaceRadius: 20,
      ),
    );
  }

  Widget _buildProgressIndicators() {
    return AnimatedSection(
      title: 'Indicateurs de Performance',
      subtitle: 'Suivi des objectifs et métriques clés',
      index: 4,
      accentColor: Colors.indigo,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: AnimatedProgressIndicator(
                    value: _dashboard!.totalGroups.toDouble(),
                    maxValue: 100.0,
                    color: Colors.blue,
                    label: 'Objectif Groupes',
                    animationDuration: const Duration(milliseconds: 2000),
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: AnimatedProgressIndicator(
                    value: _dashboard!.totalMembers.toDouble(),
                    maxValue: 500.0,
                    color: Colors.green,
                    label: 'Objectif Membres',
                    animationDuration: const Duration(milliseconds: 2000),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AnimatedProgressIndicator(
                    value: _dashboard!.totalAmountCollected,
                    maxValue: 1000000.0,
                    color: Colors.purple,
                    label: 'Objectif Financier (FCFA)',
                    animationDuration: const Duration(milliseconds: 2000),
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: AnimatedProgressIndicator(
                    value: (_dashboard!.totalContributions - _dashboard!.pendingPayments).toDouble(),
                    maxValue: _dashboard!.totalContributions.toDouble(),
                    color: Colors.orange,
                    label: 'Taux de Recouvrement',
                    animationDuration: const Duration(milliseconds: 2000),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentGroupsSection() {
    return AnimatedSection(
      title: 'Groupes Récents',
      subtitle: 'Derniers groupes créés',
      index: 2,
      accentColor: Colors.green,
      action: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/admin/groups');
        },
        child: const Text('Voir tout'),
      ),
      child: PulseCard(
        pulseColor: Colors.green,
        enablePulse: _dashboard!.recentGroups.isNotEmpty,
        child: RecentGroupsCard(groups: _dashboard!.recentGroups),
      ),
    );
  }

  Widget _buildRecentPaymentsSection() {
    return AnimatedSection(
      title: 'Paiements Récents',
      subtitle: 'Dernières transactions effectuées',
      index: 3,
      accentColor: Colors.purple,
      action: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/admin/contributions');
        },
        child: const Text('Voir tout'),
      ),
      child: PulseCard(
        pulseColor: Colors.purple,
        enablePulse: _dashboard!.recentPayments.isNotEmpty,
        child: RecentPaymentsCard(payments: _dashboard!.recentPayments),
      ),
    );
  }

  Future<void> _showCreateGroupDialog() async {
    final result = await showDialog<Group>(
      context: context,
      builder: (context) => const CreateGroupDialog(),
    );

    if (result != null) {
      try {
        // Créer le groupe via l'API
        final dio = Dio(BaseOptions(
          baseUrl: 'http://127.0.0.1:8000/api',
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ));
        
        final adminService = AdminService(
          dio: dio,
          baseUrl: 'http://127.0.0.1:8000',
        );

        await adminService.createGroup({
          'name': result.name,
          'description': result.description,
          'type': result.type,
          'contribution_amount': result.contributionAmount,
          'frequency': result.frequency,
          'payment_mode': result.paymentMode,
        });

        // Recharger le dashboard
        _loadDashboard();

        // Afficher un message de succès
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Groupe créé avec succès !'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la création: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _navigateToRoute(String route) {
    switch (route) {
      case '/admin/dashboard':
        // Déjà sur cette page
        break;
      case '/admin/groups':
        Navigator.pushNamed(context, '/admin/groups');
        break;
      case '/admin/members':
        Navigator.pushNamed(context, '/admin/members');
        break;
      case '/admin/contributions':
        Navigator.pushNamed(context, '/admin/contributions');
        break;
      case '/admin/reports':
        Navigator.pushNamed(context, '/admin/reports');
        break;
      case '/admin/settings':
        Navigator.pushNamed(context, '/admin/settings');
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Route non trouvée: $route'),
            backgroundColor: Colors.red,
          ),
        );
        break;
    }
  }
}

class SidebarItem {
  final String title;
  final IconData icon;
  final String description;
  final String route;

  SidebarItem({
    required this.title,
    required this.icon,
    required this.description,
    required this.route,
  });
}
