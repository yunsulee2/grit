import { Header } from '@/components/layout/Header';
import { Footer } from '@/components/layout/Footer';
import { HeroSection } from './(main)/_components/HeroSection';
import { HomeClient } from './(main)/_components/HomeClient';
import { mockFundCards } from '@/lib/mock-data';
import { generateWebsiteJsonLd, generateOrganizationJsonLd } from '@/lib/jsonld';

export default function HomePage() {
  // Server-side: load all fund cards (swap with Supabase fetch when ready)
  const funds = mockFundCards;

  // Featured fund: highest participant count among those ending soonest
  const featuredFund = funds.length > 0
    ? [...funds].sort((a, b) => b.currentParticipants - a.currentParticipants)[0]
    : null;

  return (
    <div className="min-h-screen flex flex-col bg-bg">
      <Header />

      <main className="flex-1">
        {/* Hero section — full width */}
        {featuredFund && <HeroSection fund={featuredFund} />}

        {/* Section heading */}
        <div className="max-w-content mx-auto px-lg mobile:px-xl tablet:px-2xl pt-3xl pb-sm">
          <h2 className="text-[18px] font-bold text-text-primary">
            오늘의 공동구매
          </h2>
        </div>

        {/* Client: category tabs + filter chips + fund grid */}
        <HomeClient initialFunds={funds} />
      </main>

      <Footer />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify(generateWebsiteJsonLd(process.env.NEXT_PUBLIC_BASE_URL || 'https://grit.app'))
        }}
      />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify(generateOrganizationJsonLd(process.env.NEXT_PUBLIC_BASE_URL || 'https://grit.app'))
        }}
      />
    </div>
  );
}
