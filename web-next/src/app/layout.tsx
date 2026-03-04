import type { Metadata } from 'next';
import { Noto_Sans_KR } from 'next/font/google';
import './globals.css';
import { KakaoScript } from '@/components/KakaoScript';
import { Providers } from './Providers';
import { GoogleAnalytics } from '@/components/GoogleAnalytics';

const notoSansKR = Noto_Sans_KR({
  subsets: ['latin'],
  variable: '--font-noto-sans-kr',
  display: 'swap',
});

export const metadata: Metadata = {
  title: 'GRIT — 피트니스 식품 공동구매',
  description: '함께 모여 더 싸게! 피트니스 식품 펀드형 공동구매 플랫폼',
  openGraph: {
    title: 'GRIT — 피트니스 식품 공동구매',
    description: '함께 모여 더 싸게! 피트니스 식품 펀드형 공동구매 플랫폼',
    type: 'website',
    locale: 'ko_KR',
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ko" className={notoSansKR.variable}>
      <body className="font-sans min-h-screen">
        <Providers>{children}</Providers>
        <KakaoScript />
        <GoogleAnalytics />
      </body>
    </html>
  );
}
