import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CandlaApp());
}

class CandlaApp extends StatefulWidget {
  const CandlaApp({super.key});

  @override
  State<CandlaApp> createState() => _CandlaAppState();
}

class _CandlaAppState extends State<CandlaApp> {
  Color seedColor = const Color(0xFFE8A1B0);
  String language = 'ar';
  bool ready = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedColor = prefs.getInt('candla_theme_color');
    final savedLanguage = prefs.getString('candla_language') ?? 'ar';
    if (!mounted) return;
    setState(() {
      if (savedColor != null) seedColor = Color(savedColor);
      language = savedLanguage;
      ready = true;
    });
  }

  Future<void> updateColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('candla_theme_color', color.value);
    if (mounted) setState(() => seedColor = color);
  }

  Future<void> updateLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('candla_language', value);
    if (mounted) setState(() => language = value);
  }

  @override
  Widget build(BuildContext context) {
    if (!ready) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CANDLA.A.b',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        scaffoldBackgroundColor: const Color(0xFFF8F7F8),
        appBarTheme: const AppBarTheme(centerTitle: true),
        cardTheme: CardThemeData(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      home: HomePage(
        language: language,
        onLanguageChanged: updateLanguage,
        onColorChanged: updateColor,
        seedColor: seedColor,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.language,
    required this.onLanguageChanged,
    required this.onColorChanged,
    required this.seedColor,
  });

  final String language;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<Color> onColorChanged;
  final Color seedColor;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int page = 0;
  bool loading = true;

  // IMPORTANT: Keep these original storage keys for compatibility.
  static const String ordersKey = 'orders';
  static const String productsKey = 'products';
  static const String customersKey = 'customers';
  static const String expensesKey = 'expenses';

  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> expenses = [];

  final ImagePicker picker = ImagePicker();

  static const Map<String, Map<String, String>> words = {
    'ar': {
      'home': 'الرئيسية', 'products': 'المنتجات', 'orders': 'الطلبات',
      'customers': 'الزبائن', 'finance': 'المالية', 'settings': 'الإعدادات',
      'welcome': 'مرحباً بك في CANDLA.A.b', 'totalProducts': 'عدد المنتجات',
      'totalOrders': 'عدد الطلبات', 'totalCustomers': 'عدد الزبائن',
      'sales': 'إجمالي المبيعات', 'expenses': 'المصاريف', 'profit': 'الأرباح',
      'addProduct': 'إضافة شمعة جديدة', 'addOrder': 'إضافة طلب جديد',
      'addCustomer': 'إضافة زبون', 'addExpense': 'إضافة مصروف',
      'productName': 'اسم المنتج', 'price': 'السعر (DZD)',
      'customerName': 'اسم الزبون', 'product': 'المنتج',
      'expenseReason': 'سبب المصروف', 'amount': 'المبلغ (DZD)',
      'save': 'حفظ', 'cancel': 'إلغاء', 'chooseImage': 'اختيار صورة من المعرض',
      'noProducts': 'لا توجد منتجات حالياً', 'noOrders': 'لا توجد طلبات',
      'noCustomers': 'لا يوجد زبائن', 'language': 'لغة التطبيق',
      'color': 'لون التطبيق', 'about': 'حول التطبيق',
      'loginNote': 'تسجيل الدخول يحتاج إعداد Firebase أولاً',
      'chart': 'ملخص المبيعات والمصاريف', 'recentOrders': 'أحدث الطلبات',
      'edit': 'تعديل', 'delete': 'حذف', 'saveProduct': 'حفظ المنتج',
      'saveOrder': 'حفظ الطلب', 'invalid': 'يرجى إدخال البيانات بشكل صحيح',
      'saved': 'تم الحفظ بنجاح', 'noExpenses': 'لا توجد مصاريف بعد',
    },
    'fr': {
      'home': 'Accueil', 'products': 'Produits', 'orders': 'Commandes',
      'customers': 'Clients', 'finance': 'Finances', 'settings': 'Paramètres',
      'welcome': 'Bienvenue dans CANDLA.A.b', 'totalProducts': 'Produits',
      'totalOrders': 'Commandes', 'totalCustomers': 'Clients',
      'sales': 'Ventes totales', 'expenses': 'Dépenses', 'profit': 'Bénéfice',
      'addProduct': 'Ajouter une bougie', 'addOrder': 'Nouvelle commande',
      'addCustomer': 'Ajouter un client', 'addExpense': 'Ajouter une dépense',
      'productName': 'Nom du produit', 'price': 'Prix (DZD)',
      'customerName': 'Nom du client', 'product': 'Produit',
      'expenseReason': 'Motif de dépense', 'amount': 'Montant (DZD)',
      'save': 'Enregistrer', 'cancel': 'Annuler',
      'chooseImage': 'Choisir une image', 'noProducts': 'Aucun produit',
      'noOrders': 'Aucune commande', 'noCustomers': 'Aucun client',
      'language': 'Langue', 'color': 'Couleur', 'about': 'À propos',
      'loginNote': 'La connexion nécessite la configuration Firebase',
      'chart': 'Résumé des ventes et dépenses', 'recentOrders': 'Commandes récentes',
      'edit': 'Modifier', 'delete': 'Supprimer', 'saveProduct': 'Enregistrer',
      'saveOrder': 'Enregistrer la commande', 'invalid': 'Vérifiez les champs',
      'saved': 'Enregistré avec succès', 'noExpenses': 'Aucune dépense',
    },
    'en': {
      'home': 'Home', 'products': 'Products', 'orders': 'Orders',
      'customers': 'Customers', 'finance': 'Finance', 'settings': 'Settings',
      'welcome': 'Welcome to CANDLA.A.b', 'totalProducts': 'Products',
      'totalOrders': 'Orders', 'totalCustomers': 'Customers',
      'sales': 'Total sales', 'expenses': 'Expenses', 'profit': 'Profit',
      'addProduct': 'Add a candle', 'addOrder': 'Add new order',
      'addCustomer': 'Add customer', 'addExpense': 'Add expense',
      'productName': 'Product name', 'price': 'Price (DZD)',
      'customerName': 'Customer name', 'product': 'Product',
      'expenseReason': 'Expense reason', 'amount': 'Amount (DZD)',
      'save': 'Save', 'cancel': 'Cancel', 'chooseImage': 'Choose from gallery',
      'noProducts': 'No products yet', 'noOrders': 'No orders',
      'noCustomers': 'No customers', 'language': 'App language',
      'color': 'App color', 'about': 'About',
      'loginNote': 'Sign-in requires Firebase setup first',
      'chart': 'Sales and expenses overview', 'recentOrders': 'Recent orders',
      'edit': 'Edit', 'delete': 'Delete', 'saveProduct': 'Save product',
      'saveOrder': 'Save order', 'invalid': 'Please enter valid information',
      'saved': 'Saved successfully', 'noExpenses': 'No expenses yet',
    },
  };

  String tr(String key) => words[widget.language]?[key] ?? words['ar']![key] ?? key;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final loadedOrders = _decodeList(prefs.getString(ordersKey));
    final loadedProducts = _decodeList(prefs.getString(productsKey));
    final loadedCustomers = _decodeList(prefs.getString(customersKey));
    final loadedExpenses = _decodeList(prefs.getString(expensesKey));
    if (!mounted) return;
    setState(() {
      orders = loadedOrders;
      products = loadedProducts;
      customers = loadedCustomers;
      expenses = loadedExpenses;
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

  Future<void> saveList(String key, List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
  }

  Future<void> saveOrders() => saveList(ordersKey, orders);
  Future<void> saveProducts() => saveList(productsKey, products);
  Future<void> saveCustomers() => saveList(customersKey, customers);
  Future<void> saveExpenses() => saveList(expensesKey, expenses);

  int number(dynamic value) => int.tryParse(value.toString()) ?? 0;

  int get totalSales => orders.fold(0, (sum, item) => sum + number(item['price']));
  int get totalExpenses => expenses.fold(0, (sum, item) => sum + number(item['amount']));
  int get profit => totalSales - totalExpenses;

  void message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

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
      final fileName = 'candle_${DateTime.now().microsecondsSinceEpoch}.jpg';
      final saved = await File(image.path).copy('${imageDirectory.path}/$fileName');
      return saved.path;
    } catch (e) {
      message('تعذر اختيار الصورة: $e');
      return null;
    }
  }

  Future<void> addProduct() async {
    final name = TextEditingController();
    final price = TextEditingController();
    String? imagePath;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, updateDialog) => AlertDialog(
          title: Text(tr('addProduct')),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (imagePath != null && File(imagePath!).existsSync())
                Image.file(File(imagePath!), height: 125, fit: BoxFit.cover)
              else
                const Icon(Icons.local_fire_department, size: 62),
              TextButton.icon(
                onPressed: () async {
                  final result = await chooseImage();
                  if (result != null) updateDialog(() => imagePath = result);
                },
                icon: const Icon(Icons.photo_library),
                label: Text(tr('chooseImage')),
              ),
              TextField(controller: name, decoration: InputDecoration(labelText: tr('productName'))),
              TextField(controller: price, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: tr('price'))),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(tr('cancel'))),
            FilledButton(
              onPressed: () async {
                if (name.text.trim().isEmpty || number(price.text) <= 0) {
                  message(tr('invalid')); return;
                }
                setState(() => products.add({
                  'name': name.text.trim(),
                  'price': number(price.text),
                  'image': imagePath ?? '',
                }));
                await saveProducts();
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                message(tr('saved'));
              },
              child: Text(tr('saveProduct')),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    price.dispose();
  }

  Future<void> editProduct(int index) async {
    final item = products[index];
    final name = TextEditingController(text: item['name']?.toString() ?? '');
    final price = TextEditingController(text: item['price']?.toString() ?? '');
    String? imagePath = item['image']?.toString();

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, updateDialog) => AlertDialog(
          title: Text(tr('edit')),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (imagePath != null && imagePath!.isNotEmpty && File(imagePath!).existsSync())
                Image.file(File(imagePath!), height: 110),
              TextButton(
                onPressed: () async {
                  final result = await chooseImage();
                  if (result != null) updateDialog(() => imagePath = result);
                },
                child: Text(tr('chooseImage')),
              ),
              TextField(controller: name, decoration: InputDecoration(labelText: tr('productName'))),
              TextField(controller: price, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: tr('price'))),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(tr('cancel'))),
            FilledButton(
              onPressed: () async {
                if (name.text.trim().isEmpty || number(price.text) <= 0) return;
                setState(() => products[index] = {
                  'name': name.text.trim(),
                  'price': number(price.text),
                  'image': imagePath ?? '',
                });
                await saveProducts();
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: Text(tr('save')),
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
        title: Text(tr('addOrder')),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: InputDecoration(labelText: tr('customerName'))),
            TextField(controller: product, decoration: InputDecoration(labelText: tr('product'))),
            TextField(controller: price, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: tr('price'))),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(tr('cancel'))),
          FilledButton(
            onPressed: () async {
              if (name.text.trim().isEmpty || product.text.trim().isEmpty || number(price.text) <= 0) {
                message(tr('invalid')); return;
              }
              // Preserve the legacy order field names and value types.
              final order = {
                'name': name.text.trim(),
                'product': product.text.trim(),
                'price': price.text.trim(),
                'date': DateTime.now().toString().substring(0, 10),
              };
              setState(() {
                orders.insert(0, order);
                if (!customers.any((c) => c['name'] == name.text.trim())) {
                  customers.add({'name': name.text.trim()});
                }
              });
              await saveOrders();
              await saveCustomers();
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              message(tr('saved'));
            },
            child: Text(tr('saveOrder')),
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
        title: Text(tr('addCustomer')),
        content: TextField(controller: name, decoration: InputDecoration(labelText: tr('customerName'))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(tr('cancel'))),
          FilledButton(
            onPressed: () async {
              if (name.text.trim().isEmpty) return;
              setState(() => customers.add({'name': name.text.trim()}));
              await saveCustomers();
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: Text(tr('save')),
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
        title: Text(tr('addExpense')),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: title, decoration: InputDecoration(labelText: tr('expenseReason'))),
          TextField(controller: amount, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: tr('amount'))),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(tr('cancel'))),
          FilledButton(
            onPressed: () async {
              if (title.text.trim().isEmpty || number(amount.text) <= 0) return;
              setState(() => expenses.add({
                'title': title.text.trim(),
                'amount': number(amount.text),
                'date': DateTime.now().toString().substring(0, 10),
              }));
              await saveExpenses();
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: Text(tr('save')),
          ),
        ],
      ),
    );
    title.dispose();
    amount.dispose();
  }

  Widget statCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          CircleAvatar(backgroundColor: color.withOpacity(.13), child: Icon(icon, color: color)),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  Widget dashboard() {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [scheme.primary, scheme.tertiary]),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr('welcome'), style: TextStyle(color: scheme.onPrimary, fontSize: 21, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${tr('profit')}: $profit DZD', style: TextStyle(color: scheme.onPrimary, fontSize: 16)),
          ]),
        ),
        const SizedBox(height: 12),
        statCard(tr('totalProducts'), '${products.length}', Icons.local_fire_department, scheme.primary),
        statCard(tr('totalOrders'), '${orders.length}', Icons.shopping_bag, Colors.deepOrange),
        statCard(tr('totalCustomers'), '${customers.length}', Icons.people, Colors.teal),
        statCard(tr('sales'), '$totalSales DZD', Icons.trending_up, Colors.green),
        statCard(tr('expenses'), '$totalExpenses DZD', Icons.money_off, Colors.red),
        statCard(tr('profit'), '$profit DZD', Icons.account_balance_wallet, scheme.tertiary),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr('chart'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              const SizedBox(height: 16),
              SizedBox(
                height: 155,
                child: SimpleBars(sales: totalSales.toDouble(), expenses: totalExpenses.toDouble()),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _legend(Colors.green, tr('sales')),
                _legend(Colors.red, tr('expenses')),
              ]),
            ]),
          ),
        ),
        const SizedBox(height: 10),
        Text(tr('recentOrders'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (orders.isEmpty) const Padding(
          padding: EdgeInsets.all(12),
          child: Text('—'),
        ),
        ...orders.take(4).map((o) => Card(
          child: ListTile(
            leading: const Icon(Icons.receipt_long),
            title: Text(o['name']?.toString() ?? ''),
            subtitle: Text('${o['product'] ?? ''} • ${o['date'] ?? ''}'),
            trailing: Text('${o['price'] ?? 0} DZD'),
          ),
        )),
      ],
    );
  }

  Widget _legend(Color color, String label) => Row(children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 5),
    Text(label, style: const TextStyle(fontSize: 12)),
  ]);

  Widget productPage() {
    return Column(children: [
      Expanded(
        child: products.isEmpty
            ? Center(child: Text(tr('noProducts')))
            : ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final item = products[index];
                  final path = item['image']?.toString() ?? '';
                  return Card(child: ListTile(
                    leading: path.isNotEmpty && File(path).existsSync()
                        ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(path), width: 54, height: 54, fit: BoxFit.cover))
                        : const Icon(Icons.local_fire_department, size: 34),
                    title: Text(item['name']?.toString() ?? ''),
                    subtitle: Text('${item['price'] ?? 0} DZD'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') await editProduct(index);
                        if (value == 'delete') {
                          setState(() => products.removeAt(index));
                          await saveProducts();
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(value: 'edit', child: Text(tr('edit'))),
                        PopupMenuItem(value: 'delete', child: Text(tr('delete'))),
                      ],
                    ),
                  ));
                },
              ),
      ),
      Padding(padding: const EdgeInsets.all(12), child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(onPressed: addProduct, icon: const Icon(Icons.add), label: Text(tr('addProduct'))),
      )),
    ]);
  }

  Widget orderPage() {
    return Column(children: [
      Expanded(
        child: orders.isEmpty
            ? Center(child: Text(tr('noOrders')))
            : ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final item = orders[index];
                  return Card(child: ListTile(
                    leading: const Icon(Icons.shopping_bag_outlined),
                    title: Text(item['name']?.toString() ?? ''),
                    subtitle: Text('${item['product'] ?? ''} • ${item['date'] ?? ''}'),
                    trailing: Text('${item['price'] ?? 0} DZD', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ));
                },
              ),
      ),
      Padding(padding: const EdgeInsets.all(12), child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(onPressed: addOrder, icon: const Icon(Icons.add), label: Text(tr('addOrder'))),
      )),
    ]);
  }

  Widget customerPage() {
    return Column(children: [
      Expanded(
        child: customers.isEmpty
            ? Center(child: Text(tr('noCustomers')))
            : ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: customers.length,
                itemBuilder: (context, index) => Card(child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(customers[index]['name']?.toString() ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      setState(() => customers.removeAt(index));
                      await saveCustomers();
                    },
                  ),
                )),
              ),
      ),
      Padding(padding: const EdgeInsets.all(12), child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(onPressed: addCustomer, icon: const Icon(Icons.person_add), label: Text(tr('addCustomer'))),
      )),
    ]);
  }

  Widget financePage() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      statCard(tr('sales'), '$totalSales DZD', Icons.trending_up, Colors.green),
      statCard(tr('expenses'), '$totalExpenses DZD', Icons.money_off, Colors.red),
      statCard(tr('profit'), '$profit DZD', Icons.account_balance_wallet, Theme.of(context).colorScheme.primary),
      const SizedBox(height: 12),
      Text(tr('expenses'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      if (expenses.isEmpty) Padding(padding: const EdgeInsets.all(14), child: Text(tr('noExpenses'))),
      ...expenses.map((item) => Card(child: ListTile(
        leading: const Icon(Icons.receipt),
        title: Text(item['title']?.toString() ?? ''),
        subtitle: Text(item['date']?.toString() ?? ''),
        trailing: Text('${item['amount'] ?? 0} DZD'),
      ))),
      const SizedBox(height: 12),
      FilledButton.icon(onPressed: addExpense, icon: const Icon(Icons.add), label: Text(tr('addExpense'))),
    ]);
  }

  Widget settingsPage() {
    final colors = <Color>[
      const Color(0xFFE8A1B0),
      const Color(0xFF6C8EBF),
      const Color(0xFF5B9A8B),
      const Color(0xFF8B70B5),
      const Color(0xFFDA9B42),
      const Color(0xFF455A64),
    ];
    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tr('language'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: widget.language,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'ar', child: Text('العربية')),
              DropdownMenuItem(value: 'fr', child: Text('Français')),
              DropdownMenuItem(value: 'en', child: Text('English')),
            ],
            onChanged: (value) {
              if (value != null) widget.onLanguageChanged(value);
            },
          ),
        ]),
      )),
      Card(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tr('color'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 12, children: colors.map((color) => InkWell(
            onTap: () => widget.onColorChanged(color),
            borderRadius: BorderRadius.circular(30),
            child: CircleAvatar(
              radius: 23,
              backgroundColor: color,
              child: widget.seedColor.value == color.value ? const Icon(Icons.check, color: Colors.white) : null,
            ),
          )).toList()),
        ]),
      )),
      Card(child: ListTile(
        leading: const Icon(Icons.login),
        title: const Text('Email / Facebook'),
        subtitle: Text(tr('loginNote')),
        onTap: () => message(tr('loginNote')),
      )),
      Card(child: ListTile(
        leading: const Icon(Icons.info_outline),
        title: Text(tr('about')),
        subtitle: const Text('CANDLA.A.b Candle Management App'),
      )),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pages = [dashboard(), productPage(), orderPage(), customerPage(), financePage(), settingsPage()];
    final titles = [tr('home'), tr('products'), tr('orders'), tr('customers'), tr('finance'), tr('settings')];
    final rtl = widget.language == 'ar';

    return Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text('CANDLA.A.b • ${titles[page]}', style: const TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              tooltip: tr('settings'),
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => setState(() => page = 5),
            ),
          ],
        ),
        body: pages[page],
        bottomNavigationBar: NavigationBar(
          selectedIndex: page == 5 ? 0 : page,
          onDestinationSelected: (index) => setState(() => page = index),
          destinations: [
            NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: tr('home')),
            NavigationDestination(icon: const Icon(Icons.local_fire_department_outlined), label: tr('products')),
            NavigationDestination(icon: const Icon(Icons.shopping_bag_outlined), label: tr('orders')),
            NavigationDestination(icon: const Icon(Icons.people_outline), label: tr('customers')),
            NavigationDestination(icon: const Icon(Icons.account_balance_wallet_outlined), label: tr('finance')),
          ],
        ),
      ),
    );
  }
}

