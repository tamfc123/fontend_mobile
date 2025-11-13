import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentStoreScreen extends StatefulWidget {
  const StudentStoreScreen({super.key});

  @override
  State<StudentStoreScreen> createState() => _StudentStoreScreenState();
}

class _StudentStoreScreenState extends State<StudentStoreScreen> {
  String _selectedCategory = 'all';

  // Mock user coins
  final int _userCoins = 8500;

  // Mock store items
  final List<Map<String, dynamic>> _storeItems = [
    {
      'id': 1,
      'name': 'Bút bi cao cấp',
      'description': 'Bút bi mực gel, viết êm, màu xanh',
      'price': 150,
      'category': 'writing',
      'image': 'assets/images/butbi.png',
      'stock': 45,
      'discount': 0,
    },
    {
      'id': 2,
      'name': 'Bút chì 2B',
      'description': 'Set 12 cây bút chì 2B chất lượng cao',
      'price': 200,
      'category': 'writing',
      'image': 'assets/images/butbi.png',
      'stock': 30,
      'discount': 10,
    },
    {
      'id': 3,
      'name': 'Sách ngữ pháp tiếng Anh',
      'description': 'Sách ngữ pháp từ cơ bản đến nâng cao',
      'price': 500,
      'category': 'books',
      'image': 'assets/images/butbi.png',
      'stock': 20,
      'discount': 15,
    },
    {
      'id': 4,
      'name': 'Vở ghi chép A5',
      'description': 'Vở 200 trang, giấy dày, kẻ ngang',
      'price': 120,
      'category': 'notebooks',
      'image': 'assets/images/butbi.png',
      'stock': 60,
      'discount': 0,
    },
    {
      'id': 5,
      'name': 'Bộ bút màu 24 màu',
      'description': 'Bút màu chuyên nghiệp cho vẽ và tô',
      'price': 350,
      'category': 'writing',
      'image': 'assets/images/butbi.png',
      'stock': 25,
      'discount': 20,
    },
    {
      'id': 6,
      'name': 'Từ điển Anh-Việt',
      'description': 'Từ điển Oxford, hơn 50,000 từ',
      'price': 800,
      'category': 'books',
      'image': 'assets/images/butbi.png',
      'stock': 15,
      'discount': 0,
    },
    {
      'id': 7,
      'name': 'Tẩy trắng cao su',
      'description': 'Tẩy không để lại vết bẩn',
      'price': 50,
      'category': 'accessories',
      'image': 'assets/images/butbi.png',
      'stock': 100,
      'discount': 0,
    },
    {
      'id': 8,
      'name': 'Bút dạ quang',
      'description': 'Set 5 màu bút highlight',
      'price': 180,
      'category': 'writing',
      'image': 'assets/images/butbi.png',
      'stock': 40,
      'discount': 5,
    },
    {
      'id': 9,
      'name': 'Sách luyện IELTS',
      'description': 'Cambridge IELTS 17 - Official',
      'price': 600,
      'category': 'books',
      'image': 'assets/images/butbi.png',
      'stock': 18,
      'discount': 10,
    },
    {
      'id': 10,
      'name': 'Bìa đựng hồ sơ',
      'description': 'Bìa nhựa trong, đựng tài liệu A4',
      'price': 80,
      'category': 'accessories',
      'image': 'assets/images/butbi.png',
      'stock': 50,
      'discount': 0,
    },
    {
      'id': 11,
      'name': 'Thước kẻ 30cm',
      'description': 'Thước nhựa trong, có chia vạch rõ',
      'price': 40,
      'category': 'accessories',
      'image': 'assets/images/butbi.png',
      'stock': 70,
      'discount': 0,
    },
    {
      'id': 12,
      'name': 'Sticky notes 5 màu',
      'description': 'Giấy note dán, 5 màu pastel',
      'price': 100,
      'category': 'notebooks',
      'image': 'assets/images/butbi.png',
      'stock': 55,
      'discount': 15,
    },
  ];

