import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/property_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/property.dart';

/// Text controllers for one row in the "Units" section.
class _UnitControllers {
  final bedroom = TextEditingController();
  final bathroom = TextEditingController();
  final squareFoot = TextEditingController();

  bool get isEmpty =>
      bedroom.text.trim().isEmpty &&
      bathroom.text.trim().isEmpty &&
      squareFoot.text.trim().isEmpty;

  PropertyUnit toUnit() => PropertyUnit(
        bedroom: bedroom.text.trim(),
        bathroom: bathroom.text.trim(),
        squareFoot: squareFoot.text.trim(),
      );

  void dispose() {
    bedroom.dispose();
    bathroom.dispose();
    squareFoot.dispose();
  }
}

/// Adds a new property, or edits [property] when one is passed in
/// (developers editing their own listings).
class AddPropertyScreen extends StatefulWidget {
  final Property? property;

  const AddPropertyScreen({super.key, this.property});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _developerController = TextEditingController();
  final _locationController = TextEditingController();
  final _googleMapLocationController = TextEditingController();
  final _priceController = TextEditingController();
  final _yieldController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _bedroomController = TextEditingController();
  final _bathroomController = TextEditingController();
  final _squareFootController = TextEditingController();
  final _agentNameController = TextEditingController();
  final _agentEmailController = TextEditingController();
  final _agentPhoneController = TextEditingController();
  final List<_UnitControllers> _units = [];

  String _selectedStatus = 'Available';
  String _selectedCurrency = 'NGN';
  String _selectedTag = 'Local';
  String _selectedCategory = 'Sale';

  // Multi-image support. When editing, already-uploaded images come first.
  final List<String> _existingImageUrls = [];
  final List<File> _selectedImages = [];

  int get _imageCount => _existingImageUrls.length + _selectedImages.length;

  /// Brochure already on the listing being edited; cleared to remove it.
  String _existingPdfUrl = '';
  File? _selectedPdf;

  bool get _hasPdf => _selectedPdf != null || _existingPdfUrl.isNotEmpty;
  String? _selectedPdfName;
  bool _isSubmitting = false;

  static const List<String> _statuses = ['Available', 'Under Offer', 'Sold'];
  static const List<String> _currencies = ['NGN', 'USD'];
  static const List<String> _tags = ['Local', 'International'];
  static const List<String> _categories = ['Rent', 'Lease', 'Sale'];

  /// Set when a Developer account is listing its own property.
  String _developerId = '';

  bool get _isEditing => widget.property != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.property;
    if (existing != null) {
      _prefill(existing);
      return;
    }

    final user = context.read<UserProvider>().currentUser;
    if (user == null) return;

    if (user.role == 'Developer') {
      // Ties the listing to the developer's portfolio.
      _developerId = user.id;
      _developerController.text = user.name;
    } else {
      // The agent listing the property is usually the logged-in user.
      _agentNameController.text = user.name;
      _agentEmailController.text = user.email;
      _agentPhoneController.text = user.phone;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _developerController.dispose();
    _locationController.dispose();
    _googleMapLocationController.dispose();
    _priceController.dispose();
    _yieldController.dispose();
    _descriptionController.dispose();
    _bedroomController.dispose();
    _bathroomController.dispose();
    _squareFootController.dispose();
    _agentNameController.dispose();
    _agentEmailController.dispose();
    _agentPhoneController.dispose();
    for (final unit in _units) {
      unit.dispose();
    }
    super.dispose();
  }

  void _prefill(Property p) {
    _developerId = p.developerId;
    _titleController.text = p.title;
    _developerController.text = p.developer;
    _locationController.text = p.location;
    _googleMapLocationController.text = p.googleMapLocation;
    _priceController.text = _formatNumber(p.price);
    _yieldController.text =
        p.yieldValue == null ? '' : _formatNumber(p.yieldValue!);
    _descriptionController.text = p.description;
    _bedroomController.text = p.bedroom.join(', ');
    _bathroomController.text = p.bathroom.join(', ');
    _squareFootController.text = p.squareFoot.join(', ');
    _agentNameController.text = p.agent?.name ?? '';
    _agentEmailController.text = p.agent?.email ?? '';
    _agentPhoneController.text = p.agent?.phone ?? '';
    for (final unit in p.units) {
      _units.add(_UnitControllers()
        ..bedroom.text = unit.bedroom
        ..bathroom.text = unit.bathroom
        ..squareFoot.text = unit.squareFoot);
    }

    // The web dashboard can store values like 'available', so match loosely
    // — a dropdown value missing from its items would throw.
    _selectedStatus = _matchOption(p.status, _statuses, _selectedStatus);
    _selectedCurrency = _matchOption(p.currency, _currencies, _selectedCurrency);
    _selectedTag = _matchOption(p.tag, _tags, _selectedTag);
    _selectedCategory = _matchOption(p.category, _categories, _selectedCategory);

    _existingImageUrls.addAll(p.images);
    _existingPdfUrl = p.pdfUrl;
  }

