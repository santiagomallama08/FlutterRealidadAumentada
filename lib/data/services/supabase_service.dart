// lib/data/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  /// 🔹 Registrar un nuevo usuario (email + contraseña)
  Future<AuthResponse?> signUp(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error desconocido al registrar: $e');
    }
  }

  /// 🔹 Iniciar sesión con email + contraseña
  Future<AuthResponse?> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error desconocido al iniciar sesión: $e');
    }
  }

  /// 🔹 Cerrar sesión
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  /// 🔹 Obtener sesión actual
  Session? get currentSession => _client.auth.currentSession;

  /// 🔹 Obtener usuario actual
  User? get currentUser => _client.auth.currentUser;
}
