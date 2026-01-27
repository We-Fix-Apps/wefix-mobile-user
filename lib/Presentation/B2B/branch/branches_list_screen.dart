import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/B2b/b2b_api.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/branch_model.dart';
import 'package:wefix/Presentation/B2B/branch/add_branch_screen.dart';
import 'package:wefix/Presentation/Components/widget_form_text.dart';

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
        title: const Text(
          "Branches",
          style: TextStyle(
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
        label: const Text(
          "Add Branch",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                    child: ListView.builder(
                      itemCount: branchesModel?.branches.length,
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
                              name: branch?.name ?? "",
                              city: branch?.city ?? "",
                              phone: branch?.phone ?? "",
                              onEdit: () {},
                              onDelete: () {
                                setState(() {
                                  branches.removeAt(index);
                                });
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
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    setState(() {
      loading = true;
    });
    B2bApi.getBranches(token: appProvider.userModel?.token ?? '').then((value) {
      if (value != null) {
        setState(() {
          loading = false;
          branchesModel = value;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    });
  }
}

// ------------------- CARD -------------------
class _BranchCard extends StatelessWidget {
  final String? image;
  final String name;
  final String city;
  final String phone;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BranchCard({
    required this.name,
    required this.city,
    required this.phone,
    required this.onEdit,
    required this.onDelete,
  });

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
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Hero(
                tag: name,
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
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 5),
                        Text(
                          city,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.phone_rounded,
                            size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 5),
                        Text(
                          phone,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
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
