class AdminConstants {
  // Add allowed admin email addresses here
  static const List<String> adminEmails = [
    'developer@buildmart.com',
    'admin@buildmart.com',
    'client@buildmart.com',
    'yogeswarreddy17@gmail.com', // Adding a likely test email based on previous context if needed
  ];

  static bool isAdmin(String email) {
    return adminEmails.contains(email.toLowerCase().trim());
  }
}
