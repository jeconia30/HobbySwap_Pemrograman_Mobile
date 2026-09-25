import 'package:flutter/material.dart';

class HobbyItem {
  final String name;
  final String location;
  final String imagePath;
  final bool available;

  HobbyItem({
    required this.name,
    required this.location,
    required this.imagePath,
    required this.available,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;
  int _selectedCategory = 0;

  final List<String> _categories = ['Olahraga', 'Fotografi', 'Outdoor', 'Gaming'];

  final List<HobbyItem> _items = [
    HobbyItem(
      name: 'Sepatu lari 42',
      location: '1.2 km · Kampus A',
      imagePath: 'assets/items/sepatu.jpg',
      available: true,
    ),
    HobbyItem(
      name: 'Kamera mirrorless',
      location: '0.8 km · Kampus B',
      imagePath: 'assets/items/kamera.jpg',
      available: false,
    ),
    HobbyItem(
      name: 'Tenda dome 4 orang',
      location: '2.0 km · Kampus A',
      imagePath: 'assets/items/tenda.jpg',
      available: true,
    ),
    HobbyItem(
      name: 'Raket badminton',
      location: '0.5 km · Kampus C',
      imagePath: 'assets/items/raket.jpg',
      available: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                    _buildCategoryChips(),
                    const SizedBox(height: 16),
                    _buildItemGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: const Color(0xFF0F6E56),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            'HobbySwap',
            style: TextStyle(color: Color(0xFFE1F5EE), fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 0.3),
          ),
          Icon(Icons.notifications_none, color: Color(0xFFE1F5EE)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey.shade500, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Cari sepatu, kamera, tenda...',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = _selectedCategory == index;
          return ChoiceChip(
            label: Text(_categories[index]),
            selected: selected,
            onSelected: (_) => setState(() => _selectedCategory = index),
            selectedColor: const Color(0xFF085041),
            labelStyle: TextStyle(
              color: selected ? const Color(0xFFE1F5EE) : Colors.grey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.grey.shade300),
          );
        },
      ),
    );
  }

  Widget _buildItemGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final item = _items[index];
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  item.imagePath,
                  height: 80,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 80,
                    color: const Color(0xFF9FE1CB),
                    child: const Icon(Icons.image_not_supported_outlined, color: Color(0xFF04342C)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(item.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(item.location, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: item.available ? const Color(0xFFFAEEDA) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.available ? 'Tersedia' : 'Dipinjam',
                  style: TextStyle(
                    fontSize: 10,
                    color: item.available ? const Color(0xFF633806) : Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedNavIndex,
      onTap: (index) => setState(() => _selectedNavIndex = index),
      selectedItemColor: const Color(0xFF0F6E56),
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Cari'),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Ajukan'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
      ],
    );
  }
}