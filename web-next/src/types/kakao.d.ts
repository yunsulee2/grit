interface KakaoShareContent {
  title: string;
  description: string;
  imageUrl: string;
  link: { mobileWebUrl: string; webUrl: string };
}

interface KakaoShareOptions {
  objectType: 'feed' | 'list' | 'commerce';
  content: KakaoShareContent;
  social?: { likeCount?: number; commentCount?: number; sharedCount?: number };
  buttons?: Array<{ title: string; link: { mobileWebUrl: string; webUrl: string } }>;
}

interface KakaoSDK {
  init: (key: string) => void;
  isInitialized: () => boolean;
  Share: {
    sendDefault: (options: KakaoShareOptions) => void;
  };
}

interface Window {
  Kakao?: KakaoSDK;
}
