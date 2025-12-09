import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../constants/api.dart';
import 'detail_product_page.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<dynamic> products = [];
  List<dynamic> filteredProducts = [];
  bool isLoading = true;
  String? selectedCabangId;
  
  final Map<String, String> cabangOptions = {
    'all': 'Semua Cabang',
    '691c3194e9aaf18a1379c316': 'Stone Crusher I (KLT01)',
    '691c308ee9aaf18a1379c30f': 'Stone Crusher II (KLT02)',
    '691c31b5e9aaf18a1379c318': 'Stone Crusher III (KLT03)',
  };

  @override
  void initState() {
    super.initState();
    selectedCabangId = 'all';
    fetchProducts();
  }

  Future<void> fetchProducts({String? cabangId}) async {
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Token tidak ditemukan. Silakan login.")),
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      final dio = Dio();
      
      String url = "${Api.baseUrl}/api/customer/product-showcase";
      if (cabangId != null && cabangId != 'all') {
        url += "?cabangId=$cabangId";
      }

      final response = await dio.get(
        url,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200 && response.data["success"] == true) {
        setState(() {
          products = response.data["data"] ?? [];
          filteredProducts = products;
        });
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = "Gagal memuat produk";
        
        if (e is DioException && e.response != null) {
          errorMsg = e.response?.data["message"] ?? errorMsg;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  String formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  Widget _buildFilterButton(String cabangId, String label) {
    final isSelected = selectedCabangId == cabangId;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCabangId = cabangId;
        });
        fetchProducts(cabangId: cabangId);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFBB00) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFFFFBB00) : Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        title: const Text("Produk Kami"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: const Color(0xFFEEEEEE),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterButton('all', 'Semua'),
                  const SizedBox(width: 8),
                  _buildFilterButton('691c3194e9aaf18a1379c316', 'Cabang 1'),
                  const SizedBox(width: 8),
                  _buildFilterButton('691c308ee9aaf18a1379c30f', 'Cabang 2'),
                  const SizedBox(width: 8),
                  _buildFilterButton('691c31b5e9aaf18a1379c318', 'Cabang 3'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: isLoading
                ? const Center(child: CircularProgressIndicator(
                    color: Color(0xFFFFBB00),
                  ))
                : filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.package,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada produk',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: const Color(0xFFFFBB00),
                        onRefresh: () => fetchProducts(cabangId: selectedCabangId),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            final cabang = product['cabangId'];
                            
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailProductPage(
                                      productId: product['_id'],
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(28),
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFBB00).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            LucideIcons.package,
                                            color: Color(0xFFFFBB00),
                                            size: 32,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product['nama'] ?? '-',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFFBB00).withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  product['kodeSku'] ?? '-',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFFCC9900),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      product['deskripsi'] ?? '-',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Divider(),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          LucideIcons.mapPin,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            cabang['namaCabang'] ?? '-',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          LucideIcons.tag,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          cabang['kodeCabang'] ?? '-',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Harga',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              formatCurrency(product['hargaJual'] ?? 0),
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFFFFBB00),
                                              ),
                                            ),
                                            Text(
                                              'per ${product['satuan'] ?? '-'}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: product['aktif'] == true
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                product['aktif'] == true
                                                    ? LucideIcons.checkCircle
                                                    : LucideIcons.xCircle,
                                                size: 14,
                                                color: product['aktif'] == true
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                product['aktif'] == true
                                                    ? 'Tersedia'
                                                    : 'Tidak Aktif',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: product['aktif'] == true
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: product['aktif'] == true
                                            ? () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => DetailProductPage(
                                                      productId: product['_id'],
                                                    ),
                                                  ),
                                                );
                                              }
                                            : null,
                                        icon: const Icon(LucideIcons.shoppingCart, size: 18),
                                        label: const Text(
                                          'Pesan Sekarang',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFFFBB00),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.all(20),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(9999),
                                          ),
                                          elevation: 0,
                                          disabledBackgroundColor: Colors.grey[300],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            );
                          },
                        ),
                      ),
    );
  }
}