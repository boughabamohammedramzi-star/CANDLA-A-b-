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
  static const _themeKey = 'candla_theme_color';
  static const _languageKey = 'candla_language';
  static const _compactKey = 'candla_compact_view';

  int themeIndex = 0;
  String language = 'ar';
  bool compactView = false;
  bool ready = false;

  static const colors = [
    Color(0xFFE8A1B0),
    Color(0xFF8E7CC3),
    Color(0xFF5B9BD5),
    Color(0xFF5A9E85),
    Color(0xFFD69B45),
    Color(0xFF455A64),
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      themeIndex = prefs.getInt(_themeKey) ?? 0;
      language = prefs.getString(_languageKey) ?? 'ar';
      compactView = prefs.getBool(_compactKey) ?? false;
      ready = true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, themeIndex);
    await prefs.setString(_languageKey, language);
    await prefs.setBool(_compactKey, compactView);
  }

  void updateSettings({
    int? color,
    String? lang,
    bool? compact,
  }) {
    setState(() {
      if (color != null) themeIndex = color;
      if (lang != null) language = lang;
      if (compact != null) compactView = compact;
    });
    _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    if (!ready) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator(color: colors[0])),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CANDLA.A.b',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: colors[themeIndex.clamp(0, colors.length - 1).toInt()]),
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF7F7FA),
      ),
      home: HomePage(
        accent: colors[themeIndex.clamp(0, colors.length - 1).toInt()],
        language: language,
        compactView: compactView,
        onSettingsChanged: updateSettings,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final Color accent;
  final String language;
  final bool compactView;
  final void Function({int? color, String? lang, bool? compact}) onSettingsChanged;

  const HomePage({
    super.key,
    required this.accent,
    required this.language,
    required this.compactView,
    required this.onSettingsChanged,
  });

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

  final ImagePicker picker = ImagePicker();
  static const String ordersKey = 'orders';

  bool get isArabic => widget.language == 'ar';

  String tr(String key) {
    const values = {
      'home': ['الرئيسية', 'Home', 'Accueil'],
      'products': ['المنتجات والشموع', 'Products & Candles', 'Produits et bougies'],
      'orders': ['المبيعات والطلبات', 'Sales & Orders', 'Ventes et commandes'],
      'customers': ['الزبائن', 'Customers', 'Clients'],
      'finance': ['الأرباح والمصاريف', 'Profit & Expenses', 'Bénéfices et dépenses'],
      'settings': ['الإعدادات', 'Settings', 'Paramètres'],
      'welcome': ['مرحباً بك في CANDLA.A.b 🕯️', 'Welcome to CANDLA.A.b 🕯️', 'Bienvenue dans CANDLA.A.b 🕯️'],
      'productsCount': ['عدد المنتجات', 'Products', 'Produits'],
      'ordersCount': ['عدد الطلبات', 'Orders', 'Commandes'],
      'customersCount': ['عدد الزبائن', 'Customers', 'Clients'],
      'sales': ['إجمالي المبيعات', 'Total sales', 'Ventes totales'],
      'expenses': ['المصاريف', 'Expenses', 'Dépenses'],
      'profit': ['صافي الأرباح', 'Net profit', 'Bénéfice net'],
      'addProduct': ['إضافة منتج جديد', 'Add product', 'Ajouter un produit'],
      'addOrder': ['إضافة طلب جديد', 'Add order', 'Ajouter une commande'],
      'addCustomer': ['إضافة زبون', 'Add customer', 'Ajouter un client'],
      'addExpense': ['إضافة مصروف', 'Add expense', 'Ajouter une dépense'],
      'noProducts': ['لا توجد منتجات حالياً', 'No products yet', 'Aucun produit pour le moment'],
      'noOrders': ['لا توجد طلبات', 'No orders', 'Aucune commande'],
      'noCustomers': ['لا يوجد زبائن', 'No customers', 'Aucun client'],
      'name': ['اسم المنتج', 'Product name', 'Nom du produit'],
      'price': ['السعر (DZD)', 'Price (DZD)', 'Prix (DZD)'],
      'customerName': ['اسم الزبون', 'Customer name', 'Nom du client'],
      'productName': ['المنتج', 'Product', 'Produit'],
      'save': ['حفظ', 'Save', 'Enregistrer'],
      'cancel': ['إلغاء', 'Cancel', 'Annuler'],
      'chooseImage': ['اختيار صورة من المعرض', 'Choose image from gallery', 'Choisir une image'],
      'changeImage': ['تغيير الصورة', 'Change image', 'Changer l’image'],
      'language': ['لغة التطبيق', 'App language', 'Langue'],
      'color': ['لون التطبيق', 'App color', 'Couleur'],
      'display': ['شكل عرض التطبيق', 'Display style', 'Style d’affichage'],
      'compact': ['عرض مضغوط', 'Compact view', 'Vue compacte'],
      'comfortable': ['عرض مريح', 'Comfortable view', 'Vue confortable'],
      'about': ['حول التطبيق', 'About the app', 'À propos'],
      'login': ['تسجيل الدخول', 'Sign in', 'Connexion'],
      'emailLogin': ['الدخول بالبريد الإلكتروني', 'Sign in with email', 'Connexion par e-mail'],
      'facebookLogin': ['الدخول بفيسبوك', 'Sign in with Facebook', 'Connexion avec Facebook'],
      'firebaseNote': ['تفعيل تسجيل الدخول الحقيقي يتطلب إعداد Firebase وربط مفاتيح المشروع.', 'Real sign-in requires Firebase configuration and project keys.', 'La connexion réelle nécessite la configuration de Firebase.'],
      'chart': ['ملخص المبيعات حسب الطلبات', 'Sales summary by orders', 'Résumé des ventes par commande'],
      'expensesTitle': ['قائمة المصاريف', 'Expense list', 'Liste des dépenses'],
      'expenseReason': ['سبب المصروف', 'Expense description', 'Motif de la dépense'],
      'amount': ['المبلغ (DZD)', 'Amount (DZD)', 'Montant (DZD)'],
      'edit': ['تعديل', 'Edit', 'Modifier'],
      'delete': ['حذف', 'Delete', 'Supprimer'],
      'saveProduct': ['حفظ المنتج', 'Save product', 'Enregistrer le produit'],
      'newCandle': ['إضافة شمعة جديدة', 'Add a new candle', 'Ajouter une bougie'],
      'editProduct': ['تعديل المنتج', 'Edit product', 'Modifier le produit'],
      'savedOrder': ['تم حفظ الطلب', 'Order saved', 'Commande enregistrée'],
      'savedProduct': ['تمت إضافة المنتج بنجاح', 'Product added successfully', 'Produit ajouté'],
      'fillOrder': ['يرجى إكمال بيانات الطلب', 'Please complete the order details', 'Veuillez compléter la commande'],
      'validProduct': ['أدخل اسم المنتج وسعراً صحيحاً', 'Enter a product name and valid price', 'Saisissez un nom et un prix valide'],
      'currency': ['دج', 'DZD', 'DZD'],
    };
    final index = widget.language == 'ar' ? 0 : widget.language == 'fr' ? 2 : 1;
    return values[key]?[index] ?? key;
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      // These original keys are intentionally unchanged to preserve existing data.
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
        (jsonDecode(value) as List).map((item) => Map<String, dynamic>.from(item)),
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
  Future<void> saveProducts() => saveList('products', products);
  Future<void> saveCustomers() => saveList('customers', customers);
  Future<void> saveExpenses() => saveList('expenses', expenses);

  Future<String?> chooseImage() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
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
      showMessage('تعذر اختيار الصورة: $e');
      return null;
    }
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  int number(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

  int get totalSales => orders.fold(0, (sum, item) => sum + number(item['price']));
  int get totalExpenses => expenses.fold(0, (sum, item) => sum + number(item['amount']));
  int get profit => totalSales - totalExpenses;

  Future<void> addProduct() async {
    final name = TextEditingController();
    final price = TextEditingController();
    String? imagePath;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, updateDialog) => AlertDialog(
          title: Text(tr('newCandle')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (imagePath != null && File(imagePath!).existsSync())
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(File(imagePath!), height: 130, width: 160, fit: BoxFit.cover),
                  )
                else
                  Icon(Icons.local_fire_department, size: 65, color: widget.accent),
                TextButton.icon(
                  onPressed: () async {
                    final result = await chooseImage();
                    if (result != null) updateDialog(() => imagePath = result);
                  },
                  icon: const Icon(Icons.photo_library),
                  label: Text(tr('chooseImage')),
                ),
                TextField(controller: name, decoration: InputDecoration(labelText: tr('name'))),
                TextField(
                  controller: price,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: tr('price')),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(tr('cancel'))),
            FilledButton(
              onPressed: () async {
                if (name.text.trim().isEmpty || number(price.text) <= 0) {
                  showMessage(tr('validProduct'));
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
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                showMessage(tr('savedProduct'));
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
    final product = products[index];
    final name = TextEditingController(text: product['name']?.toString() ?? '');
    final price = TextEditingController(text: product['price']?.toString() ?? '0');
    String? imagePath = product['image']?.toString() ?? '';

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, updateDialog) => AlertDialog(
          title: Text(tr('editProduct')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (imagePath != null && imagePath!.isNotEmpty && File(imagePath!).existsSync())
                  Image.file(File(imagePath!), height: 120, fit: BoxFit.cover),
                TextButton(
                  onPressed: () async {
                    final result = await chooseImage();
                    if (result != null) updateDialog(() => imagePath = result);
                  },
                  child: Text(tr('changeImage')),
                ),
                TextField(controller: name, decoration: InputDecoration(labelText: tr('name'))),
                TextField(
                  controller: price,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: tr('price')),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(tr('cancel'))),
            FilledButton(
              onPressed: () async {
                if (name.text.trim().isEmpty || number(price.text) <= 0) return;
                setState(() {
                  products[index] = {
                    'name': name.text.trim(),
                    'price': number(price.text),
                    'image': imagePath ?? '',
                  };
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: InputDecoration(labelText: tr('customerName'))),
              TextField(controller: product, decoration: InputDecoration(labelText: tr('productName'))),
              TextField(
                controller: price,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: tr('price')),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(tr('cancel'))),
          FilledButton(
            onPressed: () async {
              if (name.text.trim().isEmpty || product.text.trim().isEmpty || number(price.text) <= 0) {
                showMessage(tr('fillOrder'));
                return;
              }
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
              showMessage(tr('savedOrder'));
            },
            child: Text(tr('save')),
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: title, decoration: InputDecoration(labelText: tr('expenseReason'))),
            TextField(
              controller: amount,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: tr('amount')),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(tr('cancel'))),
          FilledButton(
            onPressed: () async {
              if (title.text.trim().isEmpty || number(amount.text) <= 0) return;
              setState(() {
                expenses.add({
                  'title': title.text.trim(),
                  'amount': number(amount.text),
                  'date': DateTime.now().toString().substring(0, 10),
                });
              });
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

  Widget metricCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(widget.compactView ? 10 : 16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: widget.accent.withOpacity(.15),
              child: Icon(icon, color: widget.accent),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
            Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget dashboard() {
    final money = (int value) => '$value ${tr('currency')}';
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.accent, widget.accent.withOpacity(.72)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            tr('welcome'),
            style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 14),
        metricCard(tr('productsCount'), '${products.length}', Icons.local_fire_department),
        metricCard(tr('ordersCount'), '${orders.length}', Icons.shopping_bag),
        metricCard(tr('customersCount'), '${customers.length}', Icons.people),
        metricCard(tr('sales'), money(totalSales), Icons.trending_up),
        metricCard(tr('expenses'), money(totalExpenses), Icons.money_off),
        metricCard(tr('profit'), money(profit), Icons.account_balance_wallet),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr('chart'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 14),
                SizedBox(height: 150, child: SalesChart(orders: orders, accent: widget.accent)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget productPage() {
    return Column(
      children: [
        Expanded(
          child: products.isEmpty
              ? Center(child: Text(tr('noProducts')))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final item = products[index];
                    final path = item['image']?.toString() ?? '';
                    return Card(
                      child: ListTile(
                        contentPadding: EdgeInsets.all(widget.compactView ? 6 : 12),
                        leading: path.isNotEmpty && File(path).existsSync()
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(File(path), width: 58, height: 58, fit: BoxFit.cover),
                              )
                            : Icon(Icons.local_fire_department, color: widget.accent, size: 34),
                        title: Text(item['name']?.toString() ?? ''),
                        subtitle: Text('${item['price'] ?? 0} ${tr('currency')}'),
                        trailing: Wrap(
                          children: [
                            IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => editProduct(index)),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
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
          child: FilledButton.icon(onPressed: addProduct, icon: const Icon(Icons.add), label: Text(tr('addProduct'))),
        ),
      ],
    );
  }

  Widget orderPage() {
    return Column(
      children: [
        Expanded(
          child: orders.isEmpty
              ? Center(child: Text(tr('noOrders')))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final item = orders[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.shopping_bag_outlined, color: widget.accent),
                        title: Text(item['name']?.toString() ?? ''),
                        subtitle: Text('${item['product'] ?? ''} • ${item['date'] ?? ''}'),
                        trailing: Text(
                          '${item['price'] ?? '0'} ${tr('currency')}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(onPressed: addOrder, icon: const Icon(Icons.add), label: Text(tr('addOrder'))),
        ),
      ],
    );
  }

  Widget customerPage() {
    return Column(
      children: [
        Expanded(
          child: customers.isEmpty
              ? Center(child: Text(tr('noCustomers')))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: customers.length,
                  itemBuilder: (context, index) => Card(
                    child: ListTile(
                      leading: Icon(Icons.person_outline, color: widget.accent),
                      title: Text(customers[index]['name']?.toString() ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () async {
                          setState(() => customers.removeAt(index));
                          await saveCustomers();
                        },
                      ),
                    ),
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(onPressed: addCustomer, icon: const Icon(Icons.person_add), label: Text(tr('addCustomer'))),
        ),
      ],
    );
  }

  Widget financePage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        metricCard(tr('sales'), '$totalSales ${tr('currency')}', Icons.trending_up),
        metricCard(tr('expenses'), '$totalExpenses ${tr('currency')}', Icons.money_off),
        metricCard(tr('profit'), '$profit ${tr('currency')}', Icons.account_balance_wallet),
        const SizedBox(height: 12),
        Text(tr('expensesTitle'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        ...expenses.map((item) => Card(
              child: ListTile(
                title: Text(item['title']?.toString() ?? ''),
                subtitle: Text(item['date']?.toString() ?? ''),
                trailing: Text('${item['amount'] ?? 0} ${tr('currency')}'),
              ),
            )),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: addExpense, icon: const Icon(Icons.add), label: Text(tr('addExpense'))),
      ],
    );
  }

  Widget settingsPage() {
    final languageNames = {'ar': 'العربية', 'en': 'English', 'fr': 'Français'};
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Icon(Icons.tune, size: 58, color: widget.accent),
        const SizedBox(height: 10),
        Center(child: Text(tr('settings'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
        const SizedBox(height: 22),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr('color'), style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 14,
                  runSpacing: 12,
                  children: List.generate(_CandlaAppState.colors.length, (index) {
                    final color = _CandlaAppState.colors[index];
                    return InkWell(
                      onTap: () => widget.onSettingsChanged(color: index),
                      borderRadius: BorderRadius.circular(30),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: color,
                        child: (widget.accent == color)
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.language, color: widget.accent),
            title: Text(tr('language')),
            trailing: DropdownButton<String>(
              value: widget.language,
              items: languageNames.entries
                  .map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value)))
                  .toList(),
              onChanged: (value) {
                if (value != null) widget.onSettingsChanged(lang: value);
              },
            ),
          ),
        ),
        Card(
          child: SwitchListTile(
            secondary: Icon(Icons.view_agenda_outlined, color: widget.accent),
            title: Text(tr('display')),
            subtitle: Text(widget.compactView ? tr('compact') : tr('comfortable')),
            value: widget.compactView,
            onChanged: (value) => widget.onSettingsChanged(compact: value),
          ),
        ),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.email_outlined, color: widget.accent),
                title: Text(tr('emailLogin')),
                onTap: () => _showAuthenticationNotice(),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.facebook, color: Color(0xFF1877F2)),
                title: Text(tr('facebookLogin')),
                onTap: () => _showAuthenticationNotice(),
              ),
            ],
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.info_outline, color: widget.accent),
            title: Text(tr('about')),
            subtitle: const Text('CANDLA.A.b Candle Management App'),
          ),
        ),
      ],
    );
  }

  void _showAuthenticationNotice() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(tr('login')),
        content: Text(tr('firebaseNote')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(tr('save'))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final titles = [tr('home'), tr('products'), tr('orders'), tr('customers'), tr('finance'), tr('settings')];
    final pages = [dashboard(), productPage(), orderPage(), customerPage(), financePage(), settingsPage()];

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: widget.accent,
          foregroundColor: Colors.white,
          title: Text('CANDLA.A.b - ${titles[page]}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          centerTitle: true,
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
          selectedIndex: page > 4 ? 0 : page,
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

class SalesChart extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  final Color accent;

  const SalesChart({super.key, required this.orders, required this.accent});

  @override
  Widget build(BuildContext context) {
    final values = List<int>.generate(7, (index) {
      final day = DateTime.now().subtract(Duration(days: 6 - index));
      final key = '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      return orders.where((order) => order['date']?.toString() == key)
          .fold<int>(0, (sum, order) => sum + (int.tryParse(order['price']?.toString() ?? '') ?? 0));
    });

    final maxValue = values.fold<int>(0, (a, b) => a > b ? a : b);
    return CustomPaint(
      painter: _SalesChartPainter(values: values, maxValue: maxValue, color: accent),
      child: const SizedBox.expand(),
    );
  }
}

class _SalesChartPainter extends CustomPainter {
  final List<int> values;
  final int maxValue;
  final Color color;

  _SalesChartPainter({required this.values, required this.maxValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(.22)
      ..strokeWidth = 1;
    final barPaint = Paint()..color = color;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < 4; i++) {
      final y = size.height - 24 - (i * (size.height - 42) / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final slot = size.width / 7;
    final availableHeight = size.height - 42;
    for (int i = 0; i < values.length; i++) {
      final ratio = maxValue == 0 ? 0.0 : values[i] / maxValue;
      final barHeight = ratio * availableHeight;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(slot * i + slot * .25, size.height - 24 - barHeight, slot * .5, barHeight),
        const Radius.circular(6),
      );
      canvas.drawRRect(rect, barPaint);
      final label = DateTime.now().subtract(Duration(days: 6 - i));
      textPainter.text = TextSpan(
        text: '${label.day}/${label.month}',
        style: const TextStyle(color: Colors.grey, fontSize: 9),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(slot * i + (slot - textPainter.width) / 2, size.height - 18));
    }
  }

  @override
  bool shouldRepaint(covariant _SalesChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}
