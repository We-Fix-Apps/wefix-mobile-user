import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/B2b/b2b_api.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/model/branch_model.dart';
import 'package:wefix/Presentation/B2B/branch/add_branch_screen.dart';
import 'package:wefix/Presentation/B2B/branch/branch_details_screen.dart';
import 'package:wefix/l10n/app_localizations.dart';

class BranchesListScreen extends StatefulWidget {
  const BranchesListScreen({super.key});

  @override
  State<BranchesListScreen> createState() => _BranchesListScreenState();
}

class _BranchesListScreenState extends State<BranchesListScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> branches = [
    {
      "image": "https://cdn-icons-png.flaticon.com/512/3570/3570121.png",
      "name": "Downtown Branch",
      "city": "Amman",
      "phone": "+962 79 123 4567",
    },
    {
      "image": "https://cdn-icons-png.flaticon.com/512/684/684908.png",
      "name": "Irbid Branch",
      "city": "Irbid",
      "phone": "+962 79 765 4321",
    },
    {
      "image": "https://cdn-icons-png.flaticon.com/512/741/741407.png",
      "name": "Jerash Branch",
      "city": "Jerash",
      "phone": "+962 79 567 8999",
    },
  ];

  bool? loading = false;
  BranchesModel? branchesModel;

  @override
  void initState() {
    getBranches();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.branches,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors(context).primaryColor,
        onPressed: () async {
          final a =
              await Navigator.push(context, rightToLeft(const AddBranchScreen()));

          if (a == true) {
            getBranches();
          }
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          AppLocalizations.of(context)!.addBranch,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: loading == true
          ? LinearProgressIndicator(
              color: AppColors(context).primaryColor,
              backgroundColor: AppColors.secoundryColor,
            )
          : Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  // ---------------- Branches List ----------------
                  Expanded(
                    child: branchesModel == null || branchesModel!.branches.isEmpty
                        ? Center(
                            child: Text(
                              AppLocalizations.of(context)!.noBranchesFound,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                      itemCount: branchesModel?.branches.length ?? 0,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final branch = branchesModel?.branches[index];
                        return AnimatedSlide(
                          duration: Duration(milliseconds: 400 + (index * 80)),
                          offset: const Offset(0, 0),
                          child: AnimatedOpacity(
                            duration:
                                Duration(milliseconds: 400 + (index * 80)),
                            opacity: 1,
                            child: _BranchCard(
                              branch: branch!,
                              name: branch.name,
                              city: branch.city,
                              phone: branch.phone,
                              address: branch.address,
                              representativeName: branch.representativeName,
                              representativeEmail: branch.representativeEmail,
                              onEdit: () {},
                              onDelete: () {
                                // TODO: Implement delete API call
                                if (branchesModel != null && branchesModel!.branches.length > index) {
                                setState(() {
                                    branchesModel!.branches.removeAt(index);
                                });
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future getBranches() async {
    if (!mounted) return;
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    setState(() {
      loading = true;
    });
    
    // Use accessToken for MMS API calls (B2B users)
    final token = appProvider.accessToken ?? appProvider.userModel?.token ?? '';
    
    B2bApi.getBranches(token: token, context: context).then((value) {
      if (!mounted) return;
        setState(() {
          loading = false;
          branchesModel = value;
        });
    }).catchError((error) {
      if (!mounted) return;
        setState(() {
          loading = false;
        branchesModel = null;
        });
    });
  }
}

// ------------------- CARD -------------------
class _BranchCard extends StatefulWidget {
  final Branch branch;
  final String name;
  final String city;
  final String phone;
  final String address;
  final String? representativeName;
  final String? representativeEmail;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BranchCard({
    required this.branch,
    required this.name,
    required this.city,
    required this.phone,
    required this.address,
    this.representativeName,
    this.representativeEmail,
    required this.onEdit,
    required this.onDelete, this.image,
  });

  @override
  State<_BranchCard> createState() => _BranchCardState();
}

class _BranchCardState extends State<_BranchCard> {
  String? _formattedAddress;
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    _reverseGeocodeLocation();
  }

  bool _hasValidCoordinates() {
    final lat = widget.branch.latitude;
    final lng = widget.branch.longitude;
    if (lat.isEmpty || lng.isEmpty || lat == '0' || lng == '0') {
      return false;
    }
    final latDouble = double.tryParse(lat);
    final lngDouble = double.tryParse(lng);
    return latDouble != null && lngDouble != null && 
           !latDouble.isNaN && !lngDouble.isNaN &&
           !(latDouble == 0.0 && lngDouble == 0.0);
  }

  Future<void> _reverseGeocodeLocation() async {
    if (!_hasValidCoordinates()) {
      return;
    }
    
    setState(() {
      _isLoadingAddress = true;
    });
    
    try {
      final lat = double.tryParse(widget.branch.latitude);
      final lng = double.tryParse(widget.branch.longitude);
      
      if (lat != null && lng != null) {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
        
        if (placemarks.isNotEmpty && mounted) {
          final place = placemarks[0];
          // Format: City, State, Country
          List<String> addressParts = [];
          
          if (place.locality != null && place.locality!.isNotEmpty) {
            addressParts.add(place.locality!);
          }
          if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
            addressParts.add(place.administrativeArea!);
          }
          if (place.country != null && place.country!.isNotEmpty) {
            addressParts.add(place.country!);
          }
          
          if (mounted) {
            setState(() {
              _formattedAddress = addressParts.isNotEmpty ? addressParts.join(', ') : null;
              _isLoadingAddress = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _isLoadingAddress = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingAddress = false;
          });
        }
      }
    } catch (e) {
      log('Reverse geocoding error: $e');
      if (mounted) {
        setState(() {
          _isLoadingAddress = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors(context).primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primary.withOpacity(0.2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BranchDetailsScreen(branch: widget.branch),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Hero(
                tag: widget.name,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    "assets/image/icon_logo.png",
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // --- Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name.isNotEmpty ? widget.name : "Branch",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    if (widget.representativeName != null && widget.representativeName!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.person_outline_rounded,
                              size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              widget.representativeName!,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (_formattedAddress != null && _formattedAddress!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 16, color: Colors.grey.shade700),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              _formattedAddress!,
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else if (_isLoadingAddress) ...[
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 16, color: Colors.grey.shade700),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.loadingAddress,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else if (widget.city.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                              size: 16, color: Colors.grey.shade700),
                        const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              widget.city,
                          style: TextStyle(
                                color: Colors.grey.shade800,
                            fontSize: 13,
                              ),
                          ),
                        ),
                      ],
                    ),
                    ],
                    if (widget.phone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone_rounded,
                              size: 16, color: Colors.grey.shade700),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              widget.phone,
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (widget.representativeEmail != null && widget.representativeEmail!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.email_outlined,
                              size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              widget.representativeEmail!,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                        ),
                      ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