  String _matchOption(String value, List<String> options, String fallback) {
    return options.firstWhere(
      (o) => o.toLowerCase() == value.trim().toLowerCase(),
      orElse: () => fallback,
    );
  }

  /// 2500000.0 → "2500000", 7.5 → "7.5" (fits the price input formatter).
  String _formatNumber(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2).replaceFirst(RegExp(r'0$'), '');

  void _addUnit() => setState(() => _units.add(_UnitControllers()));

  void _removeUnit(int index) {
    setState(() => _units.removeAt(index).dispose());
  }

  /// "2, 3, 4" → ['2', '3', '4']
  List<String> _splitValues(TextEditingController controller) => controller
      .text
      .split(',')
      .map((v) => v.trim())
      .where((v) => v.isNotEmpty)
      .toList();

  PropertyAgent? _buildAgent() {
    final name = _agentNameController.text.trim();
    final email = _agentEmailController.text.trim();
    final phone = _agentPhoneController.text.trim();
    if (name.isEmpty && email.isEmpty && phone.isEmpty) return null;
    return PropertyAgent(name: name, email: email, phone: phone);
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return null;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
        ? null
        : "Enter a valid email";
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

  /// [index] runs across existing images first, then newly picked files.
  void _removeImage(int index) {
    setState(() {
      if (index < _existingImageUrls.length) {
        _existingImageUrls.removeAt(index);
      } else {
        _selectedImages.removeAt(index - _existingImageUrls.length);
      }
    });
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

  /// Optional field — only validated when the agent typed something.
  String? _validateMapLink(String? value) {
    final link = value?.trim() ?? '';
    if (link.isEmpty) return null;

    final uri = Uri.tryParse(link);
    if (uri == null || !uri.hasAuthority || !uri.scheme.startsWith('http')) {
      return "Enter a full link, e.g. https://maps.app.goo.gl/...";
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one property image."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final provider = context.read<PropertyProvider>();
    final currentUserId = context.read<UserProvider>().currentUser?.id ?? '';
    final property = Property(
      id: widget.property?.id,
      title: _titleController.text.trim(),
      developer: _developerController.text.trim(),
      location: _locationController.text.trim(),
      googleMapLocation: _googleMapLocationController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      yieldValue: _yieldController.text.trim().isNotEmpty
          ? double.tryParse(_yieldController.text.trim())
          : null,
      status: _selectedStatus,
      description: _descriptionController.text.trim(),
      images: const [], // provider fills these after upload
      currency: _selectedCurrency,
      tag: _selectedTag,
      pdfUrl: '',
      category: _selectedCategory,
      verified: false, // provider keeps the stored value when editing
      bedroom: _splitValues(_bedroomController),
      bathroom: _splitValues(_bathroomController),
      squareFoot: _splitValues(_squareFootController),
      units: _units
          .where((u) => !u.isEmpty)
          .map((u) => u.toUnit())
          .toList(),
      agent: _buildAgent(),
      developerId: _developerId,
    );

    final error = _isEditing
        ? await provider.updateProperty(
            property: property,
            developerId: currentUserId,
            keptImageUrls: _existingImageUrls,
            newImageFiles: _selectedImages,
            newPdfFile: _selectedPdf,
            removePdf: _existingPdfUrl.isEmpty && _selectedPdf == null,
          )
        : await provider.addProperty(
            imageFiles: _selectedImages,
            pdfFile: _selectedPdf,
            property: property,
          );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? "Changes saved."
              : _developerId.isNotEmpty
                  ? "Property submitted. It will go live once the Wephco team approves it."
                  : "Property added successfully."),
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
        title: Text(_isEditing ? "Edit Property" : "Add Property",
            style: const TextStyle(fontWeight: FontWeight.bold)),
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
                const SizedBox(height: 16),
                _textField(
                  controller: _googleMapLocationController,
                  label: "Google Maps Link (optional)",
                  icon: Icons.map_outlined,
                  keyboardType: TextInputType.url,
                  validator: _validateMapLink,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 12, top: 6),
                  child: Text(
                    "Paste the share link from Google Maps, e.g. https://maps.app.goo.gl/gHfd2k4Mmwopij2V6",
                    style: TextStyle(fontSize: 11, color: Colors.blueGrey),
                  ),
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

              // ── Property Details ─────────────────────────────────────────
              _sectionLabel("Property Details (Optional)"),
              _card(children: [
                Row(
                  children: [
                    Expanded(
                      child: _textField(
                        controller: _bedroomController,
                        label: "Bedrooms",
                        icon: Icons.bed_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _textField(
                        controller: _bathroomController,
                        label: "Bathrooms",
                        icon: Icons.bathtub_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _textField(
                  controller: _squareFootController,
                  label: "Size (sq ft)",
                  icon: Icons.square_foot_outlined,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 12, top: 6),
                  child: Text(
                    "Separate multiple options with commas, e.g. 2, 3, 4",
                    style: TextStyle(fontSize: 11, color: Colors.blueGrey),
                  ),
                ),
              ]),
              const SizedBox(height: 16),

              // ── Units ────────────────────────────────────────────────────
              _sectionLabel("Units (Optional)"),
              _card(children: [
                for (var i = 0; i < _units.length; i++) ...[
                  _unitRow(i),
                  const SizedBox(height: 12),
                ],
                TextButton.icon(
                  onPressed: _addUnit,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(_units.isEmpty ? "Add unit type" : "Add another unit"),
                ),
              ]),
              const SizedBox(height: 16),

              // ── Listing Agent ────────────────────────────────────────────
              _sectionLabel("Listing Agent (Optional)"),
              _card(children: [
                _textField(
                  controller: _agentNameController,
                  label: "Agent Name",
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _textField(
                  controller: _agentEmailController,
                  label: "Agent Email",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                _textField(
                  controller: _agentPhoneController,
                  label: "Agent Phone",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
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
                        color: _hasPdf
                            ? Theme.of(context).primaryColor
                            : Colors.grey[200]!,
                        width: _hasPdf ? 2 : 1.5,
                      ),
                      color: const Color(0xFFF8FAFC),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.picture_as_pdf_outlined,
                          color: _hasPdf
                              ? Theme.of(context).primaryColor
                              : Colors.blueGrey,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedPdfName ??
                                (_existingPdfUrl.isNotEmpty
                                    ? "Current brochure (tap to replace)"
                                    : "Tap to select brochure PDF"),
                            style: TextStyle(
                              color: _hasPdf
                                  ? const Color(0xFF1A1C1E)
                                  : Colors.grey[500],
                              fontSize: 14,
                              fontWeight: _hasPdf
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_hasPdf)
                          GestureDetector(
                            onTap: () => setState(() {
                              _selectedPdf = null;
                              _selectedPdfName = null;
                              _existingPdfUrl = '';
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
                      : Text(
                          _isEditing ? "Save Changes" : "Add Property",
                          style: const TextStyle(
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
        if (_imageCount > 0)
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _imageCount + 1, // +1 for "add more" tile
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                if (index == _imageCount) {
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
        if (_imageCount > 0) ...[
          const SizedBox(height: 8),
          Text(
            "$_imageCount image${_imageCount == 1 ? '' : 's'} selected  •  Tap × to remove",
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
          child: index < _existingImageUrls.length
              ? Image.network(
                  _existingImageUrls[index],
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 110,
                    height: 110,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.grey),
                  ),
                )
              : Image.file(
                  _selectedImages[index - _existingImageUrls.length],
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

  Widget _unitRow(int index) {
    final unit = _units[index];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _textField(
            controller: unit.bedroom,
            label: "Beds",
            icon: Icons.bed_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _textField(
            controller: unit.bathroom,
            label: "Baths",
            icon: Icons.bathtub_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _textField(
            controller: unit.squareFoot,
            label: "Sq ft",
            icon: Icons.square_foot_outlined,
          ),
        ),
        IconButton(
          tooltip: "Remove unit",
          onPressed: () => _removeUnit(index),
          icon: const Icon(Icons.remove_circle_outline,
              color: Colors.redAccent),
        ),
      ],
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