import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(const MyApp());
}

class Product {
  int? id;
  String name;
  double price;
  String description;
  List<String> images;
  String category;
  bool discount;
  DateTime? promoTime;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.images,
    required this.category,
    required this.discount,
    this.promoTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'images': images.join(','),
      'category': category,
      'discount': discount ? 1 : 0,
      'promoTime': promoTime?.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      description: map['description'],
      images: map['images'].isNotEmpty ? map['images'].split(',') : [],
      category: map['category'],
      discount: map['discount'] == 1,
      promoTime:
      map['promoTime'] != null ? DateTime.tryParse(map['promoTime']) : null,
    );
  }
}

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'products.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE products(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          price REAL,
          description TEXT,
          images TEXT,
          category TEXT,
          discount INTEGER,
          promoTime TEXT
        )
      ''');
    });
  }

  static Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  static Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update('products', product.toMap(),
        where: 'id = ?', whereArgs: [product.id]);
  }

  static Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Product CRUD",
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const ProductListPage(),
    );
  }
}

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});
  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final data = await DBHelper.getProducts();
    setState(() {
      products = data;
    });
  }

  void deleteProduct(int id) async {
    await DBHelper.deleteProduct(id);
    loadProducts();
  }

  void openForm({Product? product}) async {
    await Navigator.push(
      context as BuildContext,
      MaterialPageRoute(
        builder: (_) => ProductFormPage(product: product),
      ),
    );
    loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Product List")),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, i) {
          final p = products[i];
          return Card(
            child: ListTile(
              leading: p.images.isNotEmpty
                  ? Image.file(File(p.images.first), width: 50, height: 50)
                  : const Icon(Icons.image, size: 40),
              title: Text(p.name),
              subtitle: Text("${p.price} - ${p.category}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => openForm(product: p)),
                  IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteProduct(p.id!)),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ProductFormPage extends StatefulWidget {
  final Product? product;
  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  String name = "";
  double price = 0;
  String description = "";
  List<String> images = [];
  String category = "Food";
  bool discount = false;
  DateTime? promoTime;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      final p = widget.product!;
      name = p.name;
      price = p.price;
      description = p.description;
      images = List.from(p.images);
      category = p.category;
      discount = p.discount;
      promoTime = p.promoTime;
    }
  }

  Future<void> pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        images.addAll(picked.map((e) => e.path));
      });
    }
  }

  Future<void> takePhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        images.add(picked.path);
      });
    }
  }

  void saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final newProduct = Product(
      id: widget.product?.id,
      name: name,
      price: price,
      description: description,
      images: images,
      category: category,
      discount: discount,
      promoTime: discount ? promoTime : null,
    );

    if (widget.product == null) {
      await DBHelper.insertProduct(newProduct);
    } else {
      await DBHelper.updateProduct(newProduct);
    }

    Navigator.pop(context as BuildContext);
  }

  Future<void> pickPromoDate() async {
    final date = await showDatePicker(
      context: context as BuildContext,
      initialDate: promoTime ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context as BuildContext,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          promoTime = DateTime(
              date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? "Add Product" : "Edit Product"),
        actions: [
          IconButton(onPressed: saveProduct, icon: const Icon(Icons.save))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: "Product Name"),
                validator: (v) =>
                v == null || v.isEmpty ? "Enter product name" : null,
                onSaved: (v) => name = v!,
              ),
              TextFormField(
                initialValue: price.toString(),
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                validator: (v) =>
                v == null || double.tryParse(v) == null ? "Enter price" : null,
                onSaved: (v) => price = double.parse(v!),
              ),
              TextFormField(
                initialValue: description,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
                onSaved: (v) => description = v ?? "",
              ),
              const SizedBox(height: 10),
              Wrap(
                children: images
                    .map((path) => Padding(
                  padding: const EdgeInsets.all(4),
                  child: Image.file(File(path), width: 80, height: 80),
                ))
                    .toList(),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                      onPressed: pickImages,
                      icon: const Icon(Icons.upload),
                      label: const Text("Upload Images")),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                      onPressed: takePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Take Photo")),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: category,
                items: ["Food", "Drink", "Other"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => category = v!),
                decoration: const InputDecoration(labelText: "Category"),
              ),
              SwitchListTile(
                value: discount,
                onChanged: (v) => setState(() => discount = v),
                title: const Text("Discount Offer"),
              ),
              if (discount)
                ListTile(
                  title: Text(promoTime == null
                      ? "Pick promo time"
                      : "Promo until: ${promoTime.toString()}"),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: pickPromoDate,
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: saveProduct, child: const Text("Save Product")),
            ],
          ),
        ),
      ),
    );
  }
}
