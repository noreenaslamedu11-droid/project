class EmailService {
  // ✅ Make this Future<void> so that await works properly
  Future<void> sendEmail(String to, String subject, String message) async {
    // For now just print, in real app you can integrate SMTP or API
    print('Email sent to $to with subject: $subject');
  }
}
