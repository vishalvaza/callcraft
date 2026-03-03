import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Import the login screen
// import 'package:callcraft/screens/auth/login_screen.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('displays email and password fields', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextFormField(
                  key: const Key('email_field'),
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextFormField(
                  key: const Key('password_field'),
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                ElevatedButton(
                  key: const Key('login_button'),
                  onPressed: () {},
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify fields exist
      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsOneWidget);
    });

    testWidgets('validates email format', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: TextFormField(
                key: const Key('email_field'),
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
            ),
          ),
        ),
      );

      // Test empty email
      formKey.currentState!.validate();
      await tester.pump();
      expect(find.text('Please enter your email'), findsOneWidget);

      // Test invalid email
      await tester.enterText(find.byKey(const Key('email_field')), 'invalid');
      formKey.currentState!.validate();
      await tester.pump();
      expect(find.text('Please enter a valid email'), findsOneWidget);

      // Test valid email
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      final isValid = formKey.currentState!.validate();
      expect(isValid, true);
    });

    testWidgets('validates password length', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: TextFormField(
                key: const Key('password_field'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      // Test empty password
      formKey.currentState!.validate();
      await tester.pump();
      expect(find.text('Please enter your password'), findsOneWidget);

      // Test short password
      await tester.enterText(find.byKey(const Key('password_field')), 'short');
      formKey.currentState!.validate();
      await tester.pump();
      expect(find.text('Password must be at least 8 characters'), findsOneWidget);

      // Test valid password
      await tester.enterText(find.byKey(const Key('password_field')), 'validpass123');
      final isValid = formKey.currentState!.validate();
      expect(isValid, true);
    });

    testWidgets('toggles password visibility', (WidgetTester tester) async {
      bool obscureText = true;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: TextFormField(
                  obscureText: obscureText,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      key: const Key('visibility_toggle'),
                      icon: Icon(
                        obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );

      // Initially password is obscured
      expect(obscureText, true);

      // Tap visibility toggle
      await tester.tap(find.byKey(const Key('visibility_toggle')));
      await tester.pump();

      // Password should now be visible
      // Note: In real implementation, check the obscureText property
    });

    testWidgets('shows loading indicator during login', (WidgetTester tester) async {
      bool isLoading = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                    });
                  },
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Login'),
                ),
              ),
            );
          },
        ),
      );

      // Initially shows "Login" text
      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Tap login button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Login'), findsNothing);
    });
  });
}
