import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_mate/services/database_service.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/sync/sync_bloc.dart';
import '../services/api_service.dart';
import '../utils/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  bool _generatingReport = false;

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
             
              // User Info Card
              _buildUserInfoCard(),
              const SizedBox(height: 20),
             
              // Account Details Card
              _buildAccountDetailsCard(),
              const SizedBox(height: 20),
             
              // Data Sync Card
              _buildSyncCard(),
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

  Widget _buildUserInfoCard() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                'User not found',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }
        final user = state.user;
       
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // Profile Picture
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
              const SizedBox(height: 20),
             
              // User Info
              Text(
                user.name,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user.email,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Active User',
                  style: TextStyle(
                    color: AppColors.accentGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountDetailsCard() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const SizedBox.shrink();
        }
        final user = state.user;
       
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
                'Account Details',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
             
              _buildDetailItem('User ID', user.id.toString(), Icons.fingerprint),
              const SizedBox(height: 16),
             
              _buildDetailItem('Email Address', user.email, Icons.email),
              const SizedBox(height: 16),
             
              _buildDetailItem('Date of Birth', user.formattedDateOfBirth, Icons.cake),
              const SizedBox(height: 16),
             
              _buildDetailItem('Member Since', user.memberSince, Icons.calendar_today),
              const SizedBox(height: 16),
             
              _buildDetailItem('Account Status', user.isActive ? 'Active' : 'Inactive',
                  user.isActive ? Icons.check_circle : Icons.error,
                  color: user.isActive ? AppColors.accentGreen : AppColors.accentRed),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSyncCard() {
    return BlocProvider(
      create: (context) => SyncBloc(
        apiService: ApiService(),
        databaseService: DatabaseService(),
      ),
      child: BlocConsumer<SyncBloc, SyncState>(
        listener: (context, state) {
          if (state is SyncSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Sync completed! ${state.transactionCount} transactions and ${state.goalCount} goals loaded.',
                ),
                backgroundColor: AppColors.accentGreen,
              ),
            );
          } else if (state is SyncError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.accentRed,
              ),
            );
          }
        },
        builder: (context, state) {
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
                  'Data Synchronization',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sync all your data from the server to your local device',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
               
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.sync, color: AppColors.primary, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sync All Data',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Download all transactions and goals from server',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      state is SyncLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                              ),
                            )
                          : IconButton(
                              icon: Icon(Icons.sync, color: AppColors.primary),
                              onPressed: () {
                                context.read<SyncBloc>().add(SyncAllData());
                              },
                            ),
                    ],
                  ),
                ),
                if (state is SyncSuccess) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: AppColors.accentGreen, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sync completed successfully!',
                            style: TextStyle(
                              color: AppColors.accentGreen,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
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

  Widget _buildDetailItem(String title, String value, IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color ?? AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
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
        _showSuccessSnackBar('Monthly report generated successfully!');
      } else {
        _showErrorSnackBar('Failed to generate report: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackBar('Error generating report: $e');
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
        _showSuccessSnackBar('Yearly report generated successfully!');
      } else {
        _showErrorSnackBar('Failed to generate report: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackBar('Error generating report: $e');
    } finally {
      setState(() {
        _generatingReport = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.accentGreen,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.accentRed,
      ),
    );
  }

  Future<void> _generatePdfReport(Map<String, dynamic> reportData, String fileName) async {
    try {
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
        _showSuccessSnackBar('Report saved to: ${file.path}');
      } else {
        _showErrorSnackBar('Storage permission denied');
      }
    } catch (e) {
      _showErrorSnackBar('Error creating PDF: $e');
    }
  }
}