import type { Metadata } from 'next';
import { notFound } from 'next/navigation';
import { getMockFundDetail } from '@/lib/mock-data';
import { formatPrice, formatNumber, calculateCurrentPrice } from '@/lib/utils';
import { Header } from '@/components/layout/Header';
import { Footer } from '@/components/layout/Footer';
import { FundDetailClient } from './_components/FundDetailClient';
import { generateProductJsonLd, generateBreadcrumbJsonLd } from '@/lib/jsonld';

interface PageProps {
  params: Promise<{ id: string }>;
}

async function getFundDetail(id: string) {
  // TODO: Replace with actual API call when backend is ready
  return getMockFundDetail(id);
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { id } = await params;
  const fund = await getFundDetail(id);

  if (!fund) {
    return { title: '펀드를 찾을 수 없습니다 - GRIT' };
  }

  const nextMessage = fund.nextTier
    ? `${formatNumber(fund.nextTier.needed)}명만 더 모이면 ${formatPrice(fund.nextTier.price)}`
    : '';

  const title = `${fund.productName} 공동구매 — 지금 ${formatPrice(fund.currentPrice)}`;
  const description = `${formatNumber(fund.currentParticipants)}명 참여 중!${nextMessage ? ` ${nextMessage}` : ''}`;

  const baseUrl = process.env.NEXT_PUBLIC_BASE_URL || 'https://grit.kr';
  const canonicalUrl = `${baseUrl}/fund/${id}`;

  return {
    title,
    description,
    openGraph: {
      title,
      description,
      images: fund.images[0] ? [{ url: fund.images[0] }] : [],
      type: 'website',
      locale: 'ko_KR',
      url: canonicalUrl,
    },
  };
}

export default async function FundDetailPage({ params }: PageProps) {
  const { id } = await params;
  const fund = await getFundDetail(id);

  if (!fund) {
    notFound();
  }

  const baseUrl = process.env.NEXT_PUBLIC_BASE_URL || 'https://grit.kr';
  const currentPrice = calculateCurrentPrice(fund.tiers, fund.currentParticipants);

  return (
    <div className="min-h-screen flex flex-col bg-bg">
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify(generateProductJsonLd(fund, currentPrice, `${baseUrl}/fund/${id}`))
        }}
      />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify(generateBreadcrumbJsonLd([
            { name: '홈', url: baseUrl },
            { name: fund.productName, url: `${baseUrl}/fund/${id}` },
          ]))
        }}
      />
      <Header />
      <main className="flex-1 max-w-content mx-auto w-full">
        <FundDetailClient initialData={fund} />
      </main>
      <Footer className="pb-[88px]" />
    </div>
  );
}
