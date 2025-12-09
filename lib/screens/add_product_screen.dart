import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController costPriceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    costPriceController.dispose();
    stockController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final product = ProductModel(
      id: '', // akan di-generate Firestore
      name: nameController.text.trim(),
      category: categoryController.text.trim(),
      price: double.tryParse(priceController.text) ?? 0,
      costPrice: double.tryParse(costPriceController.text) ?? 0,
      stock: int.tryParse(stockController.text) ?? 0,
      description: descriptionController.text.trim(),
      imageUrl: imageUrlController.text.trim().isNotEmpty
          ? imageUrlController.text.trim()
          : 'https://placehold.co/600x400/33A2FF/ffffff/png?text=PRODUCT',
      rating: 0.0,
      reviewCount: 0,
      createdAt: DateTime.now(),
    );

    final productProvider =
    Provider.of<ProductProvider>(context, listen: false);

    final success = await productProvider.addProduct(product);

    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil ditambahkan!')),
      );
      Navigator.of(context).pop(); // Kembali ke layar sebelumnya
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Gagal menambahkan produk: ${productProvider.errorMessage}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Produk"),
        backgroundColor: Colors.red.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Nama Produk",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value!.isEmpty ? "Nama produk wajib diisi" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: "Kategori",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value!.isEmpty ? "Kategori wajib diisi" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: "Harga Jual",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? "Harga jual wajib diisi" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: costPriceController,
                decoration: const InputDecoration(
                  labelText: "Harga Modal",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? "Harga modal wajib diisi" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: stockController,
                decoration: const InputDecoration(
                  labelText: "Stok",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? "Stok wajib diisi" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: "Deskripsi",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: imageUrlController,
                decoration: const InputDecoration(
                  labelText: "URL Gambar (Opsional)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : const Text("Simpan Produk"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
