// lib/core/config/app_initializer.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart'; 

class AppInitializer {
  static Future<void> init() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,     
      anonKey: SupabaseConfig.anonKey, 
    );
  }
}
