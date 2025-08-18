import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Email data model
class EmailData {
  final String email; // Can contain multiple emails separated by comma/space
  final String emailBackup;
  final String subject;
  final String links;
  final String body;
  final String cc; // Can contain multiple CCs separated by comma/space
  final String status; // New field for tracking email status
  final int rowIndex; // To track the row in spreadsheet for updates

  EmailData({
    required this.email,
    required this.emailBackup,
    required this.subject,
    required this.links,
    required this.body,
    required this.cc,
    required this.status,
    required this.rowIndex,
  });

  // Extract name from email address
  String get name {
    final emailAddress = email.split(',').first.trim();
    final username = emailAddress.split('@').first;
    // Convert email username to a more readable name
    return username.replaceAll('.', ' ').split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : '')
        .join(' ');
  }

  // Helper methods to get email lists
  List<String> get emailList {
    return email.split(RegExp(r'[,\s]+'))
        .where((e) => e.trim().isNotEmpty)
        .map((e) => e.trim())
        .toList();
  }

  List<String> get ccList {
    if (cc.isEmpty) return [];
    return cc.split(RegExp(r'[,\s]+'))
        .where((e) => e.trim().isNotEmpty)
        .map((e) => e.trim())
        .toList();
  }

  // Get status color
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'sent':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class EmailDataListPage extends StatefulWidget {
  final String spreadsheetId;
  final String apiKey; // Google Sheets API key
  final String sheetName; // Sheet name
  final String phpEndpoint; // PHP endpoint URL

  const EmailDataListPage({
    Key? key,
    required this.spreadsheetId,
    required this.apiKey,
    required this.sheetName,
    this.phpEndpoint = 'http://192.168.0.110/redbox/send_mail.php', // Your actual IP
  }) : super(key: key);

  @override
  State<EmailDataListPage> createState() => _EmailDataListPageState();
}

class _EmailDataListPageState extends State<EmailDataListPage> {
  List<EmailData> emailList = [];
  bool isLoading = true;
  bool isSendingAll = false;
  String? errorMessage;
  String? csrfToken;

  @override
  void initState() {
    super.initState();
    _loadEmailData();
    _fetchCSRFToken();
  }

