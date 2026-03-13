import { Header } from '@/components/layout/Header';
import { Footer } from '@/components/layout/Footer';
import { MobileLayout } from '@/components/layout/MobileLayout';
import { MyPageClient } from './_components/MyPageClient';

export const metadata = {
  title: '마이페이지 — GRIT',
  description: '내 참여 내역, 배송 현황, 프로필을 확인하세요.',
};

export default function MyPage() {
  return (
    <>
      <Header />
      <main className="min-h-screen bg-surface-tinted">
        <MobileLayout maxWidth="form" className="px-0">
          <MyPageClient />
        </MobileLayout>
      </main>
      <Footer />
    </>
  );
}
