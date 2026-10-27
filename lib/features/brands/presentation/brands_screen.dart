import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/brand_card.dart';
import '../../../core/constants/app_colors.dart';

import '../data/brand_repository.dart';

class BrandsScreen extends ConsumerStatefulWidget {
  const BrandsScreen({super.key});

  @override
  ConsumerState<BrandsScreen> createState() => _BrandsScreenState();
}

class _BrandsScreenState extends ConsumerState<BrandsScreen> {
  int _selectedFilterIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Brands'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search brands...',
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip(0, 'All Brands'),
                _buildFilterChip(1, 'Cement'),
                _buildFilterChip(2, 'Steel'),
                _buildFilterChip(3, 'Paints'),
                _buildFilterChip(4, 'Plumbing'),
                _buildFilterChip(5, 'Doors & Glass'),
                _buildFilterChip(6, 'Wood & Boards'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Grid
          Expanded(
            child: ref.watch(brandsProvider).when(
                  data: (brands) {
                    final filteredBrands = brands.where((brand) {
                      final query = _searchQuery.trim().toLowerCase();
                      if (query.isNotEmpty &&
                          !brand.name.toLowerCase().contains(query) &&
                          !brand.id.toLowerCase().contains(query)) {
                        return false;
                      }

                      if (_selectedFilterIndex != 0) {
                        final name = brand.name.toLowerCase();
                        final id = brand.id.toLowerCase();
                        final isCement = [
                          'acc',
                          'kcp',
                          'penna',
                          'ramco',
                          'ultratech',
                          'cement',
                          'ambuja',
                          'priya'
                        ].any((k) => name.contains(k) || id.contains(k));
                        final isSteel = [
                          'jsw',
                          'tata',
                          'vizag',
                          'sail',
                          'steel'
                        ].any((k) => name.contains(k) || id.contains(k));
                        final isPaint = [
                          'asian',
                          'berger',
                          'nippon',
                          'nerolac',
                          'paint'
                        ].any((k) => name.contains(k) || id.contains(k));
                        final isPlumbing = [
                          'jaquar',
                          'astral',
                          'supreme',
                          'plumb',
                          'pipe'
                        ].any((k) => name.contains(k) || id.contains(k));
                        final isDoors = [
                          'century',
                          'fenesta',
                          'saint',
                          'door',
                          'glass'
                        ].any((k) => name.contains(k) || id.contains(k));
                        final isWood = ['greenply', 'wood', 'board', 'ply']
                            .any((k) => name.contains(k) || id.contains(k));

                        if (_selectedFilterIndex == 1 && !isCement)
                          return false;
                        if (_selectedFilterIndex == 2 && !isSteel) return false;
                        if (_selectedFilterIndex == 3 && !isPaint) return false;
                        if (_selectedFilterIndex == 4 && !isPlumbing)
                          return false;
                        if (_selectedFilterIndex == 5 && !isDoors) return false;
                        if (_selectedFilterIndex == 6 && !isWood) return false;
                      }
                      return true;
                    }).toList();

                    if (filteredBrands.isEmpty) {
                      return const Center(child: Text('No brands found.'));
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: filteredBrands.length,
                      itemBuilder: (context, index) {
                        final brand = filteredBrands[index];
                        return BrandCard(
                          name: brand.name,
                          logoUrl: brand.logoUrl,
                          onTap: () =>
                              context.push('/products?brandId=${brand.id}'),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _selectedFilterIndex == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilterIndex = index;
          });
        },
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.background,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.accent : AppColors.text,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.border),
        ),
      ),
    );
  }
}
