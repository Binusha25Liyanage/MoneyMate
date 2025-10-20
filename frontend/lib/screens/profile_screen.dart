import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../blocs/auth/auth_bloc.dart';
import '../services/api_service.dart';
import '../utils/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController usernameController = TextEditingController(text: "John Doe");
  final TextEditingController emailController = TextEditingController(text: "john.doe@example.com");
  bool darkMode = true;
  bool notifications = true;
  String selectedCurrency = 'USD';
  bool _generatingReport = false;

  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Profile',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your account and preferences',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              
              // Profile Info Card
              _buildProfileCard(),
              const SizedBox(height: 20),
              
              // Settings Card
              _buildSettingsCard(),
              const SizedBox(height: 20),
              
              // Report Generation Card
              _buildReportCard(),
              const SizedBox(height: 20),
              
              // Logout Button
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Profile Picture
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.card, width: 3),
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Profile Info
          _buildProfileField('Username', usernameController, Icons.person_outline),
          const SizedBox(height: 16),
          _buildProfileField('Email', emailController, Icons.email_outlined),
        ],
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      style: TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.1)),
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferences',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          
          // Dark Mode Toggle
          _buildSettingItem(
            'Dark Mode',
            Icons.dark_mode_outlined,
            Switch(
              value: darkMode,
              onChanged: (value) {
                setState(() {
                  darkMode = value;
                });
              },
              activeColor: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Notifications
          _buildSettingItem(
            'Notifications',
            Icons.notifications_outlined,
            Switch(
              value: notifications,
              onChanged: (value) {
                setState(() {
                  notifications = value;
                });
              },
              activeColor: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Currency Selection
          _buildSettingItem(
            'Currency',
            Icons.currency_exchange_outlined,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                dropdownColor: AppColors.card,
                value: selectedCurrency,
                underline: const SizedBox(),
                items: ['USD', 'EUR', 'GBP', 'LKR']
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c, style: TextStyle(color: AppColors.textPrimary)),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCurrency = value!;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Reports',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Generate detailed reports of your financial activities',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          
          // Monthly Report
          _buildReportItem(
            'Monthly Report',
            'Generate PDF report for current month',
            Icons.description_outlined,
            _generateMonthlyReport,
          ),
          const SizedBox(height: 12),
          
          // Yearly Report
          _buildReportItem(
            'Yearly Report',
            'Generate PDF report for current year',
            Icons.assessment_outlined,
            _generateYearlyReport,
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _generatingReport
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.download, color: AppColors.primary),
                  onPressed: onTap,
                ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, IconData icon, Widget control) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.textSecondary),
            const SizedBox(width: 16),
            Text(title, style: TextStyle(color: AppColors.textPrimary)),
          ],
        ),
        control,
      ],
    );
  }

  Widget _buildLogoutButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.accentRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.accentRed.withOpacity(0.3)),
          ),
          child: TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutEvent());
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, color: AppColors.accentRed, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Logout',
                  style: TextStyle(
                    color: AppColors.accentRed,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _generateMonthlyReport() async {
    setState(() {
      _generatingReport = true;
    });

    try {
      final now = DateTime.now();
      final response = await _apiService.getMonthlyReport(now.month, now.year);
      
      if (response.success) {
        await _generatePdfReport(response.data, 'Monthly_Report_${now.month}_${now.year}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Monthly report generated successfully!'),
            backgroundColor: AppColors.accentGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate report: ${response.message}'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating report: $e'),
          backgroundColor: AppColors.accentRed,
        ),
      );
    } finally {
      setState(() {
        _generatingReport = false;
      });
    }
  }

  Future<void> _generateYearlyReport() async {
    setState(() {
      _generatingReport = true;
    });

    try {
      final now = DateTime.now();
      final response = await _apiService.getYearlyReport(now.year);
      
      if (response.success) {
        await _generatePdfReport(response.data, 'Yearly_Report_${now.year}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yearly report generated successfully!'),
            backgroundColor: AppColors.accentGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate report: ${response.message}'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating report: $e'),
          backgroundColor: AppColors.accentRed,
        ),
      );
    } finally {
      setState(() {
        _generatingReport = false;
      });
    }
  }

  Future<void> _generatePdfReport(Map<String, dynamic> reportData, String fileName) async {
    // Create a new PDF document
    final PdfDocument document = PdfDocument();

    // Add a new page
    final PdfPage page = document.pages.add();

    // Get page size
    final Size pageSize = page.getClientSize();

    // Draw title
    page.graphics.drawString(
      'Financial Report',
      PdfStandardFont(PdfFontFamily.helvetica, 24),
      bounds: Rect.fromLTWH(0, 0, pageSize.width, 50),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );

    // Draw report data
    double yPosition = 60;
    final PdfFont contentFont = PdfStandardFont(PdfFontFamily.helvetica, 12);

    // Add period information
    if (reportData['period'] != null) {
      final period = reportData['period'];
      page.graphics.drawString(
        'Period: ${period['monthName'] ?? ''} ${period['year'] ?? ''}',
        contentFont,
        bounds: Rect.fromLTWH(0, yPosition, pageSize.width, 20),
      );
      yPosition += 25;
    }

    // Add summary information
    if (reportData['summary'] != null) {
      final summary = reportData['summary'];
      page.graphics.drawString(
        'Summary:',
        PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(0, yPosition, pageSize.width, 20),
      );
      yPosition += 25;

      final summaryItems = [
        'Total Income: \$${summary['income']?.toStringAsFixed(2) ?? '0.00'}',
        'Total Expenses: \$${summary['expenses']?.toStringAsFixed(2) ?? '0.00'}',
        'Net Income: \$${summary['net']?.toStringAsFixed(2) ?? '0.00'}',
      ];

      for (final item in summaryItems) {
        page.graphics.drawString(
          item,
          contentFont,
          bounds: Rect.fromLTWH(20, yPosition, pageSize.width - 40, 20),
        );
        yPosition += 20;
      }
      yPosition += 10;
    }

    // Save the document
    final List<int> bytes = await document.save();

    // Dispose the document
    document.dispose();

    // Get external storage directory
    final status = await Permission.storage.request();
    if (status.isGranted) {
      final directory = await getExternalStorageDirectory();
      final file = File('${directory?.path}/$fileName.pdf');
      await file.writeAsBytes(bytes);
      
      // Show success message with file path
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report saved to: ${file.path}'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Storage permission denied'),
          backgroundColor: AppColors.accentRed,
        ),
      );
    }
  }
}