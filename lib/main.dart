
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
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

  final nameController = TextEditingController();
  final productController = TextEditingController();
  final priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  Future<void> loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('orders');

    if (data != null) {
      setState(() {
        orders = List<Map<String, dynamic>>.from(
          jsonDecode(data),
        );
      });
    }
  }

  Future<void> saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('orders', jsonEncode(orders));
  }

  void addOrder() {
    if (nameController.text.isEmpty ||
        productController.text.isEmpty ||
        priceController.text.isEmpty) {
      return;
    }

    setState(() {
      orders.insert(0, {
        'name': nameController.text,
        'product': productController.text,
        'price': priceController.text,
        'date': DateTime.now().toString().substring(0, 10),
      });
    });

    saveOrders();

    nameController.clear();
    productController.clear();
    priceController.clear();

    Navigator.pop(context);
  }

  void deleteOrder(int index) {
    setState(() {
      orders.removeAt(index);
    });
    saveOrders();
  }

  void showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
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
                  ),
                ),
                TextField(
                  controller: productController,
                  decoration: const InputDecoration(
                    labelText: 'المنتج',
                  ),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'السعر (DZD)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: addOrder,
              child: const Text('حفظ الطلب'),
            ),
          ],
        ),
      ),
    );
  }

  int get total {
    return orders.fold(0, (sum, order) {
      return sum + (int.tryParse(order['price'].toString()) ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3D5DE),
        title: const Text(
          'CANDLA.A.b 💗',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Card(
              margin: const EdgeInsets.all(16),
              color: const Color(0xFFFFEDF2),
              child: ListTile(
                leading: const Icon(Icons.shopping_bag, size: 35),
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
                      child: Text('لا توجد طلبات بعد 🌷'),
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
                              backgroundColor: Color(0xFFF3D5DE),
                              child: const Icon(Icons.person),
                            ),
                            title: Text(order['name']),
                            subtitle: Text(
                              '${order['product']} • ${order['date']}',
                            ),
                            trailing: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${order['price']} DZD',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => deleteOrder(index),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddDialog,
        backgroundColor: const Color(0xFFE8A1B0),
        icon: const Icon(Icons.add),
        label: const Text('إضافة طلب'),
      ),
    );
  }
}
