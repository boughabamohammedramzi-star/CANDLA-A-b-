
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CandlaApp());
}

class CandlaApp extends StatelessWidget {
  const CandlaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CANDLA.A.b',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE8A1B0),
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  // قراءة الطلبات القديمة دون تغيير مفتاح التخزين
  Future<void> loadOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('orders');

      if (data != null) {
        final decoded = jsonDecode(data);

        if (decoded is List) {
          orders = decoded
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error loading orders: $e');
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // حفظ الطلبات بنفس الصيغة القديمة
  Future<void> saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('orders', jsonEncode(orders));
  }

  Future<void> addOrder(
    String name,
    String product,
    String price,
  ) async {
    if (name.trim().isEmpty ||
        product.trim().isEmpty ||
        price.trim().isEmpty) {
      return;
    }

    final newOrder = {
      'name': name.trim(),
      'product': product.trim(),
      'price': price.trim(),
      'date': DateTime.now().toString().substring(0, 10),
    };

    final updatedOrders = List<Map<String, dynamic>>.from(orders);
    updatedOrders.insert(0, newOrder);

    orders = updatedOrders;
    await saveOrders();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> deleteOrder(int index) async {
    final updatedOrders = List<Map<String, dynamic>>.from(orders);
    updatedOrders.removeAt(index);

    orders = updatedOrders;
    await saveOrders();

    if (mounted) {
      setState(() {});
    }
  }

  int get total {
    return orders.fold(0, (sum, order) {
      return sum +
          (int.tryParse(order['price'].toString()) ?? 0);
    });
  }

  void showAddDialog() {
    final nameController = TextEditingController();
    final productController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('طلب جديد 🌸'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم الزبون',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: productController,
                    decoration: const InputDecoration(
                      labelText: 'المنتج',
                      prefixIcon: Icon(Icons.local_cafe),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'السعر (DZD)',
                      prefixIcon: Icon(Icons.payments),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  nameController.dispose();
                  productController.dispose();
                  priceController.dispose();
                },
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty ||
                      productController.text.trim().isEmpty ||
                      priceController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('يرجى ملء جميع المعلومات'),
                      ),
                    );
                    return;
                  }

                  await addOrder(
                    nameController.text,
                    productController.text,
                    priceController.text,
                  );

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }

                  nameController.dispose();
                  productController.dispose();
                  priceController.dispose();
                },
                child: const Text('حفظ الطلب'),
              ),
            ],
          ),
        );
      },
    );
  }

  void confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('حذف الطلب'),
            content: const Text('هل تريد حذف هذا الطلب؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await deleteOrder(index);
                },
                child: const Text('حذف'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFF3D5DE),
          title: const Text(
            'CANDLA.A.b 💗',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Card(
                    margin: const EdgeInsets.all(16),
                    color: const Color(0xFFFFEDF2),
                    child: ListTile(
                      leading: const Icon(
                        Icons.shopping_bag,
                        size: 35,
                      ),
                      title: const Text('عدد الطلبات'),
                      subtitle: Text('${orders.length} طلب'),
                      trailing: Text(
                        '$total DZD',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'قائمة الطلبيات',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: orders.isEmpty
                        ? const Center(
                            child: Text(
                              'لا توجد طلبات حالياً 🌸',
                              style: TextStyle(fontSize: 17),
                            ),
                          )
                        : ListView.builder(
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              final order = orders[index];

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Color(0xFFFFEDF2),
                                    child: Icon(
                                      Icons.shopping_bag,
                                      color: Colors.pink,
                                    ),
                                  ),
                                  title: Text(
                                    order['name']?.toString() ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${order['product'] ?? ''}\n'
                                    '${order['date'] ?? ''}',
                                  ),
                                  isThreeLine: true,
                                  trailing: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${order['price'] ?? '0'} DZD',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => confirmDelete(index),
                                        child: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                          size: 22,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: showAddDialog,
          backgroundColor: const Color(0xFFE8A1B0),
          icon: const Icon(Icons.add),
          label: const Text('طلب جديد'),
        ),
      ),
    );
  }
}
