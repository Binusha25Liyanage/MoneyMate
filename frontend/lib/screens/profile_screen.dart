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
         
          // Basic Reports
          _buildReportItem(
            'Monthly Report',
            'Generate PDF report for current month',
            Icons.description_outlined,
            _generateMonthlyReport,
          ),
          const SizedBox(height: 12),
         
          _buildReportItem(
            'Yearly Report',
            'Generate PDF report for current year',
            Icons.assessment_outlined,
            _generateYearlyReport,
          ),
          const SizedBox(height: 16),
          
          Divider(color: AppColors.textSecondary.withOpacity(0.3)),
          const SizedBox(height: 16),
          
          Text(
            'Advanced Analytics',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          // Advanced Reports
          _buildReportItem(
            'Monthly Expenditure Analysis',
            'Detailed monthly expense analysis with trends',
            Icons.analytics_outlined,
            () => _generateAdvancedReport('monthly-expenditure'),
          ),
          const SizedBox(height: 12),
          
          _buildReportItem(
            'Goal Adherence Tracking',
            'Track your progress against financial goals',
            Icons.flag_outlined,
            () => _generateAdvancedReport('goal-adherence'),
          ),
          const SizedBox(height: 12),
          
          _buildReportItem(
            'Savings Goal Progress',
            'Monitor your savings goal achievements',
            Icons.savings_outlined,
            () => _generateAdvancedReport('savings-progress'),
          ),
          const SizedBox(height: 12),
          
          _buildReportItem(
            'Category Expense Distribution',
            'Breakdown of expenses by category',
            Icons.pie_chart_outline,
            () => _generateAdvancedReport('category-distribution'),
          ),
          const SizedBox(height: 12),
          
          _buildReportItem(
            'Financial Health Status',
            'Overall assessment of your financial health',
            Icons.health_and_safety_outlined,
            () => _generateAdvancedReport('financial-health'),
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
        print('Failed to generate report: ${response.message}');
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
        print('Failed to generate report: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackBar('Error generating report: $e');
    } finally {
      setState(() {
        _generatingReport = false;
      });
    }
  }

  // New method for advanced reports
  Future<void> _generateAdvancedReport(String reportType) async {
    setState(() {
      _generatingReport = true;
    });
    
    try {
      final now = DateTime.now();
      dynamic response;
      String fileName = '';

      switch (reportType) {
        case 'monthly-expenditure':
          response = await _apiService.getMonthlyExpenditureAnalysis(now.year);
          fileName = 'Monthly_Expenditure_Analysis_${now.year}';
          break;
        case 'goal-adherence':
          final startDate = DateTime(now.year, now.month - 3, 1);
          response = await _apiService.getGoalAdherenceTracking(startDate, now);
          fileName = 'Goal_Adherence_Tracking_${now.month}_${now.year}';
          break;
        case 'savings-progress':
          response = await _apiService.getSavingsGoalProgress();
          fileName = 'Savings_Goal_Progress_${now.month}_${now.year}';
          break;
        case 'category-distribution':
          final startDate = DateTime(now.year, 1, 1);
          response = await _apiService.getCategoryExpenseDistribution(startDate, now);
          fileName = 'Category_Expense_Distribution_${now.year}';
          break;
        case 'financial-health':
          response = await _apiService.getFinancialHealthStatus();
          fileName = 'Financial_Health_Status_${now.month}_${now.year}';
          break;
        default:
          throw Exception('Unknown report type');
      }

      if (response.success) {
        await _generateAdvancedPdfReport(response.data, fileName, reportType);
        _showSuccessSnackBar('${_toTitleCase(reportType.replaceAll('-', ' '))} report generated successfully!');
      } else {
        _showErrorSnackBar('Failed to generate report: ${response.message}');
        print('Failed to generate report: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackBar('Error generating report: $e');
    } finally {
      setState(() {
        _generatingReport = false;
      });
    }
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
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

  // Update PDF generation to handle advanced reports
  Future<void> _generateAdvancedPdfReport(Map<String, dynamic> reportData, String fileName, String reportType) async {
    try {
      final PdfDocument document = PdfDocument();
      final PdfPage page = document.pages.add();
      final Size pageSize = page.getClientSize();
      final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 24);
      final PdfFont headingFont = PdfStandardFont(PdfFontFamily.helvetica, 16, style: PdfFontStyle.bold);
      final PdfFont contentFont = PdfStandardFont(PdfFontFamily.helvetica, 12);
      
      double yPosition = 0;

      // Draw title
      page.graphics.drawString(
        reportData['reportType'] ?? 'Financial Report',
        titleFont,
        bounds: Rect.fromLTWH(0, yPosition, pageSize.width, 30),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
      );
      yPosition += 40;

      // Draw report period if available
      if (reportData['period'] != null) {
        final period = reportData['period'];
        String periodText = '';
        if (period['startDate'] != null && period['endDate'] != null) {
          periodText = '${period['startDate']} to ${period['endDate']}';
        } else if (period['year'] != null) {
          periodText = 'Year: ${period['year']}';
        }
        page.graphics.drawString(
          'Period: $periodText',
          contentFont,
          bounds: Rect.fromLTWH(0, yPosition, pageSize.width, 20),
          format: PdfStringFormat(alignment: PdfTextAlignment.center),
        );
        yPosition += 25;
      }

      // Draw generated date
      page.graphics.drawString(
        'Generated: ${DateTime.now().toLocal()}',
        contentFont,
        bounds: Rect.fromLTWH(0, yPosition, pageSize.width, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
      );
      yPosition += 30;

      // Generate report content based on type
      switch (reportType) {
        case 'monthly-expenditure':
          yPosition = _drawMonthlyExpenditureAnalysis(page, reportData, yPosition, headingFont, contentFont);
          break;
        case 'goal-adherence':
          yPosition = _drawGoalAdherenceTracking(page, reportData, yPosition, headingFont, contentFont);
          break;
        case 'savings-progress':
          yPosition = _drawSavingsGoalProgress(page, reportData, yPosition, headingFont, contentFont);
          break;
        case 'category-distribution':
          yPosition = _drawCategoryExpenseDistribution(page, reportData, yPosition, headingFont, contentFont);
          break;
        case 'financial-health':
          yPosition = _drawFinancialHealthStatus(page, reportData, yPosition, headingFont, contentFont);
          break;
      }

      // Save the document
      final List<int> bytes = await document.save();
      document.dispose();

      // Save to file
      final status = await Permission.storage.request();
      if (status.isGranted) {
        final directory = await getExternalStorageDirectory();
        final file = File('${directory?.path}/$fileName.pdf');
        await file.writeAsBytes(bytes);
        _showSuccessSnackBar('Report saved to: ${file.path}');
      } else {
        _showErrorSnackBar('Storage permission denied');
      }
    } catch (e) {
      _showErrorSnackBar('Error creating PDF: $e');
    }
  }

  // Helper methods for drawing different report types
  double _drawMonthlyExpenditureAnalysis(PdfPage page, Map<String, dynamic> data, double yPosition, PdfFont headingFont, PdfFont contentFont) {
    final pageSize = page.getClientSize();
    
    page.graphics.drawString(
      'Monthly Expenditure Analysis',
      headingFont,
      bounds: Rect.fromLTWH(0, yPosition, pageSize.width, 20),
    );
    yPosition += 25;

    final analysis = data['analysis'] as List<dynamic>? ?? [];
    
    if (analysis.isEmpty) {
      page.graphics.drawString(
        'No data available for this period',
        contentFont,
        bounds: Rect.fromLTWH(20, yPosition, pageSize.width - 40, 15),
      );
      yPosition += 18;
    } else {
      for (var item in analysis) {
        final month = item['MONTH_NAME']?.toString().trim() ?? 'Unknown';
        final total = (item['TOTAL_AMOUNT'] ?? 0).toString();
        final trend = item['TREND']?.toString() ?? 'No trend';
        
        page.graphics.drawString(
          '$month: \$${double.parse(total).toStringAsFixed(2)} ($trend)',
          contentFont,
          bounds: Rect.fromLTWH(20, yPosition, pageSize.width - 40, 15),
        );
        yPosition += 18;
      }
    }

    return yPosition;
  }

  double _drawGoalAdherenceTracking(PdfPage page, Map<String, dynamic> data, double yPosition, PdfFont headingFont, PdfFont contentFont) {
    final pageSize = page.getClientSize();
    
    page.graphics.drawString(
      'Goal Adherence Tracking',
      headingFont,
      bounds: Rect.fromLTWH(0, yPosition, pageSize.width, 20),
    );
    yPosition += 25;

    final tracking = data['tracking'] as List<dynamic>? ?? [];
    
    if (tracking.isEmpty) {
      page.graphics.drawString(
        'No goal tracking data available',
        contentFont,
        bounds: Rect.fromLTWH(20, yPosition, pageSize.width - 40, 15),
      );
      yPosition += 18;
    } else {
      for (var item in tracking) {
        final month = item['TARGET_MONTH']?.toString() ?? 'Unknown';
        final year = item['TARGET_YEAR']?.toString() ?? 'Unknown';
        final target = (item['TARGET_AMOUNT'] ?? 0).toString();
        final actual = (item['ACTUAL_AMOUNT'] ?? 0).toString();
        final status = item['STATUS']?.toString() ?? 'Unknown';
        
        page.graphics.drawString(
          '$month/$year: Target \$${double.parse(target).toStringAsFixed(2)} | Actual \$${double.parse(actual).toStringAsFixed(2)} | $status',
          contentFont,
          bounds: Rect.fromLTWH(20, yPosition, pageSize.width - 40, 15),
        );
        yPosition += 18;
      }
    }

    return yPosition;
  }

  double _drawSavingsGoalProgress(PdfPage page, Map<String, dynamic> data, double yPosition, PdfFont headingFont, PdfFont contentFont) {
    final pageSize = page.getClientSize();
    
    page.graphics.drawString(
      'Savings Goal Progress',
      headingFont,
      bounds: Rect.fromLTWH(0, yPosition, pageSize.width, 20),
    );
    yPosition += 25;

    final progress = data['progress'] as List<dynamic>? ?? [];
    
    if (progress.isEmpty) {
      page.graphics.drawString(
        'No savings goal data available',
        contentFont,
        bounds: Rect.fromLTWH(20, yPosition, pageSize.width - 40, 15),
      );
      yPosition += 18;
    } else {
      for (var item in progress) {
        final month = item['TARGET_MONTH']?.toString() ?? 'Unknown';
        final year = item['TARGET_YEAR']?.toString() ?? 'Unknown';
        final progressPercent = (item['PROGRESS_PERCENTAGE'] ?? 0).toString();
        final status = item['STATUS']?.toString() ?? 'Unknown';
        
        page.graphics.drawString(
          '$month/$year: ${double.parse(progressPercent).toStringAsFixed(1)}% - $status',
          contentFont,
          bounds: Rect.fromLTWH(20, yPosition, pageSize.width - 40, 15),
        );
        yPosition += 18;
      }
    }

    return yPosition;
  }

  double _drawCategoryExpenseDistribution(PdfPage page, Map<String, dynamic> data, double yPosition, PdfFont headingFont, PdfFont contentFont) {
    final pageSize = page.getClientSize();
    
    page.graphics.drawString(
      'Category Expense Distribution',
      headingFont,
      bounds: Rect.fromLTWH(0, yPosition, pageSize.width, 20),
    );
    yPosition += 25;

    final distribution = data['distribution'] as List<dynamic>? ?? [];
    
    if (distribution.isEmpty) {
      page.graphics.drawString(
        'No category expense data available',
        contentFont,
        bounds: Rect.fromLTWH(20, yPosition, pageSize.width - 40, 15),
      );
      yPosition += 18;
    } else {
      for (var item in distribution) {
        final category = item['CATEGORY_NAME']?.toString() ?? 'Unknown';
        final total = (item['TOTAL_AMOUNT'] ?? 0).toString();
        final percentage = (item['PERCENTAGE_OF_TOTAL'] ?? 0).toString();
        
        page.graphics.drawString(
          '$category: \$${double.parse(total).toStringAsFixed(2)} (${double.parse(percentage).toStringAsFixed(1)}%)',
          contentFont,
          bounds: Rect.fromLTWH(20, yPosition, pageSize.width - 40, 15),
        );
        yPosition += 18;
      }
    }

    return yPosition;
  }

  double _drawFinancialHealthStatus(PdfPage page, Map<String, dynamic> data, double yPosition, PdfFont headingFont, PdfFont contentFont) {
    final pageSize = page.getClientSize();
    
    page.graphics.drawString(
      'Financial Health Status',
      headingFont,
      bounds: Rect.fromLTWH(0, yPosition, pageSize.width, 20),
    );
    yPosition += 25;

    final health = data['health'] as Map<String, dynamic>? ?? {};
    
    final income = (health['TOTAL_INCOME'] ?? 0).toString();
    final expenses = (health['TOTAL_EXPENSES'] ?? 0).toString();
    final net = (health['NET_INCOME'] ?? 0).toString();
    final savingsRate = (health['SAVINGS_RATE'] ?? 0).toString();
    final healthStatus = health['FINANCIAL_HEALTH']?.toString() ?? 'Unknown';
    
    final healthItems = [
      'Total Income: \$${double.parse(income).toStringAsFixed(2)}',
      'Total Expenses: \$${double.parse(expenses).toStringAsFixed(2)}',
      'Net Income: \$${double.parse(net).toStringAsFixed(2)}',
      'Savings Rate: ${double.parse(savingsRate).toStringAsFixed(1)}%',
      'Financial Health: $healthStatus',
    ];

    for (var item in healthItems) {
      page.graphics.drawString(
        item,
        contentFont,
        bounds: Rect.fromLTWH(20, yPosition, pageSize.width - 40, 15),
      );
      yPosition += 18;
    }

    return yPosition;
  }
}