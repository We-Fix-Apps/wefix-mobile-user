import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Bookings/bookings_apis.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/widget_form_text.dart';

class MaterialBottomSheet extends StatefulWidget {
  final String ticketId;
  final Map<String, dynamic>? material; // null for create, non-null for edit
  final VoidCallback onSaved;

  const MaterialBottomSheet({
    super.key,
    required this.ticketId,
    this.material,
    required this.onSaved,
  });

  @override
  State<MaterialBottomSheet> createState() => _MaterialBottomSheetState();
}

class _MaterialBottomSheetState extends State<MaterialBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController amountController;
  late TextEditingController quantityController;
  late TextEditingController totalAmountController;

  bool loading = false;
  List<XFile> selectedFiles = [];

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing material data if editing
    titleController = TextEditingController(
      text: widget.material?['title'] ?? '',
    );
    descriptionController = TextEditingController(
      text: widget.material?['description'] ?? '',
    );
    
    final amount = widget.material?['amount'];
    final quantity = widget.material?['quantity'];
    
    amountController = TextEditingController(
      text: amount != null ? _formatNumber(amount) : '',
    );
    quantityController = TextEditingController(
      text: quantity != null ? quantity.toString() : '',
    );
    
    // Initialize totalAmountController first before calculating total
    totalAmountController = TextEditingController(
      text: widget.material?['totalAmount'] != null
          ? _formatNumber(widget.material!['totalAmount'])
          : '0',
    );
    
    // Calculate initial total amount
    _updateTotalAmount();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    amountController.dispose();
    quantityController.dispose();
    totalAmountController.dispose();
    super.dispose();
  }

  void _updateTotalAmount() {
    final amount = double.tryParse(amountController.text) ?? 0;
    final quantity = int.tryParse(quantityController.text) ?? 0;
    final total = amount * quantity;
    totalAmountController.text = _formatNumber(total);
  }

  String _formatNumber(dynamic value) {
    if (value == null) return '0';
    final num = double.tryParse(value.toString()) ?? 0;
    if (num == num.roundToDouble()) {
      return num.toInt().toString();
    }
    return num.toStringAsFixed(2).replaceAll(RegExp(r'\.?0*$'), '');
  }

  Future<void> _pickFiles() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      
      if (images.isNotEmpty) {
        setState(() {
          selectedFiles.addAll(images);
        });
      }
    } catch (e) {
      log('Error picking files: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking files: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      selectedFiles.removeAt(index);
    });
  }

  Future<void> _saveMaterial() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final token = appProvider.accessToken ?? appProvider.userModel?.token ?? "";

      final title = titleController.text.trim();
      final description = descriptionController.text.trim();
      final amount = double.tryParse(amountController.text) ?? 0;
      final quantity = double.tryParse(quantityController.text) ?? 0;
      final totalAmount = double.tryParse(totalAmountController.text) ?? 0;

      Map<String, dynamic>? result;

      if (widget.material != null) {
        // Update existing material
        result = await BookingApi.updateMaterial(
          materialId: int.parse(widget.material!['id'].toString()),
          title: title,
          description: description.isNotEmpty ? description : null,
          amount: amount,
          quantity: quantity,
          totalAmount: totalAmount,
          token: token,
          context: context,
        );
      } else {
        // Create new material
        result = await BookingApi.createMaterial(
          ticketId: int.parse(widget.ticketId),
          title: title,
          description: description.isNotEmpty ? description : null,
          amount: amount,
          quantity: quantity,
          totalAmount: totalAmount,
          token: token,
          context: context,
        );
      }

      if (result != null) {
        // TODO: Upload files if any (requires file upload API)
        // final materialId = result['id'];
        // if (selectedFiles.isNotEmpty) {
        //   await _uploadFiles(materialId);
        // }

        if (mounted) {
          final languageProvider =
              Provider.of<LanguageProvider>(context, listen: false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.material != null
                    ? (languageProvider.lang == "ar"
                        ? "تم تحديث المادة بنجاح"
                        : "Material updated successfully")
                    : (languageProvider.lang == "ar"
                        ? "تم إضافة المادة بنجاح"
                        : "Material added successfully"),
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
          widget.onSaved();
        }
      } else {
        setState(() {
          loading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save material'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      log('Error saving material: $e');
      setState(() {
        loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving material: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final isArabic = languageProvider.lang == "ar";

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.material != null
                            ? (isArabic ? "تعديل المادة" : "Edit Material")
                            : (isArabic ? "إضافة مادة" : "Add Material"),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    isArabic ? "العنوان *" : "Title *",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  WidgetTextField(
                    isArabic ? "أدخل عنوان المادة" : "Enter material title",
                    controller: titleController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return isArabic ? "العنوان مطلوب" : "Title is required";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    isArabic ? "الوصف" : "Description",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  WidgetTextField(
                    isArabic ? "أدخل وصف المادة" : "Enter material description",
                    controller: descriptionController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Quantity
                  Text(
                    isArabic ? "الكمية *" : "Quantity *",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      hintText: isArabic ? "أدخل الكمية" : "Enter quantity",
                      filled: true,
                      fillColor: AppColors.greyColorback,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return isArabic ? "الكمية مطلوبة" : "Quantity is required";
                      }
                      final quantity = int.tryParse(value);
                      if (quantity == null || quantity < 1) {
                        return isArabic
                            ? "يجب أن تكون الكمية 1 على الأقل"
                            : "Quantity must be at least 1";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _updateTotalAmount();
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Amount
                  Text(
                    isArabic ? "السعر *" : "Amount *",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(
                      hintText: isArabic ? "أدخل السعر" : "Enter amount",
                      filled: true,
                      fillColor: AppColors.greyColorback,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return isArabic ? "السعر مطلوب" : "Amount is required";
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount < 0) {
                        return isArabic
                            ? "السعر يجب أن لا يكون سالب"
                            : "Amount cannot be negative";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _updateTotalAmount();
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Total Amount (Read-only)
                  Text(
                    isArabic ? "المبلغ الإجمالي" : "Total Amount",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: totalAmountController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: isArabic ? "المبلغ الإجمالي" : "Total amount",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // File Upload Section
                  Text(
                    isArabic ? "رفع ملف" : "Upload File",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickFiles,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.greyColorback,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload_file, color: AppColors.secoundryColor),
                          const SizedBox(width: 8),
                          Text(
                            isArabic ? "اضغط لرفع الملفات" : "Tap to upload files",
                            style: TextStyle(
                              color: AppColors.secoundryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Display selected files
                  if (selectedFiles.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedFiles.asMap().entries.map((entry) {
                        final index = entry.key;
                        final file = entry.value;
                        return Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(file.path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: -8,
                              right: -8,
                              child: IconButton(
                                icon: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () => _removeFile(index),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Save Button
                  loading
                      ? const Center(child: CircularProgressIndicator())
                      : CustomBotton(
                          title: widget.material != null
                              ? (isArabic ? "تحديث" : "Update")
                              : (isArabic ? "حفظ" : "Save"),
                          onTap: _saveMaterial,
                        ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
