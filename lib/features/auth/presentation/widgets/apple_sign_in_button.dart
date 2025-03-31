import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:umd_dining_refactor/features/auth/presentation/bloc/auth_bloc.dart'
    as auth_bloc;

class AppleSignInButton extends StatelessWidget {
  const AppleSignInButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ElevatedButton(
        onPressed: () {
          context.read<auth_bloc.AuthBloc>().add(
                auth_bloc.AuthSignUpApple(),
              );
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(75),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Image.asset(
                'assets/images/Apple-Logo.png',
                height: 30,
              ),
            ),
            const Text(
              "Continue with Apple",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
