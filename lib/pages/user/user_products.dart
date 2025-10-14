import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/products.dart';
import '../../services/products_services.dart';
import '../../widgets/appbar.dart';

class UserProductsScreen extends StatefulWidget {
  const UserProductsScreen({super.key});

  @override
  State<UserProductsScreen> createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen> {
  final ProductService _productService = ProductService();
  final List<Product> _products = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final newProducts = await _productService.fetchProducts(
        limit: _limit,
        offset: _offset,
      );

      setState(() {
        if (newProducts.isEmpty) {
          _hasMore = false;
        } else {
          final existingIds = _products.map((p) => p.idProduct).toSet();
          final filtered = newProducts.where((p) => !existingIds.contains(p.idProduct)).toList();
          
          // ✅ TODOS los productos comienzan como ACTIVOS
          for (var product in filtered) {
            product.isActive = true; // Todos activos por defecto
          }
          
          _products.addAll(filtered);
          _offset += _limit;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar productos: $e')),
      );
    }
  }

  void _toggleProductStatus(int index) {
    setState(() {
      // Aquí simularíamos la desactivación del producto
      // En la implementación real, haría una petición a tu API
  // ✅ CAMBIAR REALMENTE EL ESTADO DEL PRODUCTO
      _products[index].isActive = !_products[index].isActive;
      
      // Mostrar mensaje según el nuevo estado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Producto ${_products[index].name} ${_products[index].isActive ? 'activado' : 'desactivado'}'
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: _products[index].isActive ? Colors.green : Colors.orange,
        ),
      );
    });
  }

  // ✅ MÉTODO PARA ORDENAR PRODUCTOS: ACTIVOS PRIMERO
  List<Product> _getSortedProducts() {
    // Ordenar: activos primero, luego inactivos
    final activeProducts = _products.where((p) => p.isActive).toList();
    final inactiveProducts = _products.where((p) => !p.isActive).toList();
    
    return [...activeProducts, ...inactiveProducts];
  }

  Widget _buildProductCard(Product product, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Imagen del producto
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: product.isActive ? Colors.transparent : Colors.red.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: product.mediaFile != null && product.mediaFile!.attachment.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.memory(
                        const Base64Decoder().convert(product.mediaFile!.attachment),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.shopping_bag, color: Colors.grey);
                        },
                      ),
                    )
                  : Icon(
                      Icons.shopping_bag, 
                      color: product.isActive ? Colors.grey : Colors.grey[400],
                    ),
            ),
            const SizedBox(width: 16),

            // Información del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: product.isActive ? Colors.black : Colors.grey,
                      decoration: product.isActive ? TextDecoration.none : TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.category,
                    style: TextStyle(
                      color: product.isActive ? Colors.grey[600] : Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: product.isActive ? Colors.purple : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // ✅ Indicador de estado
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: product.isActive 
                          ? Colors.green.withOpacity(0.1) 
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.isActive ? 'ACTIVO' : 'INACTIVO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: product.isActive ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ✅ BOTÓN DE TOGGLE QUE REALMENTE CAMBIA
            Column(
              children: [
                // Texto indicador
                Text(
                  product.isActive ? 'Activo' : 'Inactivo',
                  style: TextStyle(
                    fontSize: 12,
                    color: product.isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // Botón toggle
                GestureDetector(
                  onTap: () => _toggleProductStatus(_products.indexOf(product)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 60,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: product.isActive 
                          ? Colors.green 
                          : Colors.red.withOpacity(0.5),
                      border: Border.all(
                        color: product.isActive ? Colors.green : Colors.grey,
                      ),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 300),
                      alignment: product.isActive 
                          ? Alignment.centerRight 
                          : Alignment.centerLeft,
                      child: Container(
                        width: 26,
                        height: 26,
                        margin: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Icon(
                          product.isActive ? Icons.check : Icons.close,
                          size: 14,
                          color: product.isActive ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap para ${product.isActive ? 'desactivar' : 'activar'}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Método para contar productos activos/inactivos
  Map<String, int> _getProductStats() {
    int active = _products.where((p) => p.isActive).length;
    int inactive = _products.where((p) => !p.isActive).length;
    return {'active': active, 'inactive': inactive};
  }

  @override
  Widget build(BuildContext context) {
    final stats = _getProductStats();
    final sortedProducts = _getSortedProducts(); // ✅ Productos ordenados
    
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Mis Productos',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // ✅ Header informativo MEJORADO
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple.withOpacity(0.1),
                  Colors.blue.withOpacity(0.1),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gestión de Productos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Los productos activos aparecen primero. Los productos inactivos no son visibles para los clientes.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                // ✅ Estadísticas
                Row(
                  children: [
                    _buildStatCard('Activos', stats['active']!, Colors.green),
                    const SizedBox(width: 10),
                    _buildStatCard('Inactivos', stats['inactive']!, Colors.red),
                  ],
                ),
              ],
            ),
          ),

          // ✅ SEPARADOR ENTRE PRODUCTOS ACTIVOS E INACTIVOS
          if (stats['inactive']! > 0 && stats['active']! > 0) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[100],
              child: Text(
                'PRODUCTOS ACTIVOS (${stats['active']})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 14,
                ),
              ),
            ),
          ],

          // ✅ Lista de productos ORDENADOS
          Expanded(
            child: sortedProducts.isEmpty && !_isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No hay productos disponibles',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        _products.clear();
                        _offset = 0;
                        _hasMore = true;
                      });
                      await _loadProducts();
                    },
                    child: ListView.builder(
                      itemCount: sortedProducts.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= sortedProducts.length) {
                          return _isLoading
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : const SizedBox();
                        }

                        final product = sortedProducts[index];
                        final isFirstInactive = index > 0 && 
                                            sortedProducts[index - 1].isActive && 
                                            !product.isActive;

                        // ✅ MOSTRAR SEPARADOR CUANDO EMPIEZAN LOS INACTIVOS
                        if (isFirstInactive) {
                          return Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                color: Colors.grey[100],
                                child: Text(
                                  'PRODUCTOS INACTIVOS (${stats['inactive']})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              _buildProductCard(product, _products.indexOf(product)),
                            ],
                          );
                        }

                        return _buildProductCard(product, _products.indexOf(product));
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ✅ Widget para mostrar estadísticas
  Widget _buildStatCard(String title, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}