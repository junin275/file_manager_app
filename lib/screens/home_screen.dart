import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:archive/archive.dart';
import '../models/file_item.dart';
import '../providers/file_manager_provider.dart';
import '../utils/zip_helper.dart';
import '../widgets/file_item.dart';
import '../widgets/bottom_action_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late FileManagerProvider _provider;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _provider = context.read<FileManagerProvider>();
    _provider.requestPermissions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<FileManagerProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            title: Text(
              provider.isSelectionMode ? provider.selectionCountText : 'Arquivos',
            ),
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: provider.currentDir.parent.path != provider.currentDir.path
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: provider.isSelectionMode
                        ? provider.exitSelectionMode
                        : provider.navigateUp,
                  )
                : null,
            actions: [
              if (!provider.isSelectionMode)
                IconButton(
                  icon: const Icon(Icons.search_rounded),
                  onPressed: () => _showSearchDialog(provider),
                ),
              if (!provider.isSelectionMode)
                IconButton(
                  icon: Icon(
                    provider.viewMode == ViewMode.list
                        ? Icons.grid_view_rounded
                        : Icons.view_list_rounded,
                  ),
                  onPressed: () => provider.setViewMode(
                    provider.viewMode == ViewMode.list ? ViewMode.grid : ViewMode.list,
                  ),
                ),
              if (!provider.isSelectionMode)
                PopupMenuButton<SortBy>(
                  icon: const Icon(Icons.sort_rounded),
                  onSelected: (sort) {
                    if (sort == provider.sortBy) {
                      provider.toggleSortOrder();
                    } else {
                      provider.setSortBy(sort);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: SortBy.name,
                      child: Text('Nome'),
                    ),
                    const PopupMenuItem(
                      value: SortBy.size,
                      child: Text('Tamanho'),
                    ),
                    const PopupMenuItem(
                      value: SortBy.date,
                      child: Text('Data'),
                    ),
                    const PopupMenuItem(
                      value: SortBy.type,
                      child: Text('Tipo'),
                    ),
                  ],
                ),
              if (!provider.isSelectionMode)
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: provider.loadCurrentFolder,
                ),
            ],
          ),
          body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async => provider.loadCurrentFolder(),
                child: _buildFileList(provider),
              ),
              if (provider.isSelectionMode)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: BottomActionBar(
                    selectionCount: provider.selectedPaths.length,
                    onExitSelection: provider.exitSelectionMode,
                    onCompress: () => _startCompress(provider),
                    onDecompress: () => _startDecompress(provider),
                    onShare: () => _shareSelected(provider),
                    onDelete: () => _confirmDelete(provider),
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddMenu,
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
            child: const Icon(Icons.create_new_folder_rounded),
          ),
        );
      },
    );
  }

  Widget _buildFileList(FileManagerProvider provider) {
    final items = provider.items;
    final isEmpty = items.isEmpty;
    final isSearching = provider.isSearching;

    if (isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.folder_open_rounded,
                    size: 80,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isSearching ? 'Nenhum resultado' : 'Pasta vazia',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isSearching
                        ? 'Tente outro termo de busca'
                        : 'Não há arquivos por aqui',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (provider.viewMode == ViewMode.list) {
      return ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: items.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: Theme.of(context).colorScheme.outlineVariant,
          indent: 72,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return FileItemWidget(
            item: item,
            isSelected: provider.selectedPaths.contains(item.path),
            isSelectionMode: provider.isSelectionMode,
            onTap: () => provider.onItemTap(item),
            onLongPress: () => provider.onItemLongPress(item),
            onMenuTap: () => _showItemMenu(item),
          );
        },
      );
    } else {
      return GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return FileItemGridWidget(
            item: item,
            isSelected: provider.selectedPaths.contains(item.path),
            isSelectionMode: provider.isSelectionMode,
            onTap: () => provider.onItemTap(item),
            onLongPress: () => provider.onItemLongPress(item),
            onMenuTap: () => _showItemMenu(item),
          );
        },
      );
    }
  }

  void _showItemMenu(FileItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.folder_open_rounded),
              title: Text(item.isDirectory ? 'Abrir pasta' : 'Abrir'),
              onTap: () {
                Navigator.pop(context);
                if (item.isDirectory) {
                  _provider.navigateTo(Directory(item.path));
                } else {
                  _openFile(item);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded),
              title: const Text('Compartilhar'),
              onTap: () {
                Navigator.pop(context);
                _shareFile(item);
              },
            ),
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline_rounded),
              title: const Text('Renomear'),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(item);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_rounded, color: Theme.of(context).colorScheme.error),
              title: Text('Excluir', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(_provider, items: [item]);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('Detalhes'),
              onTap: () {
                Navigator.pop(context);
                _showDetailsDialog(item);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showAddMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.create_new_folder_rounded),
              title: const Text('Nova pasta'),
              onTap: () {
                Navigator.pop(context);
                _showCreateFolderDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_rounded),
              title: const Text('Compactar (ZIP)'),
              onTap: () {
                Navigator.pop(context);
                _startCompress(_provider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.unarchive_rounded),
              title: const Text('Descompactar (ZIP)'),
              onTap: () {
                Navigator.pop(context);
                _startDecompress(_provider);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showCreateFolderDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova pasta'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nome da pasta'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                _createFolder(name);
                Navigator.pop(context);
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _createFolder(String name) {
    final newFolder = Directory(p.join(_provider.currentDir.path, name));
    if (!newFolder.existsSync()) {
      newFolder.createSync();
      _provider.loadCurrentFolder();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pasta criada')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pasta já existe')),
      );
    }
  }

  void _showRenameDialog(FileItem item) {
    final controller = TextEditingController(text: item.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renomear'),
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != item.name) {
                _renameItem(item, newName);
                Navigator.pop(context);
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _renameItem(FileItem item, String newName) {
    final newFile = File(p.join(_provider.currentDir.path, newName));
    if (!newFile.existsSync()) {
      File(item.path).renameSync(newFile.path);
      _provider.loadCurrentFolder();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Renomeado')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Já existe um item com esse nome')),
      );
    }
  }

  void _confirmDelete(FileManagerProvider provider, {List<FileItem>? items}) {
    final itemsToDelete = items ?? provider.selectedPaths
        .map((p) => FileItem.fromFile(File(p)))
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(itemsToDelete.length == 1 ? 'Excluir item' : 'Excluir ${itemsToDelete.length} itens'),
        content: Text(itemsToDelete.length == 1
            ? 'Tem certeza que deseja excluir "${itemsToDelete.first.name}"?'
            : 'Tem certeza que deseja excluir ${itemsToDelete.length} itens?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              Navigator.pop(context);
              _deleteItems(itemsToDelete);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItems(List<FileItem> items) async {
    bool allOk = true;
    for (final item in items) {
      final file = File(item.path);
      if (await file.exists()) {
        final ok = await _deleteRecursive(file);
        if (!ok) allOk = false;
      }
    }
    _provider.loadCurrentFolder();
    _provider.exitSelectionMode();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(allOk ? 'Excluído' : 'Erro ao excluir alguns itens')),
    );
  }

  Future<bool> _deleteRecursive(FileSystemEntity entity) async {
    if (await entity.exists()) {
      if (entity is Directory) {
        final children = entity.listSync();
        for (final child in children) {
          await _deleteRecursive(child);
        }
      }
      try {
        await entity.delete(recursive: true);
        return true;
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  void _showDetailsDialog(FileItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${item.isDirectory ? "Pasta" : "Arquivo"}'),
            Text('Tamanho: ${item.displaySize}'),
            Text('Caminho: ${item.path}'),
            Text('Modificado: ${item.lastModified.toLocal().toString().split('.').first}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _openFile(FileItem item) {
    // Implementar abertura de arquivo com open_file_plus se necessário
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abrir arquivo - implementar com open_file_plus')),
    );
  }

  void _shareFile(FileItem item) {
    // Implementar compartilhamento
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compartilhar - implementar com share_plus')),
    );
  }

  void _shareSelected(FileManagerProvider provider) {
    if (provider.selectedPaths.isNotEmpty) {
      _shareFile(FileItem.fromFile(File(provider.selectedPaths.first)));
    }
  }

  void _startCompress(FileManagerProvider provider) {
    final items = provider.selectedPaths
        .map((p) => File(p))
        .where((f) => f.existsSync())
        .toList();

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos um item')),
      );
      return;
    }

    final controller = TextEditingController(text: 'compactado.zip');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compactar (ZIP)'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'nome_do_arquivo.zip'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _compressFiles(items, controller.text.trim());
            },
            child: const Text('Compactar'),
          ),
        ],
      ),
    );
  }

  Future<void> _compressFiles(List<File> files, String zipName) async {
    if (zipName.isEmpty) return;
    final zipFile = File(p.join(_provider.currentDir.path,
        zipName.toLowerCase().endsWith('.zip') ? zipName : '$zipName.zip'));

    final progressDialog = showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Compactando...'),
          ],
        ),
      ),
    );

    final ok = await ZipHelper.compress(files, zipFile);
    if (context.mounted) {
      Navigator.pop(context); // close progress
      if (ok) {
        _provider.loadCurrentFolder();
        _provider.exitSelectionMode();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ZIP criado: ${zipFile.path.split('/').last}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao compactar')),
        );
      }
    }
  }

  void _startDecompress(FileManagerProvider provider) {
    final zips = _provider.currentDir.listSync()
        .where((e) => e.path.toLowerCase().endsWith('.zip'))
        .map((e) => File(e.path))
        .toList();

    if (zips.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum arquivo ZIP nesta pasta')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: zips.map((zip) => ListTile(
            title: Text(zip.path.split('/').last),
            onTap: () {
              Navigator.pop(context);
              _decompressFile(zip);
            },
          )).toList(),
        ),
      ),
    );
  }

  Future<void> _decompressFile(File zipFile) async {
    final progressDialog = showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Extraindo...'),
          ],
        ),
      ),
    );

    final ok = await ZipHelper.decompress(zipFile, _provider.currentDir);
    if (context.mounted) {
      Navigator.pop(context);
      if (ok) {
        _provider.loadCurrentFolder();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Extraído com sucesso')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao extrair')),
        );
      }
    }
  }

  void _showSearchDialog(FileManagerProvider provider) {
    final controller = TextEditingController(text: provider.searchQuery ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Buscar arquivos e pastas'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              provider.setSearchQuery(null);
              Navigator.pop(context);
            },
            child: const Text('Limpar'),
          ),
          FilledButton(
            onPressed: () {
              final q = controller.text.trim();
              provider.setSearchQuery(q.isEmpty ? null : q);
              Navigator.pop(context);
            },
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }
}