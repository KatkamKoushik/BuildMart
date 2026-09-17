import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../../../core/constants/app_colors.dart';
import '../data/product_model.dart';
import '../data/product_repository.dart';
import '../../categories/data/category_repository.dart';
import '../../cart/data/cart_repository.dart';
import '../../profile/data/user_repository.dart';
import '../../../core/utils/category_translator.dart';
import '../../../l10n/app_localizations.dart';
import '../../brands/data/brand_repository.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  final String? query;
  final String? categoryId;
  final String? brandId;
  const ProductsScreen({super.key, this.query, this.categoryId, this.brandId});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  String? _selectedCategoryId;
  String _sortBy = 'default';
  bool _inStockOnly = false;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryId;
  }

  @override
  void didUpdateWidget(ProductsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryId != widget.categoryId) {
      _selectedCategoryId = widget.categoryId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final brandsAsync = ref.watch(brandsProvider);
    
    final AsyncValue<List<ProductModel>> productsAsync;
    if (widget.brandId != null) {
      productsAsync = ref.watch(productsByBrandProvider(widget.brandId!));
    } else {
      productsAsync = _selectedCategoryId == null 
          ? ref.watch(featuredProductsProvider)
          : ref.watch(productsByCategoryProvider(_selectedCategoryId!));
    }

    String appBarTitle = widget.query ?? AppLocalizations.of(context)!.products;
    if (widget.brandId != null && brandsAsync.hasValue) {
      try {
        final brand = brandsAsync.value!.firstWhere((b) => b.id == widget.brandId);
        if (brand.name.isNotEmpty) {
          appBarTitle = brand.name;
        }
      } catch (e) {
        // Brand not found yet
      }
    } else if (widget.categoryId != null && categoriesAsync.hasValue) {
      try {
        final category = categoriesAsync.value!.firstWhere((c) => c.id == widget.categoryId);
        if (category.name.isNotEmpty) {
          appBarTitle = translateCategory(context, category.name);
        }
      } catch (e) {
        // Category not found yet
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          Consumer(
            builder: (context, ref, child) {
              final userAsync = ref.watch(userProvider);
              final userId = userAsync.value?.id;
              num itemCount = 0;
              if (userId != null) {
                final cartAsync = ref.watch(cartStreamProvider(userId));
                if (cartAsync.value != null) {
                  for (var item in cartAsync.value!) {
                    itemCount += item.quantity;
                  }
                }
              }

              return IconButton(
                icon: itemCount > 0
                    ? Badge(
                        label: Text(itemCount.toInt().toString()),
                        backgroundColor: AppColors.error,
                        child: const Icon(Icons.shopping_cart_outlined),
                      )
                    : const Icon(Icons.shopping_cart_outlined),
                onPressed: () => context.push('/cart'),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          if (widget.brandId == null && widget.categoryId == null)
            SizedBox(
              height: 60,
              child: categoriesAsync.when(
                data: (categories) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: categories.length + 1, // +1 for "All"
                    itemBuilder: (context, index) {
                    final isAll = index == 0;
                    final category = isAll ? null : categories[index - 1];
                    final isSelected = _selectedCategoryId == category?.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(isAll ? AppLocalizations.of(context)!.all : translateCategory(context, category!.name)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (isAll) {
                              _selectedCategoryId = null;
                            } else {
                              _selectedCategoryId = selected ? category?.id : null;
                            }
                          });
                        },
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.primary,
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => const SizedBox(),
            ),
          ),
          // Product Grid
          Expanded(
            child: productsAsync.when(
              data: (allProducts) {
                var products = widget.query != null && widget.query!.isNotEmpty
                    ? allProducts.where((p) {
                        final q = widget.query!.trim().toLowerCase();
                        if (p.brand.toLowerCase().contains(q)) {
                          return true;
                        }
                        final regex = RegExp(r'\b' + RegExp.escape(q), caseSensitive: false);
                        return regex.hasMatch(p.title);
                      }).toList()
                    : allProducts.toList();

                if (_inStockOnly) {
                  products = products.where((p) => p.inStock).toList();
                }

                if (_sortBy == 'price_asc') {
                  products.sort((a, b) => a.price.compareTo(b.price));
                } else if (_sortBy == 'price_desc') {
                  products.sort((a, b) => b.price.compareTo(a.price));
                } else if (_sortBy == 'rating') {
                  products.sort((a, b) => b.rating.compareTo(a.rating));
                }

                if (products.isEmpty) {
                  return Center(child: Text(AppLocalizations.of(context)!.noProductsFound));
                }
                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.55,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = products[index];
                            return ProductCard(
                              product: product,
                              onTap: () => context.push('/product-details/${product.id}'),
                            );
                          },
                          childCount: products.length,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 80)), // Space for FAB
                  ],
                );
              },
              loading: () => CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.55,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => const ProductCardShimmer(),
                        childCount: 4,
                      ),
                    ),
                  ),
                ],
              ),
              error: (error, stack) => Center(child: Text('Error loading products: $error')),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface, // Dark pill button
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFloatingAction(context, Icons.sort, AppLocalizations.of(context)!.sort, _showSortModal),
            Container(width: 1, height: 24, color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3)),
            _buildFloatingAction(context, Icons.filter_alt_outlined, AppLocalizations.of(context)!.filter, _showFilterModal),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingAction(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.surface, size: 20),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.surface, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sort By', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildSortRadio(setModalState, 'default', 'Recommended'),
                  _buildSortRadio(setModalState, 'price_asc', 'Price: Low to High'),
                  _buildSortRadio(setModalState, 'price_desc', 'Price: High to Low'),
                  _buildSortRadio(setModalState, 'rating', 'Customer Rating'),
                ],
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildSortRadio(StateSetter setModalState, String value, String title) {
    return RadioListTile<String>(
      title: Text(title),
      value: value,
      groupValue: _sortBy,
      activeColor: AppColors.primary,
      onChanged: (val) {
        setModalState(() {
          _sortBy = val!;
        });
        setState(() {
          _sortBy = val!;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('In Stock Only'),
                    value: _inStockOnly,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      setModalState(() {
                        _inStockOnly = val;
                      });
                      setState(() {
                        _inStockOnly = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }
}
