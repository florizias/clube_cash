enum AppFlavor { dev, prod }

class AppConfig {
  final AppFlavor flavor;
  const AppConfig(this.flavor);

  bool get isDev => flavor == AppFlavor.dev;
  bool get isProd => flavor == AppFlavor.prod;
}
