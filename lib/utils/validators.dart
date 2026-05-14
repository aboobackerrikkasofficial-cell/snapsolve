import 'package:email_validator/email_validator.dart';

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final trimmedValue = value.trim();
    if (!EmailValidator.validate(trimmedValue)) {
      return 'Please enter a valid email address';
    }

    // Additional strict checks
    if (!trimmedValue.contains('.') ||
        trimmedValue.split('@').last.split('.').last.length < 2) {
      return 'Invalid email domain';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }

    if (value.trim().split(' ').length < 2) {
      return 'Please enter your full name (first and last)';
    }

    return null;
  }
}
