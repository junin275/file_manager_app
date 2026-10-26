import 'package:flutter/material.dart';

class BottomActionBar extends StatelessWidget {
  final int selectionCount;
  final VoidCallback onExitSelection;
  final VoidCallback onCompress;
  final VoidCallback onDecompress;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const BottomActionBar({
    super.key,
    required this.selectionCount,
    required this.onExitSelection,
    required this.onCompress,
    required this.onDecompress,
    required this.onShare,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 8,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      color: colorScheme.surfaceContainerHighest,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  '$selectionCount selecionado(s)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onExitSelection,
                  tooltip: 'Sair da seleção',
                ),
              ],
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.archive_rounded,
                  label: 'Compactar',
                  color: colorScheme.primary,
                  onPressed: onCompress,
                ),
                _ActionButton(
                  icon: Icons.unarchive_rounded,
                  label: 'Descompactar',
                  color: Colors.green.shade600,
                  onPressed: onDecompress,
                ),
                _ActionButton(
                  icon: Icons.share_rounded,
                  label: 'Compartilhar',
                  color: colorScheme.onSurfaceVariant,
                  onPressed: onShare,
                ),
                _ActionButton(
                  icon: Icons.delete_rounded,
                  label: 'Excluir',
                  color: colorScheme.error,
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}