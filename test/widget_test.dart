import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prm393_lab_7/main.dart';

void main() {
  testWidgets('Lab 7 - Signup Form: layout, validation rules, focus & submit flow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // ------------------------------------------------------------------------
    // 1. Initial Render & Check Fields (Lab 7.1)
    // ------------------------------------------------------------------------
    await tester.pumpWidget(const SignupApp());
    await tester.pump();

    // Verify title and main elements
    expect(find.text('Signup Form'), findsOneWidget);
    expect(find.text('Full Name *'), findsOneWidget);
    expect(find.text('Email Address *'), findsOneWidget);
    expect(find.text('Password *'), findsOneWidget);
    expect(find.text('Confirm Password *'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(4));
    expect(find.byType(CheckboxListTile), findsOneWidget);

    // ------------------------------------------------------------------------
    // 2. Submit with Empty Fields -> Trigger Validation Errors (Lab 7.2)
    // ------------------------------------------------------------------------
    final submitButton = find.widgetWithText(ElevatedButton, 'Create Account');
    expect(submitButton, findsOneWidget);

    await tester.tap(submitButton);
    await tester.pump();

    // Verify required error messages are shown
    expect(find.text('Full name is required'), findsOneWidget);
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(find.text('Please confirm your password'), findsOneWidget);
    expect(find.text('You must accept the terms to proceed'), findsOneWidget);

    // ------------------------------------------------------------------------
    // 3. Test Invalid Email and Password Rules
    // ------------------------------------------------------------------------
    final nameField = find.byType(TextFormField).at(0);
    final emailField = find.byType(TextFormField).at(1);
    final passwordField = find.byType(TextFormField).at(2);
    final confirmField = find.byType(TextFormField).at(3);

    await tester.enterText(nameField, 'A'); // Too short
    await tester.enterText(emailField, 'notanemail'); // Invalid format
    await tester.enterText(passwordField, 'short'); // < 8 chars
    await tester.enterText(confirmField, 'mismatch'); // Not matching
    await tester.pump();

    expect(find.text('Name must be at least 2 characters'), findsOneWidget);
    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(find.text('Password must be at least 8 characters'), findsOneWidget);
    expect(find.text('Passwords do not match'), findsOneWidget);

    // Test password without numbers
    await tester.enterText(passwordField, 'longenoughpassword');
    await tester.pump();
    expect(find.text('Password must contain at least 1 number'), findsOneWidget);

    // ------------------------------------------------------------------------
    // 4. Test Async Validation for Taken Email (Lab 7.4)
    // ------------------------------------------------------------------------
    await tester.enterText(nameField, 'John Doe');
    await tester.enterText(emailField, 'taken@example.com');
    await tester.enterText(passwordField, 'secret123');
    await tester.enterText(confirmField, 'secret123');

    // Agree to terms
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();

    // Tap submit -> Trigger async email check
    await tester.tap(submitButton);
    await tester.pump(); // Start async check

    // Verify loading indicator is displayed in submit button
    expect(find.text('Checking email...'), findsOneWidget);

    // Advance time by 2 seconds to complete simulated async check
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    // Verify error for taken email
    expect(find.text('This email is already taken. Try another.'), findsOneWidget);

    // ------------------------------------------------------------------------
    // 5. Test Successful Registration (Lab 7.4 Success Flow)
    // ------------------------------------------------------------------------
    await tester.enterText(emailField, 'valid.user@example.com');
    await tester.pump();

    await tester.tap(submitButton);
    await tester.pump();

    expect(find.text('Checking email...'), findsOneWidget);

    // Complete async check
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    // Verify Success Dialog is presented
    expect(find.text('Signup Successful!'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.descendant(of: find.byType(AlertDialog), matching: find.text('John Doe')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: find.byType(AlertDialog), matching: find.text('valid.user@example.com')),
      findsOneWidget,
    );
    expect(find.widgetWithText(ElevatedButton, 'Continue'), findsOneWidget);

    // Tap Continue to dismiss dialog
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pump();
    expect(find.text('Signup Successful!'), findsNothing);
  });
}
