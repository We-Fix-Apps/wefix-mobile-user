import 'package:flutter/material.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Presentation/B2B/ticket/components/dropdown_card_item.dart';

class DraggableCardBottomSheet extends StatelessWidget {
  final String title;
  final List<DropdownCardItem> items;
  final Function(DropdownCardItem) onItemSelected;
  final DropdownCardItem? selectedItem;

  const DraggableCardBottomSheet({
    super.key,
    required this.title,
    required this.items,
    required this.onItemSelected,
    this.selectedItem,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<DropdownCardItem> items,
    required Function(DropdownCardItem) onItemSelected,
    DropdownCardItem? selectedItem,
  }) async {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableCardBottomSheet(
        title: title,
        items: items,
        onItemSelected: onItemSelected,
        selectedItem: selectedItem,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              // Grid of cards
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = selectedItem?.id == item.id;
                    return _CardItemWidget(
                      item: item,
                      isSelected: isSelected,
                      onTap: () {
                        onItemSelected(item);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CardItemWidget extends StatelessWidget {
  final DropdownCardItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _CardItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors(context).primaryColor.withOpacity(0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors(context).primaryColor
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon or Image
            if (item.iconWidget != null)
              item.iconWidget!
            else if (item.icon != null)
              Icon(
                item.icon,
                size: 70,
                color: isSelected
                    ? AppColors(context).primaryColor
                    : Colors.grey[700],
              ),
            const SizedBox(height: 8),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                item.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppColors(context).primaryColor
                      : Colors.black87,
                ),
              ),
            ),
            // Subtitle (optional) - show both names
            if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  item.subtitle!,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
