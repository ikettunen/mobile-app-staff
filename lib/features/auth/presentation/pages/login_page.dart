import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nurse_app/core/navigation/app_router.dart';
import 'package:nurse_app/features/auth/presentation/bloc/auth_bloc.dart';

class TestUser {
  final String name;
  final String email;
  final String password;
  final String role;
  final String emoji;
  
  TestUser(this.name, this.email, this.password, this.role, this.emoji);
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Test users for dropdown
  final List<TestUser> _testUsers = [
    TestUser('Anna Virtanen', 'anna.virtanen@hoitokoti.fi', 'nursing123', 'NURSE', '👩‍⚕️'),
    TestUser('Maria Nieminen', 'maria.nieminen@hoitokoti.fi', 'nursing123', 'HEAD_NURSE', '👩‍⚕️'),
    TestUser('Jukka Mäkinen', 'jukka.makinen@hoitokoti.fi', 'nursing123', 'DOCTOR', '👨‍⚕️'),
    TestUser('Liisa Korhonen', 'liisa.korhonen@hoitokoti.fi', 'nursing123', 'PRAC_NURSE', '👩‍⚕️'),
    TestUser('Pekka Laine', 'pekka.laine@hoitokoti.fi', 'nursing123', 'PHYSIO', '🏃‍♂️'),
    TestUser('Kaisa Järvinen', 'kaisa.jarvinen@hoitokoti.fi', 'nursing123', 'PSYCHO', '🧠'),
  ];
  
  TestUser? _selectedUser;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        LoginRequested(
          _emailController.text,
          _passwordController.text,
        ),
      );
    }
  }

  void _fillCredentials(TestUser user) {
    setState(() {
      _emailController.text = user.email;
      _passwordController.text = user.password;
      _selectedUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRouter.home,
              (route) => false,
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Icon(
                    Icons.local_hospital,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Test users section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.people_outline, 
                              color: Colors.blue.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Quick Login - Test Users',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<TestUser>(
                          value: _selectedUser,
                          decoration: const InputDecoration(
                            labelText: 'Select Test User',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: _testUsers.map((user) {
                            return DropdownMenuItem<TestUser>(
                              value: user,
                              child: Text('${user.emoji} ${user.name} (${user.role.replaceAll('_', ' ')})'),
                            );
                          }).toList(),
                          onChanged: (TestUser? user) {
                            if (user != null) {
                              _fillCredentials(user);
                            }
                          },
                        ),
                        if (_selectedUser != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Email: ${_selectedUser!.email}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade600,
                              fontFamily: 'monospace',
                            ),
                          ),
                          Text(
                            'Password: ${_selectedUser!.password}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade600,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state is AuthLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: state is AuthLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Sign In'),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
