import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../models/user.dart';
import '../../models/group.dart';
import '../../services/member_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class MembersManagementScreen extends StatefulWidget {
  const MembersManagementScreen({super.key});

  @override
  State<MembersManagementScreen> createState() => _MembersManagementScreenState();
}

class _MembersManagementScreenState extends State<MembersManagementScreen> {
  List<User> _members = [];
  List<Group> _availableGroups = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedIndex = 2; // Index pour "Gestion des Membres"

  @override
  void initState() {
    super.initState();
    _loadMembers();
    _loadAvailableGroups();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final dio = Dio(BaseOptions(
        baseUrl: 'http://127.0.0.1:8000/api',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));

      final memberService = MemberService(
        dio: dio,
        baseUrl: 'http://127.0.0.1:8000',
      );

      final members = await memberService.getAllMembers();
      setState(() {
        _members = members;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAvailableGroups() async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: 'http://127.0.0.1:8000/api',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));

      final memberService = MemberService(
        dio: dio,
        baseUrl: 'http://127.0.0.1:8000',
      );

      final groups = await memberService.getAvailableGroups();
      setState(() {
        _availableGroups = groups;
      });
    } catch (e) {
      // Ignorer l'erreur pour les groupes, ce n'est pas critique
    }
  }

  List<User> get _filteredMembers {
    if (_searchQuery.isEmpty) {
      return _members;
    }
    return _members.where((member) {
      final fullName = '${member.firstName} ${member.lastName}'.toLowerCase();
      final phone = member.phoneNumber.toLowerCase();
      final email = member.email?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      
      return fullName.contains(query) || 
             phone.contains(query) || 
             email.contains(query);
    }).toList();
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
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFb22222),
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
                      Text(
                        'Administration',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Gestion des Dons',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
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
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _sidebarItems.length,
              itemBuilder: (context, index) {
                return _buildSidebarItem(_sidebarItems[index], index);
              },
            ),
          ),
          
          // Footer
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
                    size: 20,
                    color: const Color(0xFFb22222),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Administrateur',
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
                    // TODO: Implémenter la déconnexion
                    Navigator.pushNamed(context, '/login');
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
    final isSelected = index == _selectedIndex;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _navigateToRoute(item['route']),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFb22222).withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected ? Border.all(
                color: const Color(0xFFb22222).withOpacity(0.3),
                width: 1,
              ) : null,
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
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? const Color(0xFFb22222) : Colors.grey[800],
                          fontSize: 14,
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
        // Header avec titre et bouton refresh
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestion des Membres',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      'Ajoutez et gérez vos membres',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadMembers,
                tooltip: 'Actualiser',
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showCreateMemberDialog,
                icon: const Icon(Icons.add),
                label: const Text('Nouveau Membre'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                  : _buildMembersContent(),
        ),
      ],
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
            onPressed: _loadMembers,
            child: const Text('Réessayer'),
          ),
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
        Navigator.pushNamed(context, '/admin/groups');
        break;
      case '/admin/members':
        // Déjà sur cette page
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

  Widget _buildMembersContent() {
    return Column(
      children: [
        // Barre de recherche
        Container(
          padding: const EdgeInsets.all(16),
          child: CustomTextField(
            controller: _searchController,
            labelText: 'Rechercher un membre...',
            prefixIcon: Icons.search,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),

        // Statistiques
        _buildStatsCards(),

        const SizedBox(height: 16),

        // Liste des membres
        Expanded(
          child: _filteredMembers.isEmpty
              ? _buildEmptyState()
              : _buildMembersList(),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Membres',
              _members.length.toString(),
              Icons.people,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Membres Actifs',
              _members.where((m) => m.phoneVerified).length.toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun membre trouvé',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Aucun membre ne correspond à votre recherche'
                : 'Commencez par ajouter votre premier membre',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showCreateMemberDialog,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un membre'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredMembers.length,
      itemBuilder: (context, index) {
        final member = _filteredMembers[index];
        return _buildMemberCard(member);
      },
    );
  }

  Widget _buildMemberCard(User member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(
            '${member.firstName[0]}${member.lastName[0]}'.toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          '${member.firstName} ${member.lastName}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(member.phoneNumber),
              ],
            ),
            if (member.email != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.email, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(member.email!),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  member.phoneVerified ? Icons.verified : Icons.warning,
                  size: 16,
                  color: member.phoneVerified ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  member.phoneVerified ? 'Vérifié' : 'Non vérifié',
                  style: TextStyle(
                    color: member.phoneVerified ? Colors.green : Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMemberAction(value, member),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Modifier'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'groups',
              child: Row(
                children: [
                  Icon(Icons.group),
                  SizedBox(width: 8),
                  Text('Gérer les groupes'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Supprimer', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMemberAction(String action, User member) {
    switch (action) {
      case 'edit':
        _showEditMemberDialog(member);
        break;
      case 'groups':
        _showManageGroupsDialog(member);
        break;
      case 'delete':
        _showDeleteConfirmation(member);
        break;
    }
  }

  Future<void> _showCreateMemberDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _CreateMemberDialog(availableGroups: _availableGroups),
    );

    if (result != null) {
      try {
        final dio = Dio(BaseOptions(
          baseUrl: 'http://127.0.0.1:8000/api',
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ));

        final memberService = MemberService(
          dio: dio,
          baseUrl: 'http://127.0.0.1:8000',
        );

        await memberService.createMember(result);
        _loadMembers();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Membre créé avec succès !'),
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

  Future<void> _showEditMemberDialog(User member) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _EditMemberDialog(
        member: member,
        availableGroups: _availableGroups,
      ),
    );

    if (result != null) {
      try {
        final dio = Dio(BaseOptions(
          baseUrl: 'http://127.0.0.1:8000/api',
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ));

        final memberService = MemberService(
          dio: dio,
          baseUrl: 'http://127.0.0.1:8000',
        );

        await memberService.updateMember(member.id, result);
        _loadMembers();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Membre mis à jour avec succès !'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la mise à jour: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showManageGroupsDialog(User member) async {
    // TODO: Implémenter la gestion des groupes pour un membre
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gestion des groupes bientôt disponible'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _showDeleteConfirmation(User member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le membre "${member.firstName} ${member.lastName}" ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final dio = Dio(BaseOptions(
          baseUrl: 'http://127.0.0.1:8000/api',
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ));

        final memberService = MemberService(
          dio: dio,
          baseUrl: 'http://127.0.0.1:8000',
        );

        await memberService.deleteMember(member.id);
        _loadMembers();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Membre supprimé avec succès !'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la suppression: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _CreateMemberDialog extends StatefulWidget {
  final List<Group> availableGroups;

  const _CreateMemberDialog({required this.availableGroups});

  @override
  State<_CreateMemberDialog> createState() => _CreateMemberDialogState();
}

class _CreateMemberDialogState extends State<_CreateMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  List<int> _selectedGroupIds = [];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouveau Membre'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                             CustomTextField(
                 controller: _firstNameController,
                 labelText: 'Prénom *',
                 validator: (value) {
                   if (value == null || value.isEmpty) {
                     return 'Le prénom est requis';
                   }
                   return null;
                 },
               ),
               const SizedBox(height: 16),
               CustomTextField(
                 controller: _lastNameController,
                 labelText: 'Nom *',
                 validator: (value) {
                   if (value == null || value.isEmpty) {
                     return 'Le nom est requis';
                   }
                   return null;
                 },
               ),
               const SizedBox(height: 16),
               CustomTextField(
                 controller: _phoneController,
                 labelText: 'Numéro de téléphone *',
                 keyboardType: TextInputType.phone,
                 validator: (value) {
                   if (value == null || value.isEmpty) {
                     return 'Le numéro de téléphone est requis';
                   }
                   return null;
                 },
               ),
               const SizedBox(height: 16),
               CustomTextField(
                 controller: _emailController,
                 labelText: 'Email (optionnel)',
                 keyboardType: TextInputType.emailAddress,
               ),
               const SizedBox(height: 16),
               CustomTextField(
                 controller: _passwordController,
                 labelText: 'Mot de passe *',
                 obscureText: true,
                 validator: (value) {
                   if (value == null || value.isEmpty) {
                     return 'Le mot de passe est requis';
                   }
                   if (value.length < 6) {
                     return 'Le mot de passe doit contenir au moins 6 caractères';
                   }
                   return null;
                 },
               ),
              if (widget.availableGroups.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Groupes (optionnel)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...widget.availableGroups.map((group) => CheckboxListTile(
                  title: Text(group.name),
                  subtitle: Text(group.type),
                  value: _selectedGroupIds.contains(group.id),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedGroupIds.add(group.id);
                      } else {
                        _selectedGroupIds.remove(group.id);
                      }
                    });
                  },
                )),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Créer'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final memberData = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'phone_number': _phoneController.text,
        'email': _emailController.text.isNotEmpty ? _emailController.text : null,
        'password': _passwordController.text,
        if (_selectedGroupIds.isNotEmpty) 'group_ids': _selectedGroupIds,
      };

      Navigator.of(context).pop(memberData);
    }
  }
}

