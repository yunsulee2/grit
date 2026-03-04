'use client';

import { cn } from '@/lib/utils';
import { useState, useEffect } from 'react';
import { useToast } from '@/components/ui/Toast';
import { trackEvent } from '@/lib/analytics';

interface ShareButtonsProps {
  shareUrl?: string;
  productName?: string;
  imageUrl?: string;
  description?: string;
  participantCount?: number;
  userId?: string;
  className?: string;
}

function ShareButtons({
  shareUrl,
  productName,
  imageUrl,
  description,
  participantCount,
  userId,
  className,
}: ShareButtonsProps) {
  const [copied, setCopied] = useState(false);
  const [kakaoReady, setKakaoReady] = useState(false);
  const { toast } = useToast();

  useEffect(() => {
    // Poll until Kakao SDK is loaded and initialized
    const check = () => {
      if (window.Kakao && window.Kakao.isInitialized()) {
        setKakaoReady(true);
      }
    };
    check();
    const interval = setInterval(check, 300);
    return () => clearInterval(interval);
  }, []);

  const buildShareUrl = () => {
    if (!shareUrl) return '';
    const url = new URL(shareUrl);
    url.searchParams.set('utm_source', 'kakao');
    url.searchParams.set('utm_medium', 'share');
    if (userId) url.searchParams.set('ref', userId);
    return url.toString();
  };

  const handleKakao = () => {
    const url = buildShareUrl() || shareUrl || '';

    if (kakaoReady && window.Kakao) {
      window.Kakao.Share.sendDefault({
        objectType: 'feed',
        content: {
          title: productName || 'GRIT 공동구매',
          description: description || '함께 모여 더 싸게!',
          imageUrl: imageUrl || '',
          link: {
            mobileWebUrl: url,
            webUrl: url,
          },
        },
        social: participantCount !== undefined ? { likeCount: participantCount } : undefined,
        buttons: [
          {
            title: '참여하기',
            link: {
              mobileWebUrl: url,
              webUrl: url,
            },
          },
        ],
      });
      trackEvent('share_kakao', { product_name: productName || '' });
    } else {
      // Fallback: copy link if Kakao SDK not available
      if (url) {
        navigator.clipboard.writeText(url).catch(() => {
          console.error('[ShareButtons] Failed to copy link as Kakao fallback');
        });
      }
      // Kakao SDK not ready — fell back to link copy
    }
  };

  // Instagram story sharing is not yet available; button is removed.

  const handleCopyLink = async () => {
    if (!shareUrl) return;
    try {
      await navigator.clipboard.writeText(shareUrl);
      setCopied(true);
      toast({ variant: 'success', message: '링크가 복사되었습니다' });
      trackEvent('share_link', { product_name: productName || '' });
      setTimeout(() => setCopied(false), 2000);
    } catch {
      console.error('[ShareButtons] Failed to copy link');
    }
  };

  return (
    <div className={cn('flex items-start justify-center gap-3xl', className)}>
      {/* Kakao */}
      <ShareButton
        label="카카오톡 공유"
        onClick={handleKakao}
        bgClassName="bg-[#FEE500]"
        icon={
          <svg width="22" height="22" viewBox="0 0 24 24" fill="#3A1D1D">
            <path d="M12 3C6.48 3 2 6.58 2 10.9c0 2.8 1.86 5.27 4.66 6.67l-1.2 4.37c-.1.37.32.67.65.46L10.6 19.3c.46.06.93.1 1.4.1 5.52 0 10-3.58 10-7.9S17.52 3 12 3z" />
          </svg>
        }
      />

      {/* Link copy */}
      <ShareButton
        label={copied ? '복사됨!' : '링크 복사'}
        onClick={handleCopyLink}
        bgClassName="bg-border-subtle"
        icon={
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#8E8E93" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71" />
            <path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71" />
          </svg>
        }
      />
    </div>
  );
}

/* -- Individual share button ---------------------------------------------------------- */

function ShareButton({
  label,
  onClick,
  bgClassName,
  icon,
}: {
  label: string;
  onClick: () => void;
  bgClassName: string;
  icon: React.ReactNode;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className="flex flex-col items-center gap-[6px] cursor-pointer"
    >
      <div
        className={cn(
          'w-[48px] h-[48px] rounded-full flex items-center justify-center',
          bgClassName
        )}
      >
        {icon}
      </div>
      <span className="text-[12px] text-text-secondary whitespace-nowrap">
        {label}
      </span>
    </button>
  );
}

export { ShareButtons };
export type { ShareButtonsProps };
