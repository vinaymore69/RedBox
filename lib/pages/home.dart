import 'package:flutter/material.dart';

import 'emaildata.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _spreadsheetController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _spreadsheetController.dispose();
    super.dispose();
  }



  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      String spreadsheetId = _spreadsheetController.text.trim();

      if (spreadsheetId.startsWith('https://docs.google.com/spreadsheets/d/')) {
        // Remove the base URL part
        spreadsheetId = spreadsheetId.replaceFirst(
          'https://docs.google.com/spreadsheets/d/',
          '',
        );

        // Keep only the ID (stop at first '/')
        spreadsheetId = spreadsheetId.split('/')[0];
      }

      print('Spreadsheet ID: $spreadsheetId');



      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Spreadsheet ID submitted successfully!'),
          backgroundColor: Colors.black,
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EmailDataListPage(
            spreadsheetId: spreadsheetId,
            apiKey: 'AIzaSyDLZ0N6Eren67siE_splisoj2AwL-Mi5pM',
            sheetName: 'Sheet1', // e.g., 'Sheet1', 'EmailData', etc.
          ),
        ),
      );

    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.black, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              'Google Spreadsheet Form',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            'Spreadsheet ID or URL..',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _spreadsheetController,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter your Google Spreadsheet ID',
                              hintStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(color: Colors.black, width: 1),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(color: Colors.black, width: 1),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(color: Colors.black, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a spreadsheet ID';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black, width: 1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Instructions:',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  '• Make sure your Google Spreadsheet is visible and accessible to anyone',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  '• Share settings should be set to "Anyone with the link can view"',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  '• Copy the spreadsheet ID from the URL between "/d/" and "/edit"',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _handleSubmit,
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
                                'Submit',
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
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}