  List<Map<String, dynamic>> get _filteredItems {
    if (_selectedCategory == 'all') return _storeItems;
    return _storeItems
        .where((item) => item['category'] == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      // App Bar
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Cửa hàng",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          // Cart icon with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_rounded),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Giỏ hàng đang được phát triển'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          // Coins balance header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade600, Colors.blue.shade400],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade600.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Số dư của bạn',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${NumberFormat('#,###').format(_userCoins)} xu',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Chức năng nạp xu đang phát triển'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('Nạp'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue.shade700,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Category filters
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip(
                    icon: Icons.grid_view_rounded,
                    label: 'Tất cả',
                    value: 'all',
                    count: _storeItems.length,
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryChip(
                    icon: Icons.edit_rounded,
                    label: 'Dụng cụ viết',
                    value: 'writing',
                    count:
                        _storeItems
                            .where((item) => item['category'] == 'writing')
                            .length,
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryChip(
                    icon: Icons.menu_book_rounded,
                    label: 'Sách',
                    value: 'books',
                    count:
                        _storeItems
                            .where((item) => item['category'] == 'books')
                            .length,
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryChip(
                    icon: Icons.book_rounded,
                    label: 'Vở',
                    value: 'notebooks',
                    count:
                        _storeItems
                            .where((item) => item['category'] == 'notebooks')
                            .length,
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryChip(
                    icon: Icons.inventory_2_rounded,
                    label: 'Phụ kiện',
                    value: 'accessories',
                    count:
                        _storeItems
                            .where((item) => item['category'] == 'accessories')
                            .length,
                  ),
                ],
              ),
            ),
          ),

          // Items count
          if (_filteredItems.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                '${_filteredItems.length} sản phẩm',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ),

          // Items grid
          Expanded(
            child:
                _filteredItems.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không có sản phẩm',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                    : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.65,
                          ),
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return _buildStoreItem(item);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  // Category chip widget
  Widget _buildCategoryChip({
    required IconData icon,
    required String label,
    required String value,
    required int count,
  }) {
    final isSelected = _selectedCategory == value;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : Colors.blue.shade600,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.blue.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? Colors.white.withOpacity(0.3)
                      : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.blue.shade600,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = value;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: Colors.blue.shade600,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? Colors.blue.shade600 : Colors.blue.shade200,
        width: 1.5,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  // Store item card widget
  Widget _buildStoreItem(Map<String, dynamic> item) {
    final hasDiscount = item['discount'] > 0;
    final originalPrice = item['price'] as int;
    final discountedPrice =
        hasDiscount
            ? (originalPrice * (1 - item['discount'] / 100)).round()
            : originalPrice;
    final canAfford = _userCoins >= discountedPrice;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showItemDetails(item),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.blue.shade100],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: Image.asset(
                        item['image'], // URL ảnh thật
                        fit: BoxFit.fill,
                        width: double.infinity,
                      ),
                    ),
                    // Discount badge
                    if (hasDiscount)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '-${item['discount']}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    // Stock badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inventory_2,
                              size: 12,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${item['stock']}',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Info section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['description'],
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      // Price + button row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (hasDiscount)
                                  Text(
                                    '${NumberFormat('#,###').format(originalPrice)} xu',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.monetization_on,
                                      size: 16,
                                      color: Colors.amber.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        NumberFormat(
                                          '#,###',
                                        ).format(discountedPrice),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber.shade700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  canAfford
                                      ? Colors.blue.shade600
                                      : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.shopping_cart_rounded,
                              color:
                                  canAfford
                                      ? Colors.white
                                      : Colors.grey.shade500,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show item details bottom sheet
  void _showItemDetails(Map<String, dynamic> item) {
    final hasDiscount = item['discount'] > 0;
    final originalPrice = item['price'] as int;
    final discountedPrice =
        hasDiscount
            ? (originalPrice * (1 - item['discount'] / 100)).round()
            : originalPrice;
    final canAfford = _userCoins >= discountedPrice;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Item header
                Row(
                  children: [
                    Container(
                      width: 100, // hoặc tuỳ ý
                      height: 100,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade50, Colors.blue.shade100],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: Image.asset(
                          item['image'],
                          fit: BoxFit.fill,
                          //width: double.infinity,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.inventory_2,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Còn ${item['stock']} sản phẩm',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Description
                Text(
                  'Mô tả',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                // Price and buy section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Giá',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          if (hasDiscount)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Giảm ${item['discount']}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (hasDiscount) ...[
                            Text(
                              '${NumberFormat('#,###').format(originalPrice)} xu',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Icon(
                            Icons.monetization_on,
                            size: 24,
                            color: Colors.amber.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${NumberFormat('#,###').format(discountedPrice)} xu',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close_rounded),
                        label: const Text('Đóng'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed:
                            canAfford
                                ? () {
                                  Navigator.pop(context);
                                  _purchaseItem(item, discountedPrice);
                                }
                                : null,
                        icon: const Icon(Icons.shopping_cart_rounded),
                        label: Text(canAfford ? 'Mua ngay' : 'Không đủ xu'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade500,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
    );
  }

  // Purchase item (mock)
  void _purchaseItem(Map<String, dynamic> item, int price) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text('Mua thành công!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bạn đã mua "${item['name']}" với giá $price xu.'),
                const SizedBox(height: 12),
                Text(
                  'Số dư còn lại: ${NumberFormat('#,###').format(_userCoins - price)} xu',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(
                            Icons.shopping_bag_rounded,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Vật phẩm đã được thêm vào kho của bạn',
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Xem kho'),
              ),
            ],
          ),
    );
  }
}
