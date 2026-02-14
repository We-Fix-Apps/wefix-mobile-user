import 'package:flutter/material.dart';
import 'package:wefix/Presentation/Profile/Screens/booking_details_screen.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';

/// Wrapper screen that loads TicketDetailsScreen safely after cold start
/// This prevents crashes when navigating from notification on app launch
class TicketDetailsLoader extends StatefulWidget {
  final String ticketId;
  
  const TicketDetailsLoader({Key? key, required this.ticketId}) : super(key: key);

  @override
  State<TicketDetailsLoader> createState() => _TicketDetailsLoaderState();
}

class _TicketDetailsLoaderState extends State<TicketDetailsLoader> {
  @override
  void initState() {
    super.initState();
    
    // Give the app time to fully initialize before loading the complex TicketDetailsScreen
    // This prevents native crashes during cold start navigation
    // Increased delay to ensure all native plugins are ready and app is fully initialized
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) {
        return;
      }
      
      // Additional safety check - wait for next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!mounted) {
            return;
          }
          
          try {
            // Replace this loader screen with the actual TicketDetailsScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TicketDetailsScreen(id: widget.ticketId),
              ),
            );
          } catch (e) {
            // Show error and go back
            if (mounted) {
              final appText = AppText(context);
              String errorMessage;
              try {
                final translation = appText.getTranslation('errorLoadingTicketDetails');
                if (translation.isNotEmpty) {
                  errorMessage = translation;
                } else {
                  errorMessage = appText.langCode == 'ar' 
                      ? 'خطأ في تحميل تفاصيل التذكرة' 
                      : 'Error loading ticket details';
                }
              } catch (_) {
                errorMessage = appText.langCode == 'ar' 
                    ? 'خطأ في تحميل تفاصيل التذكرة' 
                    : 'Error loading ticket details';
              }
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  backgroundColor: Colors.red,
                ),
              );
              Navigator.of(context).pop();
            }
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final appText = AppText(context);
    final ticketText = appText.ticket.isNotEmpty ? appText.ticket : 'Ticket';
    
    // Create localized loading message
    // Try to get translation, fallback to language-based default
    String loadingMessage;
    try {
      final translation = appText.getTranslation('loadingTicketDetails');
      if (translation.isNotEmpty) {
        loadingMessage = translation;
      } else {
        // Fallback based on language
        loadingMessage = appText.langCode == 'ar' 
            ? 'جاري تحميل تفاصيل التذكرة...' 
            : 'Loading ticket details...';
      }
    } catch (e) {
      // Final fallback
      loadingMessage = appText.langCode == 'ar' 
          ? 'جاري تحميل تفاصيل التذكرة...' 
          : 'Loading ticket details...';
    }
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors(context).primaryColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          '$ticketText #${widget.ticketId}',
          style: TextStyle(
            color: AppColors.blackColor1,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          LanguageButton(),
        ],
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors(context).primaryColor,
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              loadingMessage,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.greyColor2,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$ticketText #${widget.ticketId}',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.greyColor5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
