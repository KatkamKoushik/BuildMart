class AdminConstants {
  // Configured administrative email addresses
  static const List<String> adminEmails = [
    'admin@buildmart.dev',
    'developer@buildmart.dev',
  ];

  static bool isAdmin(String email) {
    return adminEmails.contains(email.toLowerCase().trim());
  }
}