  // Fetch CSRF token from server with timeout and better error handling
  Future<void> _fetchCSRFToken() async {
    try {
      final csrfUrl = widget.phpEndpoint.replaceAll('/send_mail.php', '/get_csrf.php');
      print('Attempting to fetch CSRF token from: $csrfUrl');

      final response = await http.get(
        Uri.parse(csrfUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('CSRF Response status: ${response.statusCode}');
      print('CSRF Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        csrfToken = data['csrf_token'];
        print('CSRF token fetched successfully');
      } else {
        print('Failed to fetch CSRF token: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to fetch CSRF token: $e');
      // We'll continue without CSRF for now
      csrfToken = null;
    }
  }

  // Send email using PHP endpoint
  Future<bool> _sendEmail(EmailData emailData) async {
    try {
      print('Attempting to send email to: ${widget.phpEndpoint}');

      // Prepare the request body
      final Map<String, String> requestBody = {
        'to': emailData.emailList.join(', '),
        'cc': emailData.ccList.join(', '),
        'subject': emailData.subject,
        'body': _formatEmailBody(emailData),
      };

      // Add CSRF token if available
      if (csrfToken != null && csrfToken!.isNotEmpty) {
        requestBody['csrf_token'] = csrfToken!;
        print('Using CSRF token');
      } else {
        print('No CSRF token available, proceeding without it');
      }

      print('Request body: $requestBody');

      final response = await http.post(
        Uri.parse(widget.phpEndpoint),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: requestBody,
      ).timeout(const Duration(seconds: 30));

      print('Email response status: ${response.statusCode}');
      print('Email response body: ${response.body}');

      if (response.statusCode == 200) {
        // Email sent successfully
        return true;
      } else {
        // Handle error
        print('Email sending failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending email: $e');
      return false;
    }
  }

  // Send emails to all contacts
  Future<void> _sendToAll() async {
    if (emailList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No emails to send'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Filter emails that are not already sent
    final pendingEmails = emailList.where((email) =>
    email.status.toLowerCase() != 'sent').toList();

    if (pendingEmails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All emails have already been sent'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.black, width: 1),
          ),
          title: const Text(
            'Send to All',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          content: Text(
            'Are you sure you want to send emails to all ${pendingEmails.length} pending contacts?',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Send All'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      isSendingAll = true;
    });

    // Show progress dialog
    BuildContext? progressContext;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        progressContext = dialogContext;
        return StatefulBuilder(
          builder: (context, setProgressState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.black, width: 1),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Sending emails...',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '0 of ${pendingEmails.length} sent',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    int successCount = 0;
    int failureCount = 0;

    // Send emails one by one with a small delay
    for (int i = 0; i < pendingEmails.length; i++) {
      final emailData = pendingEmails[i];

      try {
        final success = await _sendEmail(emailData);

        if (success) {
          successCount++;
          _updateEmailStatus(emailData, 'Sent');
        } else {
          failureCount++;
          _updateEmailStatus(emailData, 'Failed');
        }

        // Update progress dialog
        if (progressContext != null && progressContext!.mounted) {
          // Update the dialog content (you might need to rebuild the dialog for real-time updates)
        }

        // Small delay between emails to avoid overwhelming the server
        if (i < pendingEmails.length - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      } catch (e) {
        failureCount++;
        _updateEmailStatus(emailData, 'Failed');
        print('Error sending email to ${emailData.email}: $e');
      }
    }

    // Close progress dialog
    if (progressContext != null && progressContext!.mounted) {
      Navigator.of(progressContext!).pop();
    }

    setState(() {
      isSendingAll = false;
    });

    // Show result
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          'Bulk send completed!\nSuccess: $successCount, Failed: $failureCount',
        ),
        backgroundColor: failureCount == 0 ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Format email body with additional information
  String _formatEmailBody(EmailData emailData) {
    String formattedBody = emailData.body;

    // Add links if available
    if (emailData.links.isNotEmpty) {
      formattedBody += '\n\nRelevant Links:\n${emailData.links}';
    }

    // Add backup email info if different
    if (emailData.emailBackup.isNotEmpty && emailData.emailBackup != emailData.email) {
      formattedBody += '\n\nBackup Email: ${emailData.emailBackup}';
    }

    return formattedBody;
  }

  // Fetch data from Google Sheets
  Future<void> _loadEmailData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Google Sheets API URL
      final String url = 'https://sheets.googleapis.com/v4/spreadsheets/${widget.spreadsheetId}/values/${widget.sheetName}?key=${widget.apiKey}';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> rows = data['values'] ?? [];

        if (rows.isEmpty) {
          setState(() {
            emailList = [];
            isLoading = false;
          });
          return;
        }

        // Parse the data (assuming first row is header)
        List<EmailData> parsedEmailList = [];

        // Expected columns: Emails, Emails backup, Subject, Links, Body, cc, Status (Status may be missing)
        for (int i = 1; i < rows.length; i++) {
          final row = rows[i];
          if (row.length >= 6) { // We need at least 6 columns (Status is optional)
            parsedEmailList.add(EmailData(
              email: _getColumnValue(row, 0),
              emailBackup: _getColumnValue(row, 1),
              subject: _getColumnValue(row, 2),
              links: _getColumnValue(row, 3),
              body: _getColumnValue(row, 4),
              cc: _getColumnValue(row, 5),
              status: row.length > 6 ? (_getColumnValue(row, 6).isEmpty ? 'Pending' : _getColumnValue(row, 6)) : 'Pending',
              rowIndex: i + 1, // Row index in spreadsheet (1-based)
            ));
          }
        }

        setState(() {
          emailList = parsedEmailList;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading data: $e';
        isLoading = false;
      });
    }
  }

  String _getColumnValue(List<dynamic> row, int index) {
    return index < row.length ? row[index].toString() : '';
  }

  // Update status in Google Sheets (for future implementation)
  Future<void> _updateEmailStatus(EmailData emailData, String newStatus) async {
    // TODO: Implement Google Sheets update API call
    // This will require a service account or OAuth for write permissions
    // For now, just update locally
    setState(() {
      final index = emailList.indexWhere((e) => e.rowIndex == emailData.rowIndex);
      if (index != -1) {
        emailList[index] = EmailData(
          email: emailData.email,
          emailBackup: emailData.emailBackup,
          subject: emailData.subject,
          links: emailData.links,
          body: emailData.body,
          cc: emailData.cc,
          status: newStatus,
          rowIndex: emailData.rowIndex,
        );
      }
    });

    // Only show individual status updates when not doing bulk send
    if (!isSendingAll) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to: $newStatus'),
          backgroundColor: Colors.black,
        ),
      );
    }
  }

  void _showEmailDetails(EmailData emailData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.black, width: 1),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700, maxHeight: 700),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Email Details',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Details
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Name', emailData.name),
                        _buildDetailRow('Email(s)', emailData.email),
                        _buildDetailRow('Email Backup', emailData.emailBackup),
                        _buildDetailRow('CC', emailData.cc, isMultiline: true),
                        _buildDetailRow('Subject', emailData.subject),
                        _buildDetailRow('Links', emailData.links),
                        _buildDetailRow('Body', emailData.body, isMultiline: true),
                        _buildStatusRow(emailData),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _updateEmailStatus(emailData, 'Pending');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text('Mark Pending'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Store the navigator and scaffold messenger before async operations
                          final navigator = Navigator.of(context);
                          final scaffoldMessenger = ScaffoldMessenger.of(context);

                          navigator.pop(); // Close details dialog first

                          // Show loading dialog and store its context
                          BuildContext? loadingContext;
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext dialogContext) {
                              loadingContext = dialogContext;
                              return const Dialog(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(width: 20),
                                      Text('Sending email...'),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );

                          // Send email
                          bool success = await _sendEmail(emailData);

                          // Close loading dialog using the stored context
                          if (loadingContext != null && loadingContext!.mounted) {
                            Navigator.of(loadingContext!).pop();
                          }

                          if (success) {
                            _updateEmailStatus(emailData, 'Sent');
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('Email sent successfully!'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } else {
                            _updateEmailStatus(emailData, 'Failed');
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('Failed to send email. Please try again.'),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                            side: const BorderSide(color: Colors.black, width: 1),
                          ),
                          elevation: 2,
                          shadowColor: Colors.black.withOpacity(0.1),
                        ),
                        child: const Text(
                          'Send',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
              maxLines: isMultiline ? null : 1,
              overflow: isMultiline ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(EmailData emailData) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: emailData.statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  emailData.status,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: emailData.statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          'Email Data List',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              // Debug button - test connection
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              try {
                print('Testing connection to: ${widget.phpEndpoint}');
                final testUrl = widget.phpEndpoint.replaceAll('/send_mail.php', '/get_csrf.php');
                print('CSRF URL: $testUrl');

                final response = await http.get(
                  Uri.parse(testUrl),
                ).timeout(const Duration(seconds: 5));

                print('Response: ${response.statusCode} - ${response.body}');

                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Connection test: ${response.statusCode}\n${response.body}'),
                    backgroundColor: response.statusCode == 200 ? Colors.green : Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              } catch (e) {
                print('Connection error: $e');
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Connection failed: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            icon: const Icon(Icons.wifi_tethering, color: Colors.black),
          ),
          IconButton(
            onPressed: _loadEmailData,
            icon: const Icon(Icons.refresh, color: Colors.black),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.black,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
        ),
      )
          : errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage!,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEmailData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : emailList.isEmpty
          ? const Center(
        child: Text(
          'No email data found',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      )
          : Column(
        children: [
          // Send to All button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: isSendingAll ? null : _sendToAll,
              icon: isSendingAll
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Icon(Icons.send, color: Colors.white),
              label: Text(
                isSendingAll ? 'Sending...' : 'Send to All',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.1),
              ),
            ),
          ),
          // Email list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: emailList.length,
              itemBuilder: (context, index) {
                final emailData = emailList[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    color: Colors.white,
                    elevation: 2,
                    shadowColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.black, width: 1),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              emailData.name,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: emailData.statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: emailData.statusColor, width: 1),
                            ),
                            child: Text(
                              emailData.status,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: emailData.statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            emailData.subject,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            emailData.emailList.join(', '),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (emailData.ccList.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'CC: ${emailData.ccList.join(', ')}',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.black,
                      ),
                      onTap: () => _showEmailDetails(emailData),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}