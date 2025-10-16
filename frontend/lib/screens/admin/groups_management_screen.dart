import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../models/group.dart';
import '../../services/admin_service.dart';
import '../../widgets/admin/group_list_item.dart';
import '../../widgets/admin/create_group_dialog.dart';

class GroupsManagementScreen extends StatefulWidget {
  const GroupsManagementScreen({super.key});

  @override
  State<GroupsManagementScreen> createState() => _GroupsManagementScreenState();
}

class _GroupsManagementScreenState extends State<GroupsManagementScreen> {
  List<Group> _groups = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String _filterType = 'all';
  int _selectedIndex = 1; // Index pour "Gestion des Groupes"

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
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

      final groups = await adminService.getAllGroups();
      setState(() {
        _groups = groups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Group> get _filteredGroups {
    return _groups.where((group) {
      final matchesSearch = group.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (group.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      
      final matchesType = _filterType == 'all' || group.type == _filterType;
      
      return matchesSearch && matchesType;
    }).toList();
  }

  Future<void> _createGroup() async {
    final result = await showDialog<Group>(
      context: context,
      builder: (context) => const CreateGroupDialog(),
    );

    if (result != null) {
      try {
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

        // Créer le groupe via l'API
        final createdGroup = await adminService.createGroup({
          'name': result.name,
          'description': result.description,
          'type': result.type,
          'contribution_amount': result.contributionAmount,
          'frequency': result.frequency,
          'payment_mode': result.paymentMode,
        });

        // Ajouter le groupe créé à la liste
        setState(() {
          _groups.insert(0, createdGroup);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Groupe "${result.name}" créé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteGroup(Group group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer le groupe "${group.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
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

        await adminService.deleteGroup(group.id);
        setState(() {
          _groups.removeWhere((g) => g.id == group.id);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Groupe "${group.name}" supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

          // Navigation items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _sidebarItems.length,
              itemBuilder: (context, index) {
                final item = _sidebarItems[index];
                return _buildSidebarItem(item, index);
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
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFFb22222).withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    color: const Color(0xFFb22222),
                    size: 18,
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
                IconButton(
                  icon: Icon(Icons.logout, color: Colors.grey[600]),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(Map<String, dynamic> item, int index) {
    final isSelected = _selectedIndex == index;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
            _navigateToRoute(item['route']);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFb22222).withOpacity(0.1) : Colors.transparent,
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
                  item['icon'],
                  color: isSelected ? const Color(0xFFb22222) : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'],
                        style: TextStyle(
                          color: isSelected ? const Color(0xFFb22222) : Colors.grey[800],
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      Text(
                        item['description'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
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
    return Column(
      children: [
        // Header avec titre et boutons d'action
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.group,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Gestion des Groupes',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadGroups,
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _createGroup,
                icon: const Icon(Icons.add),
                label: const Text('Nouveau Groupe'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Contenu principal
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildErrorWidget()
                  : _buildGroupsContent(),
        ),
      ],
    );
  }

  Widget _buildGroupsContent() {
    return Column(
      children: [
        // Barre de recherche et filtres
        _buildSearchAndFilters(),
        
        // Liste des groupes
        Expanded(
          child: _buildGroupsList(),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barre de recherche
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Rechercher un groupe...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Filtres
          Row(
            children: [
              Text(
                'Filtrer par type: ',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'Tous'),
                      const SizedBox(width: 8),
                      _buildFilterChip('association', 'Association'),
                      const SizedBox(width: 8),
                      _buildFilterChip('tontine', 'Tontine'),
                      const SizedBox(width: 8),
                      _buildFilterChip('mutuelle', 'Mutuelle'),
                      const SizedBox(width: 8),
                      _buildFilterChip('cooperative', 'Coopérative'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _filterType == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterType = value;
        });
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
            onPressed: _loadGroups,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsList() {
    if (_filteredGroups.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadGroups,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredGroups.length,
        itemBuilder: (context, index) {
          final group = _filteredGroups[index];
          return GroupListItem(
            group: group,
            onEdit: () {
              // TODO: Navigation vers l'édition du groupe
            },
            onDelete: () => _deleteGroup(group),
            onViewDetails: () {
              // TODO: Navigation vers les détails du groupe
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun groupe trouvé',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _filterType != 'all'
                ? 'Essayez de modifier vos critères de recherche'
                : 'Créez votre premier groupe pour commencer',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isEmpty && _filterType == 'all') ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _createGroup,
              icon: const Icon(Icons.add),
              label: const Text('Créer un groupe'),
            ),
          ],
        ],
      ),
    );
  }

  // Éléments du sidebar
  List<Map<String, dynamic>> get _sidebarItems => [
    {
      'title': 'Tableau de Bord',
      'description': 'Vue d\'ensemble de votre activité',
      'icon': Icons.dashboard,
      'route': '/admin/dashboard',
    },
    {
      'title': 'Gestion des Groupes',
      'description': 'Créez et gérez vos groupes',
      'icon': Icons.group,
      'route': '/admin/groups',
    },
    {
      'title': 'Gestion des Membres',
      'description': 'Ajoutez et gérez vos membres',
      'icon': Icons.people,
      'route': '/admin/members',
    },
    {
      'title': 'Suivi des Cotisations',
      'description': 'Surveillez les paiements',
      'icon': Icons.receipt_long,
      'route': '/admin/contributions',
    },
    {
      'title': 'Rapports et Export',
      'description': 'Générez des rapports détaillés',
      'icon': Icons.bar_chart,
      'route': '/admin/reports',
    },
    {
      'title': 'Paramètres',
      'description': 'Configurez votre application',
      'icon': Icons.settings,
      'route': '/admin/settings',
    },
  ];

  void _navigateToRoute(String route) {
    switch (route) {
      case '/admin/dashboard':
        Navigator.pushNamed(context, '/admin/dashboard');
        break;
      case '/admin/groups':
        // Déjà sur cette page
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
    }
  }
}
