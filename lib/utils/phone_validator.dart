class PhoneValidator {
  /// Validates phone number with country code
  /// Supports formats: +1234567890, +1-234-567-890, +1 234 567 890, etc.
  static bool isValidPhoneNumber(String phone) {
    // Remove all spaces, dashes, and parentheses
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Must start with + and have country code (1-3 digits) followed by number
    // Minimum: +1234567890 (11 digits total)
    // Maximum: +123456789012345 (16 digits total)
    final pattern = RegExp(r'^\+[1-9]\d{9,14}$');
    
    return pattern.hasMatch(cleaned);
  }

  /// Formats phone number for display
  static String formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    if (cleaned.startsWith('+')) {
      final countryCode = cleaned.substring(0, cleaned.length > 11 ? 3 : 2);
      final number = cleaned.substring(countryCode.length);
      
      // Format based on length
      if (number.length == 10) {
        // US format: (123) 456-7890
        return '$countryCode (${number.substring(0, 3)}) ${number.substring(3, 6)}-${number.substring(6)}';
      } else if (number.length > 10) {
        // International format: +1 234 567 8901
        return '$countryCode ${number.substring(0, 3)} ${number.substring(3, 6)} ${number.substring(6)}';
      }
    }
    
    return phone;
  }

  /// Gets error message for invalid phone number
  static String? getPhoneError(String phone) {
    if (phone.trim().isEmpty) {
      return 'Phone number cannot be empty';
    }
    
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    if (!cleaned.startsWith('+')) {
      return 'Phone number must start with country code (e.g., +1, +44, +91)';
    }
    
    if (cleaned.length < 11) {
      return 'Phone number too short (minimum 10 digits after country code)';
    }
    
    if (cleaned.length > 16) {
      return 'Phone number too long (maximum 15 digits after country code)';
    }
    
    if (!isValidPhoneNumber(phone)) {
      return 'Invalid phone number format';
    }
    
    return null;
  }
}

