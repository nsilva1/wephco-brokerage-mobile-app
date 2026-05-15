import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/property_provider.dart';
import '../../models/property.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _developerController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _yieldController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedStatus = 'Available';
  String _selectedCurrency = 'NGN';
  String _selectedTag = 'Local';
  String _selectedCategory = 'Sale';

  // Multi-image support
  final List<File> _selectedImages = [];

  File? _selectedPdf;
  String? _selectedPdfName;
  bool _isSubmitting = false;

  static const List<String> _statuses = ['Available', 'Under Offer', 'Sold'];
  static const List<String> _currencies = ['NGN', 'USD'];
  static const List<String> _tags = ['Local', 'International'];
  static const List<String> _categories = ['Rent', 'Lease', 'Sale'];

  @override
  void dispose() {
    _titleController.dispose();
    _developerController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _yieldController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) {
      setState(() {
        // Deduplicate: avoid adding the same path twice
        final existingPaths = _selectedImages.map((f) => f.path).toSet();
        for (final xFile in picked) {
          if (!existingPaths.contains(xFile.path)) {
            _selectedImages.add(File(xFile.path));
          }
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedPdf = File(result.files.single.path!);
        _selectedPdfName = result.files.single.name;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one property image."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final error = await context.read<PropertyProvider>().addProperty(
      imageFiles: _selectedImages,
      pdfFile: _selectedPdf,
      property: Property(
        title: _titleController.text.trim(),
        developer: _developerController.text.trim(),
        location: _locationController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        yieldValue: _yieldController.text.trim().isNotEmpty
            ? double.tryParse(_yieldController.text.trim())
            : null,
        status: _selectedStatus,
        description: _descriptionController.text.trim(),
        images: const [],  // provider fills these after upload
        currency: _selectedCurrency,
        tag: _selectedTag,
        pdfUrl: '',
        category: _selectedCategory,
        verified: false,
      ),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Property added successfully."),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Add Property",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image picker ─────────────────────────────────────────────
              _sectionLabel("Property Images"),
              _imagePickerSection(),
              const SizedBox(height: 24),

              // ── Basic Info ───────────────────────────────────────────────
              _sectionLabel("Basic Information"),
              _card(children: [
                _textField(
                  controller: _titleController,
                  label: "Property Title",
                  icon: Icons.home_outlined,
                  validator: (v) =>
                      v!.isEmpty ? "Enter property title" : null,
                ),
                const SizedBox(height: 16),
                _textField(
                  controller: _developerController,
                  label: "Developer",
                  icon: Icons.business_outlined,
                  validator: (v) =>
                      v!.isEmpty ? "Enter developer name" : null,
                ),
                const SizedBox(height: 16),
                _textField(
                  controller: _locationController,
                  label: "Location",
                  icon: Icons.location_on_outlined,
                  validator: (v) => v!.isEmpty ? "Enter location" : null,
                ),
              ]),
              const SizedBox(height: 16),

              // ── Pricing ──────────────────────────────────────────────────
              _sectionLabel("Pricing"),
              _card(children: [
                Row(
                  children: [
                    Expanded(
                      child: _textField(
                        controller: _priceController,
                        label: "Price",
                        icon: Icons.payments_outlined,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (v) {
                          if (v!.isEmpty) return "Enter price";
                          if (double.tryParse(v) == null) {
                            return "Invalid price";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dropdown(
                        label: "Currency",
                        value: _selectedCurrency,
                        items: _currencies,
                        onChanged: (v) =>
                            setState(() => _selectedCurrency = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _textField(
                  controller: _yieldController,
                  label: "Expected Yield % (optional)",
                  icon: Icons.trending_up_outlined,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                ),
              ]),
              const SizedBox(height: 16),

              // ── Classification ───────────────────────────────────────────
              _sectionLabel("Classification"),
              _card(children: [
                _dropdown(
                  label: "Status",
                  value: _selectedStatus,
                  items: _statuses,
                  onChanged: (v) => setState(() => _selectedStatus = v!),
                  icon: Icons.flag_outlined,
                ),
                const SizedBox(height: 16),
                _dropdown(
                  label: "Tag",
                  value: _selectedTag,
                  items: _tags,
                  onChanged: (v) => setState(() => _selectedTag = v!),
                  icon: Icons.label_outline,
                ),
                const SizedBox(height: 16),
                _dropdown(
                  label: "Category",
                  value: _selectedCategory,
                  items: _categories,
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                  icon: Icons.category_outlined,
                ),
              ]),
              const SizedBox(height: 16),

              // ── Description ──────────────────────────────────────────────
              _sectionLabel("Description"),
              _card(children: [
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: _inputDecoration(
                      "Describe the property...",
                      Icons.description_outlined),
                  validator: (v) =>
                      v!.isEmpty ? "Enter a description" : null,
                ),
              ]),
              const SizedBox(height: 16),

              // ── Documents ────────────────────────────────────────────────
              _sectionLabel("Documents (Optional)"),
              _card(children: [
                GestureDetector(
                  onTap: _pickPdf,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedPdf != null
                            ? Theme.of(context).primaryColor
                            : Colors.grey[200]!,
                        width: _selectedPdf != null ? 2 : 1.5,
                      ),
                      color: const Color(0xFFF8FAFC),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.picture_as_pdf_outlined,
                          color: _selectedPdf != null
                              ? Theme.of(context).primaryColor
                              : Colors.blueGrey,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedPdfName ??
                                "Tap to select brochure PDF",
                            style: TextStyle(
                              color: _selectedPdf != null
                                  ? const Color(0xFF1A1C1E)
                                  : Colors.grey[500],
                              fontSize: 14,
                              fontWeight: _selectedPdf != null
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_selectedPdf != null)
                          GestureDetector(
                            onTap: () => setState(() {
                              _selectedPdf = null;
                              _selectedPdfName = null;
                            }),
                            child: const Icon(Icons.close,
                                size: 18, color: Colors.blueGrey),
                          )
                        else
                          const Icon(Icons.chevron_right,
                              color: Colors.blueGrey, size: 18),
                      ],
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 32),

              // ── Submit ───────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Add Property",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Multi-image picker section ─────────────────────────────────────────────
  Widget _imagePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail row
        if (_selectedImages.isNotEmpty)
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length + 1, // +1 for "add more" tile
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                if (index == _selectedImages.length) {
                  return _addMoreTile();
                }
                return _imageThumbnail(index);
              },
            ),
          )
        else
          // Empty state — tap to pick
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: const Color(0xFFE2E8F0), width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    "Tap to select images",
                    style:
                        TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "You can select multiple",
                    style:
                        TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            "${_selectedImages.length} image${_selectedImages.length == 1 ? '' : 's'} selected  •  Tap × to remove",
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _imageThumbnail(int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            _selectedImages[index],
            width: 110,
            height: 110,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close,
                  size: 14, color: Colors.white),
            ),
          ),
        ),
        // "Cover" label on first image
        if (index == 0)
          Positioned(
            bottom: 6,
            left: 6,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF061A0A).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                "Cover",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }

  Widget _addMoreTile() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                size: 28, color: Colors.grey[400]),
            const SizedBox(height: 4),
            Text("Add more",
                style:
                    TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.blueGrey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: _inputDecoration(label, icon),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    IconData? icon,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items
          .map((item) =>
              DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      decoration:
          _inputDecoration(label, icon ?? Icons.arrow_drop_down),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle:
          const TextStyle(fontSize: 14, color: Colors.blueGrey),
      floatingLabelStyle:
          TextStyle(color: Theme.of(context).primaryColor),
      prefixIcon: Icon(icon, size: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: Colors.grey[200]!, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color: Theme.of(context).primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: Colors.red.shade300, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: Colors.red.shade400, width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
    );
  }
}