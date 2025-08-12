import 'models.dart';

class MockDatabase {
  static List<User> users = [];
  static List<Product> products = [];
  static List<QuoteRequest> quoteRequests = [];

  static bool userExists(String email) {
    return users.any((u) => u.email == email);
  }

  static void addUser(User user) {
    users.add(user);
  }

  static void addProduct(Product product) {
    products.add(product);
  }

  static void addQuoteRequest(QuoteRequest request) {
    quoteRequests.add(request);
  }

  // تحديث حالة التحقق للمستخدم (الطريقة القديمة للتوافق مع الكود القديم)
  static void updateUserVerification(String userId, bool isVerified) {
    updateUserVerificationStatus(userId, isVerified, 'email');
  }

  // تحديث حالة التحقق للمستخدم (طريقة محسنة تدعم التحقق من البريد والهاتف)
  static void updateUserVerificationStatus(
      String userId, bool isVerified, String verificationType) {
    final userIndex = users.indexWhere((u) => u.id == userId);
    if (userIndex != -1) {
      final user = users[userIndex];

      // تحديد نوع التحقق (بريد إلكتروني أو هاتف)
      bool updatedEmailVerified = user.verified;
      bool updatedPhoneVerified = user.phoneVerified;

      if (verificationType == 'email') {
        updatedEmailVerified = isVerified;
      } else if (verificationType == 'phone') {
        updatedPhoneVerified = isVerified;
      }

      // إنشاء مستخدم جديد مع تحديث حالة التحقق لأن النموذج غير قابل للتعديل
      final updatedUser = User(
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        type: user.type,
        createdAt: user.createdAt,
        institution: user.institution,
        verified: updatedEmailVerified,
        phoneVerified: updatedPhoneVerified,
        isActive: user.isActive,
        lastLogin: DateTime.now(),
        profileImage: user.profileImage,
        encryptedData: user.encryptedData,
        accessToken: user.accessToken,
        permissions: user.permissions,
      );

      // استبدال المستخدم القديم بالمستخدم المحدث
      users[userIndex] = updatedUser;
    }
  }

  // البحث عن مستخدم عن طريق البريد الإلكتروني
  static User? getUserByEmail(String email) {
    try {
      return users.firstWhere((u) => u.email == email);
    } catch (e) {
      return null;
    }
  }
}

// Optional: Example usage for testing
void main() {
  // MockDatabase.addUser(User(...));
  // MockDatabase.addProduct(Product(...));
  // MockDatabase.addQuoteRequest(QuoteRequest(...));
}
