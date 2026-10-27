import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildmart/core/security/secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final Map<String, String> mockStorage = {};
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  setUp(() {
    mockStorage.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'write':
          final key = methodCall.arguments['key'] as String;
          final value = methodCall.arguments['value'] as String;
          mockStorage[key] = value;
          return null;
        case 'read':
          final key = methodCall.arguments['key'] as String;
          return mockStorage[key];
        case 'delete':
          final key = methodCall.arguments['key'] as String;
          mockStorage.remove(key);
          return null;
        case 'deleteAll':
          mockStorage.clear();
          return null;
        case 'readAll':
          return mockStorage;
        case 'containsKey':
          final key = methodCall.arguments['key'] as String;
          return mockStorage.containsKey(key);
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('SecureStorage Service Tests', () {
    final storageService = SecureStorage();

    test('saves and retrieves auth token', () async {
      await storageService.saveToken('test_jwt_access_token');
      final token = await storageService.getToken();

      expect(token, equals('test_jwt_access_token'));
      expect(mockStorage['auth_token'], equals('test_jwt_access_token'));
    });

    test('saves and retrieves refresh token', () async {
      await storageService.saveRefreshToken('test_jwt_refresh_token');
      final refreshToken = await storageService.getRefreshToken();

      expect(refreshToken, equals('test_jwt_refresh_token'));
      expect(mockStorage['refresh_token'], equals('test_jwt_refresh_token'));
    });

    test('saves and retrieves user ID', () async {
      await storageService.saveUserId('user_buildmart_99');
      final userId = await storageService.getUserId();

      expect(userId, equals('user_buildmart_99'));
      expect(mockStorage['user_id'], equals('user_buildmart_99'));
    });

    test('clears all credentials upon logout', () async {
      await storageService.saveToken('token_to_clear');
      await storageService.saveUserId('user_to_clear');
      expect(mockStorage.isNotEmpty, isTrue);

      await storageService.clearAll();
      expect(mockStorage.isEmpty, isTrue);
      expect(await storageService.getToken(), isNull);
    });
  });
}
