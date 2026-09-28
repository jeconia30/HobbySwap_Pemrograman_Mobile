import 'package:flutter/material.dart';
import '../models.dart';
import '../widgets/common.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Katalog Barang',
    'Pinjaman Saya',
    'Barang Saya',
    'Profil Pengguna',
  ];

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    final pages = [
      const _CatalogTab(),
      const _MyLoansTab(),
      const _MyItemsTab(),
      const _ProfileTab(),
    ];

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: const [
                    Icon(Icons.swap_horizontal_circle, size: 36, color: Color(0xFF0F6E56)),
                    SizedBox(height: 4),
                    Text('HobbySwap', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.grid_view_outlined),
                  selectedIcon: Icon(Icons.grid_view),
                  label: Text('Katalog'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.assignment_outlined),
                  selectedIcon: Icon(Icons.assignment),
                  label: Text('Pinjaman'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon: Icon(Icons.inventory_2),
                  label: Text('Barang Saya'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: Text('Profil'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: Scaffold(
                appBar: AppBar(
                  title: Text(_titles[_selectedIndex]),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Muat Ulang',
                      onPressed: () => store.fetchData(forceReload: true),
                    ),
                  ],
                ),
                body: pages[_selectedIndex],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat Ulang',
            onPressed: () => store.fetchData(forceReload: true),
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (idx) => setState(() => _selectedIndex = idx),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0F6E56),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: 'Katalog',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Pinjaman',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Barang Saya',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _CatalogTab extends StatelessWidget {
  const _CatalogTab();

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);

    if (store.isLoading && store.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (store.errorMessage != null && store.items.isEmpty) {
      return ErrorStateWidget(
        message: store.errorMessage!,
        onRetry: () => store.fetchData(forceReload: true),
      );
    }

    final items = store.filteredItems;

    return RefreshIndicator(
      onRefresh: () => store.fetchData(forceReload: true),
      child: Column(
        children: [
          // Search & Filter header
          Container(
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => store.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Cari barang, lokasi, atau hobi...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: store.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => store.setSearchQuery(''),
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Semua Kategori'),
                        selected: store.selectedCategoryId == null,
                        onSelected: (_) => store.setSelectedCategory(null),
                      ),
                      const SizedBox(width: 6),
                      ...store.categories.map((cat) {
                        final isSelected = store.selectedCategoryId == cat.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: FilterChip(
                            label: Text(cat.name),
                            selected: isSelected,
                            onSelected: (_) => store.setSelectedCategory(isSelected ? null : cat.id),
                          ),
                        );
                      }),
                      const SizedBox(width: 8),
                      FilterChip(
                        avatar: Icon(
                          store.onlyAvailable ? Icons.check_box : Icons.check_box_outline_blank,
                          size: 16,
                        ),
                        label: const Text('Hanya Tersedia'),
                        selected: store.onlyAvailable,
                        onSelected: (val) => store.setOnlyAvailable(val),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Items Grid
          Expanded(
            child: items.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.search_off,
                    title: 'Tidak Ada Barang Ditemukan',
                    message: 'Coba ubah kata kunci pencarian atau reset filter kategori.',
                    actionLabel: 'Reset Filter',
                    onAction: () => store.resetFilters(),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      int crossAxisCount = 2;
                      if (width >= 1200) {
                        crossAxisCount = 5;
                      } else if (width >= 800) {
                        crossAxisCount = 4;
                      } else if (width >= 500) {
                        crossAxisCount = 3;
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: items.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.78,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return ItemCard(
                            item: item,
                            onTap: () {
                              Navigator.pushNamed(context, '/item/${item.id}');
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _MyLoansTab extends StatefulWidget {
  const _MyLoansTab();

  @override
  State<_MyLoansTab> createState() => _MyLoansTabState();
}

class _MyLoansTabState extends State<_MyLoansTab> {
  LoanStatus? _selectedStatusFilter;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);

    if (store.isLoading && store.loans.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (store.errorMessage != null && store.loans.isEmpty) {
      return ErrorStateWidget(
        message: store.errorMessage!,
        onRetry: () => store.fetchData(forceReload: true),
      );
    }

    final allLoans = store.myLoans;
    final filteredLoans = _selectedStatusFilter == null
        ? allLoans
        : allLoans.where((l) => l.status == _selectedStatusFilter).toList();

    return Column(
      children: [
        // Summary cards
        Container(
          padding: const EdgeInsets.all(12),
          color: Theme.of(context).cardColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: Text('Semua (${allLoans.length})'),
                      selected: _selectedStatusFilter == null,
                      onSelected: (_) => setState(() => _selectedStatusFilter = null),
                    ),
                    const SizedBox(width: 8),
                    ...LoanStatus.values.map((st) {
                      final count = store.countLoansByStatus(st);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text('${st.label} ($count)'),
                          selected: _selectedStatusFilter == st,
                          onSelected: (_) => setState(() => _selectedStatusFilter = st),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: filteredLoans.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.assignment_outlined,
                  title: 'Belum Ada Pengajuan',
                  message: _selectedStatusFilter == null
                      ? 'Anda belum pernah meminjam barang hobi. Jelajahi katalog dan ajukan peminjaman!'
                      : 'Tidak ada pengajuan dengan status ${_selectedStatusFilter!.label}.',
                  actionLabel: _selectedStatusFilter != null ? 'Tampilkan Semua' : null,
                  onAction: _selectedStatusFilter != null
                      ? () => setState(() => _selectedStatusFilter = null)
                      : null,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredLoans.length,
                  separatorBuilder: (context, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final loan = filteredLoans[index];
                    final item = store.getItemById(loan.itemId);

                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade200,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: item != null
                              ? Image.asset(
                                  item.imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
                                )
                              : const Icon(Icons.inventory_2),
                        ),
                        title: Text(
                          item?.name ?? 'Barang #${loan.itemId}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Peminjam: ${loan.borrowerName} (${loan.borrowerPhone})',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Tgl: ${loan.startDate.day}/${loan.startDate.month}/${loan.startDate.year} - ${loan.endDate.day}/${loan.endDate.month}/${loan.endDate.year}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: StatusBadge(status: loan.status),
                        onTap: () {
                          Navigator.pushNamed(context, '/loan/${loan.id}');
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _MyItemsTab extends StatelessWidget {
  const _MyItemsTab();

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);

    if (store.isLoading && store.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (store.errorMessage != null && store.items.isEmpty) {
      return ErrorStateWidget(
        message: store.errorMessage!,
        onRetry: () => store.fetchData(forceReload: true),
      );
    }

    final myItems = store.myItems;

    return Scaffold(
      body: myItems.isEmpty
          ? EmptyStateWidget(
              icon: Icons.inventory_2_outlined,
              title: 'Belum Ada Barang Milik Anda',
              message: 'Anda belum mendaftarkan barang hobi yang dapat dipinjamkan.',
              actionLabel: 'Tambah Barang Sekarang',
              onAction: () => Navigator.pushNamed(context, '/items/new'),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: myItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = myItems[index];

                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade200,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        item.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                      ),
                    ),
                    title: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(item.location, style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        AvailabilityBadge(isAvailable: item.isAvailable),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          tooltip: 'Edit Barang',
                          onPressed: () {
                            Navigator.pushNamed(context, '/item/${item.id}/edit');
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Hapus Barang',
                          onPressed: () async {
                            final confirm = await showConfirmDialog(
                              context: context,
                              title: 'Hapus Barang',
                              content: 'Apakah Anda yakin ingin menghapus "${item.name}" dari katalog?',
                            );
                            if (confirm == true) {
                              final success = await store.deleteItem(item.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(success
                                        ? 'Barang berhasil dihapus'
                                        : 'Gagal menghapus barang: ${store.errorMessage}'),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/item/${item.id}');
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/items/new'),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Barang'),
        backgroundColor: const Color(0xFF0F6E56),
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final profile = store.userProfile;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // User Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFF0F6E56),
                    child: Icon(Icons.person, size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(profile.email, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('WA: ${profile.phone}', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Chip(
                    avatar: const Icon(Icons.school, size: 16),
                    label: Text(profile.campus),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profile.bio,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/profile/edit');
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profil & Pengaturan'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Settings Card
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Mode Gelap (Dark Mode)'),
                  subtitle: const Text('Ubah tema aplikasi menjadi gelap'),
                  secondary: const Icon(Icons.dark_mode_outlined),
                  value: store.darkMode,
                  onChanged: (_) => store.toggleDarkMode(),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Simulasi Gagal Jaringan'),
                  subtitle: const Text('Aktifkan untuk menguji penanganan error async/network'),
                  secondary: const Icon(Icons.signal_wifi_off_outlined, color: Colors.amber),
                  value: store.failureSimulated,
                  onChanged: (_) => store.toggleFailureSimulation(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
