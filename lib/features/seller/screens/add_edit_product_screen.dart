import 'dart:math';
import 'package:flutter/material.dart';
import 'package:snack_bazaar/core/theme/app_colors.dart';
import 'package:snack_bazaar/features/seller/models/seller_product.dart';
import 'package:snack_bazaar/features/seller/screens/product_management_tab.dart';
import 'package:snack_bazaar/features/seller/services/seller_product_repository.dart';

class AddEditProductScreen extends StatefulWidget {
  final SellerProduct? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  // Firestore repository instance for saving/updating products
  final SellerProductRepository _productRepository = SellerProductRepository();

  late String _name;
  late String _description;
  late String _category;
  late int _stockQuantity;
  late double _price;
  late String _imageKey;

  final List<String> _categories = ['Chips', 'Snacks', 'Breads', 'Cookies', 'Cakes', 'Pickles', 'Sweets'];
  bool _hasImage = true;

  // Tracks whether a Firestore save/update operation is in progress
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = p?.name ?? '';
    _description = p?.description ?? '';
    _category = p?.category ?? 'Chips';
    if (!_categories.contains(_category)) {
      _category = _categories.first;
    }
    _stockQuantity = p?.stockQuantity ?? 10;
    _price = p?.price ?? 4.99;
    _imageKey = p?.imageKey ?? 'banana_chips';
  }

  /// Validates the form fields and saves/updates the product in Firestore.
  /// Shows a loading indicator during the operation and handles errors gracefully.
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // Prevent duplicate taps while saving
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    // Determine an imageKey based on category if creating new
    if (widget.product == null) {
      switch (_category.toLowerCase()) {
        case 'chips':
          _imageKey = 'banana_chips';
          break;
        case 'snacks':
          _imageKey = 'pretzels';
          break;
        case 'breads':
          _imageKey = 'sourdough';
          break;
        case 'cookies':
          _imageKey = 'cookies';
          break;
        case 'cakes':
          _imageKey = 'cake';
          break;
        case 'pickles':
          _imageKey = 'pickle';
          break;
        default:
          _imageKey = 'peanuts';
          break;
      }
    }

    final savedProduct = SellerProduct(
      id: widget.product?.id ?? 'p_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(100)}',
      name: _name,
      description: _description,
      price: _price,
      category: _category,
      stockQuantity: _stockQuantity,
      rating: widget.product?.rating ?? 5.0,
      imageKey: _hasImage ? _imageKey : 'default',
    );

    try {
      if (widget.product == null) {
        // CREATE: Add a new product document to Firestore
        await _productRepository.addProduct(savedProduct);
      } else {
        // UPDATE: Update the existing product document in Firestore
        await _productRepository.updateProduct(savedProduct);
      }

      if (!mounted) return;
      // Return true to signal success to the calling screen
      Navigator.pop(context, true);
    } catch (e) {
      // Handle Firestore errors gracefully with a user-visible message
      setState(() {
        _isSaving = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.product == null
                ? 'Failed to add product. Please try again.'
                : 'Failed to update product. Please try again.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.product != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Edit Product' : 'Add Product',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: const Text(
                'B',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image Editor Section
                const Text(
                  'Product Image',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                _buildImageSection(),
                const SizedBox(height: 24),

                // Product Name Field
                _buildLabel('Product Name'),
                TextFormField(
                  initialValue: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: _buildInputDecoration('e.g. Spicy Banana Chips'),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Product name is required';
                    return null;
                  },
                  onSaved: (val) => _name = val!.trim(),
                ),
                const SizedBox(height: 18),

                // Description Field
                _buildLabel('Product Description'),
                TextFormField(
                  initialValue: _description,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _buildInputDecoration('Enter product ingredients, texture, flavor notes, etc.'),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Description is required';
                    return null;
                  },
                  onSaved: (val) => _description = val!.trim(),
                ),
                const SizedBox(height: 18),

                // Category and Stock Quantity Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Category'),
                          DropdownButtonFormField<String>(
                            initialValue: _category,
                            items: _categories.map((cat) {
                              return DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              );
                            }).toList(),
                            decoration: _buildInputDecoration(''),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _category = val;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Stock Qty'),
                          TextFormField(
                            initialValue: _stockQuantity.toString(),
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDecoration('e.g. 25'),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Required';
                              final num = int.tryParse(val.trim());
                              if (num == null || num < 0) return 'Invalid';
                              return null;
                            },
                            onSaved: (val) => _stockQuantity = int.parse(val!.trim()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Price Field
                _buildLabel('Price (USD)'),
                TextFormField(
                  initialValue: isEdit ? _price.toStringAsFixed(2) : '',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: _buildInputDecoration('e.g. 4.99').copyWith(
                    prefixText: '\$ ',
                    prefixStyle: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Price is required';
                    final num = double.tryParse(val.trim().replaceAll('\$', ''));
                    if (num == null || num <= 0) return 'Enter a valid price';
                    return null;
                  },
                  onSaved: (val) => _price = double.parse(val!.trim().replaceAll('\$', '')),
                ),
                const SizedBox(height: 36),

                // Action Buttons — shows a loading indicator when saving to Firestore
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            isEdit ? 'Update Product' : 'Add Product',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Discard Changes',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13.5, fontWeight: FontWeight.w400),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_hasImage)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SnackVisualThumbnail(imageKey: _imageKey, size: 90),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _hasImage = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mock: Image removed'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(foregroundColor: AppColors.error),
                      child: const Text('Remove', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mock: Select a photo from system gallery'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.border,
                        foregroundColor: AppColors.textPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Change Photo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    ),
                  ],
                ),
              ],
            )
          else
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined, size: 48, color: AppColors.textTertiary.withValues(alpha: 0.5)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _hasImage = true;
                    });
                  },
                  icon: const Icon(Icons.upload, size: 16),
                  label: const Text('Add Product Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
