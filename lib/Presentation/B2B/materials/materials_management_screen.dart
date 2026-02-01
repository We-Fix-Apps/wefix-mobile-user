import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Bookings/bookings_apis.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Business/end_points.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/language_icon.dart' as lang;
import 'package:wefix/Presentation/appointment/Components/attachments_widget.dart';
import 'package:wefix/l10n/app_localizations.dart';
import 'material_bottom_sheet.dart';

// Theme colors matching frontend-oms
const Color _orangeColor = Color(0xFFff6b35); // Orange from frontend-oms
const Color _purpleColor = Color(0xFF7c5cdb); // Purple from frontend-oms

class MaterialsManagementScreen extends StatefulWidget {
  final String ticketId;
  final bool canManage; // true for white label, false for B2B (view-only)

  const MaterialsManagementScreen({
    super.key,
    required this.ticketId,
    this.canManage = true,
  });

  @override
  State<MaterialsManagementScreen> createState() =>
      _MaterialsManagementScreenState();
}

class _MaterialsManagementScreenState extends State<MaterialsManagementScreen> {
  bool loading = false;
  List<Map<String, dynamic>> materials = [];

  @override
  void initState() {
    super.initState();
    log('MaterialsManagementScreen - canManage: ${widget.canManage}, ticketId: ${widget.ticketId}');
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    setState(() {
      loading = true;
    });

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final result = await BookingApi.getMaterialsByTicketId(
        ticketId: int.parse(widget.ticketId),
        token: appProvider.accessToken ?? appProvider.userModel?.token ?? "",
        context: context,
      );

      if (mounted) {
        setState(() {
          if (result != null && result['materials'] != null) {
            materials = List<Map<String, dynamic>>.from(result['materials']);
          } else {
            materials = [];
          }
          loading = false;
        });
      }
    } catch (e) {
      log('Error loading materials: $e');
      setState(() {
        loading = false;
      });
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations?.errorLoadingMaterials ?? 'Error loading materials: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showMaterialBottomSheet({Map<String, dynamic>? material}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MaterialBottomSheet(
        ticketId: widget.ticketId,
        material: material,
        onSaved: () async {
          // Small delay to ensure backend has processed the request
          await Future.delayed(const Duration(milliseconds: 300));
          if (mounted) {
            _loadMaterials();
          }
        },
      ),
    );
  }

  void _deleteMaterial(String materialId) async {
    // Show confirmation dialog
    final localizations = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          localizations?.confirmDelete ?? "Confirm Delete",
        ),
        content: Text(
          localizations?.areYouSureDeleteMaterial ?? "Are you sure you want to delete this material?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              localizations?.cancel ?? "Cancel",
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(
              localizations?.delete ?? "Delete",
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      loading = true;
    });

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final success = await BookingApi.deleteMaterial(
        materialId: int.parse(materialId),
        token: appProvider.accessToken ?? appProvider.userModel?.token ?? "",
        context: context,
      );

      final localizations = AppLocalizations.of(context);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                localizations?.materialDeletedSuccessfully ?? "Material deleted successfully",
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
        _loadMaterials();
      } else {
        setState(() {
          loading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations?.errorLoadingMaterials ?? 'Failed to delete material'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      log('Error deleting material: $e');
      setState(() {
        loading = false;
      });
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations?.errorLoadingMaterials ?? 'Error deleting material: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatNumber(dynamic value) {
    if (value == null) return '0';
    final num = double.tryParse(value.toString()) ?? 0;
    if (num == num.roundToDouble()) {
      return num.toInt().toString();
    }
    return num.toStringAsFixed(2).replaceAll(RegExp(r'\.?0*$'), '');
  }

  String _formatAmount(dynamic value) {
    return '${_formatNumber(value)} JOD';
  }

  double _calculateTotalAmount() {
    double total = 0;
    for (var material in materials) {
      final totalAmount = material['totalAmount'];
      if (totalAmount != null) {
        total += double.tryParse(totalAmount.toString()) ?? 0;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final localizations = AppLocalizations.of(context);
        final isArabic = languageProvider.lang == "ar";

        return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey[200],
        leading: IconButton(
          icon: Icon(
            isArabic ? Icons.arrow_forward : Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          localizations?.materialsManagement ?? "Materials Management",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          lang.LanguageButton(),
          SizedBox(width: 8),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : materials.isEmpty
              ? _buildEmptyState(localizations, isArabic)
              : _buildMaterialsList(localizations, isArabic),
        );
      },
    );
  }

  Widget _buildEmptyState(AppLocalizations? localizations, bool isArabic) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 100,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 24),
              Text(
                localizations?.noMaterialsAddedYet ?? "No Materials Added Yet",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                localizations?.tapAddMaterialButton ?? "Tap 'Add Material' button to add your first material",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 32),
              CustomBotton(
                title: localizations?.addMaterial ?? "Add Material",
                onTap: () => _showMaterialBottomSheet(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialsList(AppLocalizations? localizations, bool isArabic) {
    final calculatedTotal = _calculateTotalAmount();
    final materialsCount = materials.length;
    
    return RefreshIndicator(
      onRefresh: _loadMaterials,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: materials.length + 
            (widget.canManage && materials.isNotEmpty ? 1 : 0) + // Add Material button
            1, // Total summary card
        itemBuilder: (context, index) {
          // Show total summary card at the top
          if (index == 0) {
            return _buildTotalSummaryCard(localizations, isArabic, calculatedTotal, materialsCount);
          }
          
          // Adjust index for Add Material button
          final adjustedIndex = index - 1;
          
          // Show "Add Material" button if user can manage and list is not empty
          if (widget.canManage && materials.isNotEmpty && adjustedIndex == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                onTap: () => _showMaterialBottomSheet(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _orangeColor,
                        _orangeColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _orangeColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        localizations?.addMaterial ?? "Add Material",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          
          // Adjust index for materials list (subtract 1 for total card and 1 for Add Material button if shown)
          final materialIndex = widget.canManage && materials.isNotEmpty 
              ? adjustedIndex - 1 
              : adjustedIndex;
          
          // Safety check to prevent index out of bounds
          if (materialIndex < 0 || materialIndex >= materials.length) {
            return const SizedBox.shrink();
          }
          
          final material = materials[materialIndex];
          final title = material['title'] ?? '';
          final description = material['description'] ?? '';
          final quantity = _formatNumber(material['quantity']);
          
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _orangeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.inventory_2,
                                color: _orangeColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.canManage)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: _purpleColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.edit, color: _purpleColor, size: 20),
                                onPressed: () => _showMaterialBottomSheet(
                                  material: material,
                                ),
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () =>
                                    _deleteMaterial(material['id'].toString()),
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.description,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoChip(
                          localizations?.quantity ?? "Quantity",
                          quantity,
                          Icons.numbers,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoChip(
                          localizations?.amount ?? "Amount",
                          _formatAmount(material['amount']),
                          Icons.attach_money,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoChip(
                    localizations?.total ?? "Total",
                    _formatAmount(material['totalAmount']),
                    Icons.calculate,
                    isHighlighted: true,
                  ),
                  // Show attachments if available
                  if (material['files'] != null && (material['files'] as List).isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildAttachmentsSection(material['files'] as List, localizations),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttachmentsSection(List files, AppLocalizations? localizations) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_file,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                localizations?.filesAttached(files.length) ?? '${files.length} ${files.length == 1 ? 'file' : 'files'} attached',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...files.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            final filePath = file['path']?.toString() ?? '';
            
            // Use abbreviated filename: file-01, file-02, etc.
            final fileName = 'file-${(index + 1).toString().padLeft(2, '0')}';
            
            // Build full URL
            String fullUrl = filePath;
            if (filePath.isNotEmpty && !filePath.startsWith('http')) {
              String baseUrl = EndPoints.mmsBaseUrl.replaceAll('/api/v1/', '').replaceAll(RegExp(r'/$'), '');
              if (filePath.startsWith('/WeFixFiles')) {
                fullUrl = '$baseUrl$filePath';
              } else if (filePath.startsWith('WeFixFiles')) {
                fullUrl = '$baseUrl/$filePath';
              } else {
                fullUrl = '$baseUrl$filePath';
              }
            }
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AttachmentsWidget(
                image: fileName,
                url: fullUrl,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTotalSummaryCard(AppLocalizations? localizations, bool isArabic, double totalAmount, int totalCount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _orangeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.summarize,
                  color: _orangeColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  localizations?.materialsSummary ?? "Materials Summary",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations?.totalItems ?? "Total Items",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalCount',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: 1,
                  height: 50,
                  color: Colors.grey[300],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations?.totalAmount ?? "Total Amount",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatAmount(totalAmount),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _orangeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon,
      {bool isHighlighted = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: isHighlighted
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _orangeColor.withOpacity(0.15),
                  _purpleColor.withOpacity(0.08),
                ],
              )
            : null,
        color: isHighlighted ? null : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted
              ? _orangeColor.withOpacity(0.4)
              : Colors.grey[200]!,
          width: isHighlighted ? 1.5 : 1,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: _orangeColor.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? _orangeColor.withOpacity(0.2)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isHighlighted
                  ? _orangeColor
                  : Colors.grey[700],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isHighlighted
                        ? _orangeColor
                        : Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
