
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

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
        fontFamily: 'Roboto',
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
  int page = 0;
  bool loading = true;

  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> expenses = [];

  final picker = ImagePicker();

  static const pink = Color(0xFFE8A1B0);
  static const String ordersKey = 'orders';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      // Keep the original orders storage key.
      orders = _decodeList(prefs.getString(ordersKey));
      products = _decodeList(prefs.getString('products'));
      customers = _decodeList(prefs.getString('customers'));
      expenses = _decodeList(prefs.getString('expenses'));
      loading = false;
    });
  }

  List<Map<String, dynamic>> _decodeList(String? value) {
    if (value == null || value.isEmpty) return [];
    try {
      return List<Map<String, dynamic>>.from(
        (jsonDecode(value) as List).map(
          (item) => Map<String, dynamic>.from(item),
        ),
      );
    } catch (_) {
      return [];
    }
  }

  Future<void> saveList(
    String key,
    List<Map<String, dynamic>> data,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
  }

  Future<void> saveOrders() => saveList(ordersKey, orders);
  Future<void> saveProducts() => saveList('products', products);
  Future<void> saveCustomers() => saveList('customers', customers);
  Future<void> saveExpenses() => saveList('expenses', expenses);

  Future<String?> chooseImage() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return null;

      final directory = await getApplicationDocumentsDirectory();
      final imageDirectory = Directory('${directory.path}/candles');

      if (!await imageDirectory.exists()) {
        await imageDirectory.create(recursive: true);
      }

      final fileName =
          'candle_${DateTime.now().microsecondsSinceEpoch}.jpg';

      final saved = await File(image.path).copy(
        '${imageDirectory.path}/$fileName',
      );

      return saved.path;
    } catch (e) {
      showMessage('تعذر اختيار الصورة: $e');
      return null;
    }
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  int number(dynamic value) {
    return int.tryParse(value.toString()) ?? 0;
  }

  int get totalSales =>
      orders.fold(0, (sum, item) => sum + number(item['price']));

  int get totalExpenses =>
      expenses.fold(0, (sum, item) => sum + number(item['amount']));

  int get profit => totalSales - totalExpenses;

  Future<void> addProduct() async {
    final name = TextEditingController();
    final price = TextEditingController();
    String? imagePath;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, updateDialog) => AlertDialog(
          title: const Text('إضافة شمعة جديدة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (imagePath != null &&
                    File(imagePath!).existsSync())
                  Image.file(
                    File(imagePath!),
                    height: 130,
                    width: 150,
                    fit: BoxFit.cover,
                  )
                else
                  const Icon(Icons.image, size: 65, color: pink),
                TextButton.icon(
                  onPressed: () async {
                    final result = await chooseImage();
                    if (result != null) {
                      updateDialog(() => imagePath = result);
                    }
                  },
                  icon: const Icon(Icons.photo_library),
                  label: const Text('اختيار صورة من المعرض'),
                ),
                TextField(
                  controller: name,
                  decoration: const InputDecoration(
                    labelText: 'اسم المنتج',
                  ),
                ),
                TextField(
                  controller: price,
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
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (name.text.trim().isEmpty ||
                    number(price.text) <= 0) {
                  showMessage('أدخل اسم المنتج وسعراً صحيحاً');
                  return;
                }

                setState(() {
                  products.add({
                    'name': name.text.trim(),
                    'price': number(price.text),
                    'image': imagePath ?? '',
                  });
                });

                await saveProducts();
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
                showMessage('تمت إضافة المنتج بنجاح');
              },
              child: const Text('حفظ المنتج'),
            ),
          ],
        ),
      ),
    );

    name.dispose();
    price.dispose();
  }

  Future<void> editProduct(int index) async {
    final product = products[index];
    final name = TextEditingController(text: product['name']);
    final price = TextEditingController(
      text: product['price'].toString(),
    );
    String? imagePath = product['image'];

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, updateDialog) => AlertDialog(
          title: const Text('تعديل المنتج'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (imagePath != null &&
                    imagePath!.isNotEmpty &&
                    File(imagePath!).existsSync())
                  Image.file(
                    File(imagePath!),
                    height: 120,
                  ),
                TextButton(
                  onPressed: () async {
                    final result = await chooseImage();
                    if (result != null) {
                      updateDialog(() => imagePath = result);
                    }
                  },
                  child: const Text('تغيير الصورة'),
                ),
                TextField(
                  controller: name,
                  decoration: const InputDecoration(
                    labelText: 'اسم المنتج',
                  ),
                ),
                TextField(
                  controller: price,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'السعر DZD',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (name.text.trim().isEmpty ||
                    number(price.text) <= 0) return;

                setState(() {
                  products[index] = {
                    'name': name.text.trim(),
                    'price': number(price.text),
                    'image': imagePath ?? '',
                  };
                });
                await saveProducts();
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );

    name.dispose();
    price.dispose();
  }

  Future<void> addOrder() async {
    final name = TextEditingController();
    final product = TextEditingController();
    final price = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('طلب جديد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(
                  labelText: 'اسم الزبون',
                ),
              ),
              TextField(
                controller: product,
                decoration: const InputDecoration(
                  labelText: 'المنتج',
                ),
              ),
              TextField(
                controller: price,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'السعر DZD',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (name.text.trim().isEmpty ||
                  product.text.trim().isEmpty ||
                  number(price.text) <= 0) {
                showMessage('يرجى إكمال بيانات الطلب');
                return;
              }

              final order = {
                'name': name.text.trim(),
                'product': product.text.trim(),
                'price': price.text.trim(),
                'date': DateTime.now()
                    .toString()
                    .substring(0, 10),
              };

              setState(() {
                orders.insert(0, order);

                if (!customers.any(
                  (c) => c['name'] == name.text.trim(),
                )) {
                  customers.add({'name': name.text.trim()});
                }
              });

              await saveOrders();
              await saveCustomers();

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
              showMessage('تم حفظ الطلب');
            },
            child: const Text('حفظ الطلب'),
          ),
        ],
      ),
    );

    name.dispose();
    product.dispose();
    price.dispose();
  }

  Future<void> addCustomer() async {
    final name = TextEditingController();
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إضافة زبون'),
        content: TextField(
          controller: name,
          decoration: const InputDecoration(
            labelText: 'اسم الزبون',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (name.text.trim().isEmpty) return;
              setState(() {
                customers.add({'name': name.text.trim()});
              });
              await saveCustomers();
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    name.dispose();
  }

  Future<void> addExpense() async {
    final title = TextEditingController();
    final amount = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إضافة مصروف'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(
                labelText: 'سبب المصروف',
              ),
            ),
            TextField(
              controller: amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'المبلغ DZD',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (title.text.trim().isEmpty ||
                  number(amount.text) <= 0) return;

              setState(() {
                expenses.add({
                  'title': title.text.trim(),
                  'amount': number(amount.text),
                  'date': DateTime.now()
                      .toString()
                      .substring(0, 10),
                });
              });
              await saveExpenses();
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    title.dispose();
    amount.dispose();
  }

  Widget dashboard() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'مرحباً بك في CANDLA.A.b 🕯️',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 18),
        summaryCard('المنتجات', products.length, Icons.local_fire_department),
        summaryCard('الطلبات', orders.length, Icons.shopping_bag),
        summaryCard('الزبائن', customers.length, Icons.people),
        summaryCard('إجمالي المبيعات', totalSales, Icons.trending_up),
        summaryCard('المصاريف', totalExpenses, Icons.money_off),
        summaryCard('الأرباح', profit, Icons.account_balance_wallet),
      ],
    );
  }

  Widget summaryCard(String title, int value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: pink, size: 30),
        title: Text(title),
        trailing: Text(
          title == 'المنتجات' ||
                  title == 'الطلبات' ||
                  title == 'الزبائن'
              ? '$value'
              : '$value DZD',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
    );
  }

  Widget productPage() {
    return Column(
      children: [
        Expanded(
          child: products.isEmpty
              ? const Center(child: Text('لا توجد منتجات حالياً'))
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final item = products[index];
                    final path = item['image']?.toString() ?? '';
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: path.isNotEmpty &&
                                File(path).existsSync()
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(path),
                                  width: 55,
                                  height: 55,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.local_fire_department,
                                color: pink,
                                size: 35,
                              ),
                        title: Text(item['name'].toString()),
                        subtitle: Text('${item['price']} DZD'),
                        trailing: Wrap(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => editProduct(index),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () async {
                                setState(() => products.removeAt(index));
                                await saveProducts();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton.icon(
            onPressed: addProduct,
            icon: const Icon(Icons.add),
            label: const Text('إضافة منتج جديد'),
          ),
        ),
      ],
    );
  }

  Widget orderPage() {
    return Column(
      children: [
        Expanded(
          child: orders.isEmpty
              ? const Center(child: Text('لا توجد طلبات'))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final item = orders[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.shopping_bag,
                          color: pink,
                        ),
                        title: Text(item['name']?.toString() ?? ''),
                        subtitle: Text(
                          '${item['product'] ?? ''} • ${item['date'] ?? ''}',
                        ),
                        trailing: Text(
                          '${item['price'] ?? '0'} DZD',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton.icon(
            onPressed: addOrder,
            icon: const Icon(Icons.add),
            label: const Text('إضافة طلب جديد'),
          ),
        ),
      ],
    );
  }

  Widget customerPage() {
    return Column(
      children: [
        Expanded(
          child: customers.isEmpty
              ? const Center(child: Text('لا يوجد زبائن'))
              : ListView.builder(
                  itemCount: customers.length,
                  it
