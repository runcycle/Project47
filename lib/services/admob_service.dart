import "dart:io";

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-6574097995292239~6589840728";
    } else if (Platform.isIOS) {
      return "ca-app-pub-6574097995292239~9350723679";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}
