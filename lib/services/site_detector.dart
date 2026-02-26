enum SupportedSite { coupang, naver, kakao, other }

class SiteDetector {
  /// Detects the site from a URL string
  static SupportedSite detect(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host.toLowerCase();
      if (host == 'coupang.com' || host.endsWith('.coupang.com')) {
        return SupportedSite.coupang;
      }
      if (host == 'smartstore.naver.com' || host.endsWith('.smartstore.naver.com')) {
        return SupportedSite.naver;
      }
      if (host == 'store.kakao.com' || host.endsWith('.store.kakao.com')) {
        return SupportedSite.kakao;
      }
      return SupportedSite.other;
    } catch (_) {
      return SupportedSite.other;
    }
  }

  /// Returns the display name for a site
  static String displayName(SupportedSite site) {
    switch (site) {
      case SupportedSite.coupang:
        return '쿠팡';
      case SupportedSite.naver:
        return '네이버 스마트스토어';
      case SupportedSite.kakao:
        return '카카오 톡딜';
      case SupportedSite.other:
        return '기타';
    }
  }

  /// Returns whether the site is a P0 priority (high confidence extraction)
  static bool isP0(SupportedSite site) {
    return site == SupportedSite.coupang || site == SupportedSite.naver;
  }

  /// Validates if a string is a valid URL format
  static bool isValidUrl(String url) {
    if (!url.startsWith('https://') && !url.startsWith('http://')) {
      return false;
    }
    try {
      final uri = Uri.parse(url);
      return uri.host.isNotEmpty && uri.host.contains('.');
    } catch (_) {
      return false;
    }
  }

  /// Returns a warning message for non-P0 sites
  static String? getWarningMessage(SupportedSite site) {
    switch (site) {
      case SupportedSite.coupang:
      case SupportedSite.naver:
        return null;
      case SupportedSite.kakao:
        return '이 사이트는 자동 추출 정확도가 낮을 수 있습니다';
      case SupportedSite.other:
        return '이 사이트는 자동 추출이 지원되지 않을 수 있습니다. 시도는 가능합니다.';
    }
  }
}
