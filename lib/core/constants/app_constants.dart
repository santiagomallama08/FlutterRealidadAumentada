class AppConstants {
  // 🧠 Parámetros por defecto
  static const double defaultStrength = 0.75;

  // 🪣 Nombre del bucket de Supabase
  static const String supabaseBucketGenerated = 'generated_images';

  // 🧬 Modelo por defecto de IA (puedes cambiarlo según tu setup)
  static const String stabilityModel = 'stable-diffusion-xl-1024-v1-0';

  // 🌐 Endpoint base si lo necesitas
  static const String apiBaseUrl = 'https://api.stability.ai/v1';
}
