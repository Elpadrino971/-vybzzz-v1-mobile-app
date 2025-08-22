import 'package:flutter_test/flutter_test.dart';
import 'package:vybzzz/common/config/deepar_config.dart';

void main() {
  group('DeepAR Configuration Tests', () {
    test('iOS License Key is configured', () {
      expect(DeepARConfig.iosLicenseKey, isNotEmpty);
      expect(DeepARConfig.iosLicenseKey.length, greaterThan(50));
      expect(DeepARConfig.iosLicenseKey, contains('a21c2790ef33df0f2523d5c1f34461e5898132abf0d5a5c9bdc8e24aaafee0d3e1136f170a7327ef'));
    });

    test('Bundle identifiers are correct', () {
      expect(DeepARConfig.iosBundleId, equals('com.vybzzz.deepar'));
      expect(DeepARConfig.androidBundleId, equals('com.vybzzz.deepar'));
    });

    test('DeepAR features are enabled', () {
      expect(DeepARConfig.enableAR, isTrue);
      expect(DeepARConfig.enableFaceTracking, isTrue);
    });

    test('Performance settings are valid', () {
      expect(DeepARConfig.defaultResolution, isIn(['low', 'medium', 'high']));
      expect(DeepARConfig.maxCacheSize, greaterThan(0));
    });

    test('Filter settings are configured', () {
      expect(DeepARConfig.defaultFilterPath, isNotEmpty);
      expect(DeepARConfig.supportedFormats, contains('.ar'));
      expect(DeepARConfig.supportedFormats, contains('.zip'));
    });

    test('Camera settings are enabled', () {
      expect(DeepARConfig.enableFrontCamera, isTrue);
      expect(DeepARConfig.enableBackCamera, isTrue);
      expect(DeepARConfig.enableFlash, isTrue);
    });
  });
}
