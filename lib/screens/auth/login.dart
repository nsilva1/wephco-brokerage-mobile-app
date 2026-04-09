import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final userProvider = context.read<UserProvider>();
      
      final error = await userProvider.loginUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (error == null) {
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<UserProvider>().isAuthLoading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
            width: MediaQuery.of(context).size.width * 0.6, 
            child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
          ),
                  const SizedBox(height: 50),
                  Text("Welcome Back", style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: const Color(0xFF235F23), fontWeight: FontWeight.bold)),
                  const Text("Log in to manage your properties"),
                  const SizedBox(height: 40),
                  
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                    validator: (value) => value!.contains('@') ? null : "Enter a valid email",
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (value) => value!.length < 6 ? "Password too short" : null,
                  ),
                  
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(onPressed: () {}, child: const Text("Forgot Password?", style: TextStyle(
      decoration: TextDecoration.underline, // This adds the underline
      color: Color(0xFF235F23), // Keeping your brand green
      fontWeight: FontWeight.bold,
    ),)),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF235F23)),
                      child: isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text("Login", style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/register'), 
                        child: const Text("Register", style: TextStyle(
      decoration: TextDecoration.underline, // This adds the underline
      color: Color(0xFF235F23), // Keeping your brand green
      fontWeight: FontWeight.bold,
    ),),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}