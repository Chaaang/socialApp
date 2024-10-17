import 'package:flutter/material.dart';
import 'package:social_app/features/auth/presentation/components/my_button.dart';
import 'package:social_app/features/auth/presentation/components/my_text_field.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? togglePages;
  const RegisterPage({super.key, required this.togglePages});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final firstNameControoler = TextEditingController();
  final lastNameControoler = TextEditingController();
  final emailController = TextEditingController();
  final passwordControoler = TextEditingController();
  final confirmControoler = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.9),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //LOGO
                    Icon(
                      Icons.lock_open_rounded,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),

                    const SizedBox(
                      height: 50,
                    ),
                    //WELCOME MESSAGE
                    Text(
                      'Welcome back, you\'ve been missed!',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 25),

                    MyTextField(
                        controller: firstNameControoler,
                        obscureText: true,
                        hintText: 'First Name'),
                    const SizedBox(height: 10),
                    MyTextField(
                        controller: lastNameControoler,
                        obscureText: true,
                        hintText: 'Last Name'),
                    const SizedBox(height: 10),
                    // EMAIL TEXTFIELD
                    MyTextField(
                        controller: emailController,
                        obscureText: false,
                        hintText: 'Email'),
                    //PASSWORD TEXTFIELD
                    const SizedBox(height: 10),
                    MyTextField(
                        controller: passwordControoler,
                        obscureText: true,
                        hintText: 'Password'),

                    const SizedBox(height: 10),

                    MyTextField(
                        controller: passwordControoler,
                        obscureText: true,
                        hintText: 'Confirm Password'),
                    //BUTTON
                    const SizedBox(height: 25),
                    MyButton(
                      onTap: widget.togglePages,
                      text: 'Sign In',
                    ),

                    // Message to register
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already a member?',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(width: 5),
                        GestureDetector(
                            onTap: widget.togglePages,
                            child: const Text(
                              'Log in',
                              style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold),
                            ))
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
