class RoutesPath {
  RoutesPath._(); // Prevents instantiation

  // --- Main Sub-routes ---
  static const String home = '/home'; // Relative to /main
  static const String setting = '/setting'; // Relative to /main

  // --- Home Sub-routes ---
  static const String configure = 'configure'; // Relative to /main/home

  // --- Setting Sub-routes ---
  static const String upload = 'upload'; // Relative to /main/setting
  static const String theme = 'theme'; // Relative to /main/setting

  // --- Full Paths (Optional but helpful for navigation) ---
  // You can construct full paths here if you frequently navigate to them directly.
  // This helps avoid manual string concatenation in your navigation calls.
  static const String homeConfigure = '$home/$configure';
  static const String homeUpload = '$home/$upload';
  static const String settingUpload = '$setting/$upload';
  static const String settingTheme = '$setting/$theme';
}