class _EditMemberDialog extends StatefulWidget {
  final User member;
  final List<Group> availableGroups;

  const _EditMemberDialog({
    required this.member,
    required this.availableGroups,
  });

  @override
  State<_EditMemberDialog> createState() => _EditMemberDialogState();
}

class _EditMemberDialogState extends State<_EditMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();
  List<int> _selectedGroupIds = [];

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.member.firstName);
    _lastNameController = TextEditingController(text: widget.member.lastName);
    _phoneController = TextEditingController(text: widget.member.phoneNumber);
    _emailController = TextEditingController(text: widget.member.email ?? '');
    
    // Charger les groupes actuels du membre
    if (widget.member.groupMembers != null) {
      _selectedGroupIds = widget.member.groupMembers!
          .map((gm) => gm.groupId)
          .toList();
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier le Membre'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                             CustomTextField(
                 controller: _firstNameController,
                 labelText: 'Prénom *',
                 validator: (value) {
                   if (value == null || value.isEmpty) {
                     return 'Le prénom est requis';
                   }
                   return null;
                 },
               ),
               const SizedBox(height: 16),
               CustomTextField(
                 controller: _lastNameController,
                 labelText: 'Nom *',
                 validator: (value) {
                   if (value == null || value.isEmpty) {
                     return 'Le nom est requis';
                   }
                   return null;
                 },
               ),
               const SizedBox(height: 16),
               CustomTextField(
                 controller: _phoneController,
                 labelText: 'Numéro de téléphone *',
                 keyboardType: TextInputType.phone,
                 validator: (value) {
                   if (value == null || value.isEmpty) {
                     return 'Le numéro de téléphone est requis';
                   }
                   return null;
                 },
               ),
               const SizedBox(height: 16),
               CustomTextField(
                 controller: _emailController,
                 labelText: 'Email (optionnel)',
                 keyboardType: TextInputType.emailAddress,
               ),
               const SizedBox(height: 16),
               CustomTextField(
                 controller: _passwordController,
                 labelText: 'Nouveau mot de passe (optionnel)',
                 obscureText: true,
                 validator: (value) {
                   if (value != null && value.isNotEmpty && value.length < 6) {
                     return 'Le mot de passe doit contenir au moins 6 caractères';
                   }
                   return null;
                 },
               ),
              if (widget.availableGroups.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Groupes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...widget.availableGroups.map((group) => CheckboxListTile(
                  title: Text(group.name),
                  subtitle: Text(group.type),
                  value: _selectedGroupIds.contains(group.id),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedGroupIds.add(group.id);
                      } else {
                        _selectedGroupIds.remove(group.id);
                      }
                    });
                  },
                )),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Mettre à jour'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final memberData = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'phone_number': _phoneController.text,
        'email': _emailController.text.isNotEmpty ? _emailController.text : null,
        'group_ids': _selectedGroupIds,
      };

      // Ajouter le mot de passe seulement s'il a été saisi
      if (_passwordController.text.isNotEmpty) {
        memberData['password'] = _passwordController.text;
      }

      Navigator.of(context).pop(memberData);
    }
  }
} 