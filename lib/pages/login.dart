import 'package:flutter/material.dart';
import 'package:redbox/pages/home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Hardcoded credentials
  final String _validUsername = 'vinay14';
  final String _validPassword = '1201';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate a small delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));

      String username = _usernameController.text.trim();
      String password = _passwordController.text.trim();

      if (username == _validUsername && password == _validPassword) {
        // Successful login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      } else {
        // Failed login
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid username or password!'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                constraints: const BoxConstraints(maxWidth: 400),
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
                            child: Icon(
                              Icons.lock_outline,
                              size: 60,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Center(
                            child: Text(
                              'Login',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Center(
                            child: Text(
                              'Please sign in to continue',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Username Field
                          const Text(
                            'Username',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _usernameController,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter your username',
                              hintStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              prefixIcon: const Icon(
                                Icons.person_outline,
                                color: Colors.black,
                                size: 20,
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
                              errorBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(color: Colors.red, width: 1),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your username';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              hintStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Colors.black,
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.black,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
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
                              errorBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(color: Colors.red, width: 1),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
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
                              child: _isLoading
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                                  : const Text(
                                'Login',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Demo credentials info
                          // Container(
                          //   padding: const EdgeInsets.all(12),
                          //   decoration: BoxDecoration(
                          //     color: Colors.grey[50],
                          //     border: Border.all(color: Colors.grey[300]!, width: 1),
                          //     borderRadius: BorderRadius.circular(4),
                          //   ),
                          //   child: const Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       Text(
                          //         'Demo Credentials:',
                          //         style: TextStyle(
                          //           fontFamily: 'Poppins',
                          //           fontSize: 12,
                          //           fontWeight: FontWeight.w600,
                          //           color: Colors.black87,
                          //         ),
                          //       ),
                          //       SizedBox(height: 4),
                          //       Text(
                          //         'Username: vinay14',
                          //         style: TextStyle(
                          //           fontFamily: 'Poppins',
                          //           fontSize: 11,
                          //           fontWeight: FontWeight.w400,
                          //           color: Colors.black87,
                          //         ),
                          //       ),
                          //       Text(
                          //         'Password: 1201',
                          //         style: TextStyle(
                          //           fontFamily: 'Poppins',
                          //           fontSize: 11,
                          //           fontWeight: FontWeight.w400,
                          //           color: Colors.black87,
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
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