class SimpleBars extends StatelessWidget {
  const SimpleBars({super.key, required this.sales, required this.expenses});
  final double sales;
  final double expenses;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BarsPainter(sales: sales, expenses: expenses, textColor: Theme.of(context).colorScheme.onSurface),
      child: const SizedBox.expand(),
    );
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter({required this.sales, required this.expenses, required this.textColor});
  final double sales;
  final double expenses;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    final base = Paint()..color = Colors.grey.withOpacity(.25)..strokeWidth = 1;
    canvas.drawLine(Offset(12, size.height - 24), Offset(size.width - 12, size.height - 24), base);

    final maxValue = (sales > expenses ? sales : expenses);
    final scale = maxValue <= 0 ? 1.0 : (size.height - 48) / maxValue;
    final barPaint = Paint()..style = PaintingStyle.fill;
    final barWidth = size.width * .19;

    final salesHeight = sales * scale;
    barPaint.color = Colors.green;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.width * .23, size.height - 24 - salesHeight, barWidth, salesHeight), const Radius.circular(8)),
      barPaint,
    );

    final expensesHeight = expenses * scale;
    barPaint.color = Colors.red;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.width * .59, size.height - 24 - expensesHeight, barWidth, expensesHeight), const Radius.circular(8)),
      barPaint,
    );

    final textStyle = TextStyle(color: textColor, fontSize: 11);
    _drawText(canvas, 'Sales', Offset(size.width * .23, size.height - 18), textStyle);
    _drawText(canvas, 'Expenses', Offset(size.width * .56, size.height - 18), textStyle);
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _BarsPainter oldDelegate) =>
      oldDelegate.sales != sales || oldDelegate.expenses != expenses || oldDelegate.textColor != textColor;
}
