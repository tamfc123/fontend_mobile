import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Để format ngày tháng
import 'package:mobile/data/models/gift_model.dart';
import 'package:mobile/data/models/student_redemption_model.dart';
import 'package:mobile/services/auth/auth_service.dart';
import 'package:mobile/services/student/student_gift_service.dart';
// Đã xóa import StudentProfileService thừa
import 'package:mobile/shared_widgets/admin/common_empty_state.dart';
import 'package:provider/provider.dart';

class StudentGiftStoreScreen extends StatefulWidget {
  const StudentGiftStoreScreen({super.key});

  @override
  State<StudentGiftStoreScreen> createState() => _StudentGiftStoreScreenState();
}

class _StudentGiftStoreScreenState extends State<StudentGiftStoreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load dữ liệu khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentGiftService>().fetchStoreData();
      context.read<StudentGiftService>().fetchMyRedemptions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cửa Hàng Đổi Quà',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(icon: Icon(Icons.storefront), text: 'Cửa Hàng'),
            Tab(icon: Icon(Icons.card_giftcard), text: 'Kho Quà Của Tôi'),
          ],
        ),
        actions: [
          // Hiển thị số dư Coin hiện tại của User
          Consumer<AuthService>(
            builder: (context, auth, _) {
              final coins = auth.currentUser?.coins ?? 0;
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$coins',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_StoreTab(), _MyRedemptionTab()],
      ),
    );
  }
}

// ================== TAB 1: CỬA HÀNG ==================
class _StoreTab extends StatelessWidget {
  const _StoreTab();

  void _confirmRedeem(BuildContext context, GiftModel gift) {
    final userCoins = context.read<AuthService>().currentUser?.coins ?? 0;

    if (userCoins < gift.coinPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bạn không đủ Coin! Cần thêm ${gift.coinPrice - userCoins} xu nữa.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Xác nhận đổi quà'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bạn muốn dùng ${gift.coinPrice} xu để đổi lấy:'),
                const SizedBox(height: 8),
                Text(
                  gift.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Lưu ý: Sau khi đổi, hãy đến quầy lễ tân và đọc tên/email để nhận quà.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final success = await context
                      .read<StudentGiftService>()
                      .redeemGift(gift.id);
                  if (success) {
                    // ✅ [ĐÃ SỬA] Gọi AuthService để cập nhật số dư cho Consumer ở trên
                    // ignore: use_build_context_synchronously
                    context.read<AuthService>().fetchCurrentUser();
                  }
                },
                child: const Text(
                  'Đổi ngay',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<StudentGiftService>();
    final gifts = service.gifts;
    final isLoading = service.isLoading;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (gifts.isEmpty) {
      return const CommonEmptyState(
        title: 'Cửa hàng đang đóng cửa',
        subtitle: 'Hiện chưa có món quà nào được bày bán.',
        icon: Icons.store_mall_directory_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () => service.fetchStoreData(),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 cột
          childAspectRatio: 0.75, // Tỷ lệ khung hình
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: gifts.length,
        itemBuilder: (context, index) {
          final gift = gifts[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Ảnh
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      color: Colors.grey[200],
                      image:
                          gift.imageUrl != null
                              ? DecorationImage(
                                image: NetworkImage(gift.imageUrl!),
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                    child:
                        gift.imageUrl == null
                            ? const Center(
                              child: Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.grey,
                              ),
                            )
                            : null,
                  ),
                ),

                // 2. Thông tin
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gift.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.monetization_on,
                            size: 14,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${gift.coinPrice}',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Kho: ${gift.stockQuantity}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: ElevatedButton(
                          onPressed:
                              gift.stockQuantity > 0
                                  ? () => _confirmRedeem(context, gift)
                                  : null, // Hết hàng thì disable
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.zero,
                            disabledBackgroundColor: Colors.grey[300],
                          ),
                          child: Text(
                            gift.stockQuantity > 0 ? 'Đổi quà' : 'Hết hàng',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ================== TAB 2: KHO QUÀ CỦA TÔI ==================
class _MyRedemptionTab extends StatelessWidget {
  const _MyRedemptionTab();

  @override
  Widget build(BuildContext context) {
    final service = context.watch<StudentGiftService>();
    final redemptions = service.redemptions;
    final isLoading = service.isLoading;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (redemptions.isEmpty) {
      return const CommonEmptyState(
        title: 'Chưa có quà nào',
        subtitle: 'Hãy tích lũy Coin và đổi quà ngay nhé!',
        icon: Icons.card_giftcard,
      );
    }

    return RefreshIndicator(
      onRefresh: () => service.fetchMyRedemptions(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: redemptions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = redemptions[index];
          final isPending = item.status == "PENDING";

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // Ảnh nhỏ
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                      image:
                          item.giftImage != null
                              ? DecorationImage(
                                image: NetworkImage(item.giftImage!),
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                    child:
                        item.giftImage == null
                            ? const Icon(Icons.image, color: Colors.grey)
                            : null,
                  ),
                  const SizedBox(width: 16),

                  // Thông tin
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.giftName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Đổi ngày: ${DateFormat('dd/MM/yyyy HH:mm').format(item.redeemedAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              size: 12,
                              color: Colors.orange,
                            ),
                            Text(
                              ' ${item.coinCost}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Badge Trạng thái
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isPending ? Colors.amber[100] : Colors.green[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isPending ? Colors.amber : Colors.green,
                      ),
                    ),
                    child: Text(
                      isPending ? 'Chờ nhận' : 'Đã nhận',
                      style: TextStyle(
                        color:
                            isPending ? Colors.amber[900] : Colors.green[900],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
