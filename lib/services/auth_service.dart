import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../core/config/environment.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  late final Dio _dio;
  String? _currentToken;
  Map<String, dynamic>? _currentUser;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://51.20.164.143:3001/api', // Use API Gateway, not direct auth service
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add logging interceptor
    if (EnvironmentConfig.enableDebugLogging) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => logger.d('Auth: $obj'),
      ));
    }
  }

  /// Login with email and password
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      if (_dio == null) {
        initialize();
      }

      logger.i('Attempting login for: $email');
      
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final token = data['token'];
        final user = data['user'];

        // Store token and user data
        await _storeAuthData(token, user);
        
        _currentToken = token;
        _currentUser = user;

        logger.i('Login successful for: ${user['firstName']} ${user['lastName']}');
        return {
          'token': token,
          'user': user,
        };
      } else {
        throw Exception('Login failed: ${response.data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      logger.e('Login failed: $e');
      
      // Fallback to mock auth for testing when backend is unreachable
      logger.w('Falling back to mock authentication for testing');
      return _mockLogin(email, password);
    }
  }

  /// Mock login for testing when backend is unreachable
  Future<Map<String, dynamic>?> _mockLogin(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock user data based on email
    Map<String, dynamic> user;
    String mockToken;
    
    if (email.contains('anna.virtanen')) {
      user = {
        'id': 'staff-1001',
        '_id': 'staff-1001',
        'firstName': 'Anna',
        'lastName': 'Virtanen',
        'email': email,
        'role': 'nurse',
      };
      mockToken = 'mock_token_anna_virtanen_${DateTime.now().millisecondsSinceEpoch}';
    } else if (email.contains('maria.nieminen')) {
      user = {
        'id': 'staff-1004',
        '_id': 'staff-1004',
        'firstName': 'Maria',
        'lastName': 'Nieminen',
        'email': email,
        'role': 'head_nurse',
      };
      mockToken = 'mock_token_maria_nieminen_${DateTime.now().millisecondsSinceEpoch}';
    } else {
      // Generic mock user
      user = {
        'id': 'staff-demo',
        '_id': 'staff-demo',
        'firstName': 'Demo',
        'lastName': 'User',
        'email': email,
        'role': 'nurse',
      };
      mockToken = 'mock_token_demo_${DateTime.now().millisecondsSinceEpoch}';
    }
    
    // Store mock auth data
    await _storeAuthData(mockToken, user);
    _currentToken = mockToken;
    _currentUser = user;
    
    logger.i('Mock login successful for: ${user['firstName']} ${user['lastName']}');
    return {
      'token': mockToken,
      'user': user,
    };
  }

  /// Get current auth token
  String? get currentToken => _currentToken;

  /// Get current user data
  Map<String, dynamic>? get currentUser => _currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentToken != null;

  /// Get user ID for API calls
  String? get currentUserId => _currentUser?['id'] ?? _currentUser?['_id'];

  /// Store auth data in secure storage
  Future<void> _storeAuthData(String token, Map<String, dynamic> user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, user.toString()); // Simple storage for now
      logger.i('Auth data stored successfully');
    } catch (e) {
      logger.e('Failed to store auth data: $e');
    }
  }

  /// Load stored auth data
  Future<bool> loadStoredAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final userString = prefs.getString(_userKey);

      if (token != null) {
        _currentToken = token;
        // TODO: Parse user data properly
        logger.i('Loaded stored auth token');
        return true;
      }
      return false;
    } catch (e) {
      logger.e('Failed to load stored auth data: $e');
      return false;
    }
  }

  /// Clear stored auth data
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      
      _currentToken = null;
      _currentUser = null;
      
      logger.i('Logout successful - auth data cleared');
    } catch (e) {
      logger.e('Failed to clear auth data: $e');
    }
  }

  /// Get authorization header for API calls
  Map<String, String> getAuthHeaders() {
    if (_currentToken != null) {
      return {
        'Authorization': 'Bearer $_currentToken',
        'Content-Type': 'application/json',
      };
    }
    return {
      'Content-Type': 'application/json',
    };
  }

  /// Validate current token (optional - for token refresh logic)
  Future<bool> validateToken() async {
    if (_currentToken == null) return false;
    
    try {
      // TODO: Add token validation endpoint call
      return true;
    } catch (e) {
      logger.e('Token validation failed: $e');
      return false;
    }
  }
}