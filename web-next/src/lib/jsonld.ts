import type { FundDetailData } from '@/types/fund';

export function generateProductJsonLd(fund: FundDetailData, currentPrice: number, url: string) {
  return {
    '@context': 'https://schema.org',
    '@type': 'Product',
    name: fund.productName,
    description: fund.description,
    image: fund.images[0],
    brand: { '@type': 'Brand', name: fund.brandName },
    offers: {
      '@type': 'AggregateOffer',
      priceCurrency: 'KRW',
      lowPrice: fund.targetPrice,
      highPrice: fund.startPrice,
      offerCount: fund.currentParticipants,
      availability: 'https://schema.org/InStock',
      url,
    },
  };
}

export function generateBreadcrumbJsonLd(items: { name: string; url: string }[]) {
  return {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: items.map((item, i) => ({
      '@type': 'ListItem',
      position: i + 1,
      name: item.name,
      item: item.url,
    })),
  };
}

export function generateWebsiteJsonLd(baseUrl: string) {
  return {
    '@context': 'https://schema.org',
    '@type': 'WebSite',
    name: 'GRIT',
    description: '함께 모여 더 싸게! 피트니스 식품 펀드형 공동구매 플랫폼',
    url: baseUrl,
  };
}

export function generateOrganizationJsonLd(baseUrl: string) {
  return {
    '@context': 'https://schema.org',
    '@type': 'Organization',
    name: 'GRIT',
    url: baseUrl,
    description: '피트니스 식품 공동구매 플랫폼',
  };
}
