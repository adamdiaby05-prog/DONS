import 'package:flutter/material.dart';
import '../../models/group.dart';

class GroupListItem extends StatelessWidget {
  final Group group;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewDetails;

  const GroupListItem({
    super.key,
    required this.group,
    required this.onEdit,
    required this.onDelete,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getGroupTypeColor(group.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getGroupTypeIcon(group.type),
            color: _getGroupTypeColor(group.type),
            size: 24,
          ),
        ),
        title: Text(
          group.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              group.description ?? 'Aucune description',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.monetization_on,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${group.contributionAmount.toStringAsFixed(0)} FCFA',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _getFrequencyLabel(group.frequency),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onViewDetails,
              icon: Icon(
                Icons.visibility,
                color: Colors.grey[600],
                size: 20,
              ),
              tooltip: 'Voir détails',
            ),
            IconButton(
              onPressed: onEdit,
              icon: Icon(
                Icons.edit,
                color: Colors.blue[600],
                size: 20,
              ),
              tooltip: 'Modifier',
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete,
                color: Colors.red[600],
                size: 20,
              ),
              tooltip: 'Supprimer',
            ),
          ],
        ),
      ),
    );
  }

  Color _getGroupTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'association':
        return Colors.blue;
      case 'tontine':
        return Colors.green;
      case 'mutuelle':
        return Colors.orange;
      case 'cooperative':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getGroupTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'association':
        return Icons.people;
      case 'tontine':
        return Icons.account_balance_wallet;
      case 'mutuelle':
        return Icons.health_and_safety;
      case 'cooperative':
        return Icons.business;
      default:
        return Icons.group;
    }
  }

  String _getFrequencyLabel(String frequency) {
    switch (frequency.toLowerCase()) {
      case 'daily':
        return 'Quotidien';
      case 'weekly':
        return 'Hebdomadaire';
      case 'monthly':
        return 'Mensuel';
      case 'yearly':
        return 'Annuel';
      default:
        return frequency;
    }
  }
}
