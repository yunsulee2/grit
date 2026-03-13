import Link from 'next/link';
import { Header } from '@/components/layout/Header';
import { Footer } from '@/components/layout/Footer';

export default function NotFound() {
  return (
    <div className="min-h-screen flex flex-col bg-bg">
      <Header />

      <main className="flex-1 flex items-center justify-center">
        <div className="text-center px-lg">
          <p className="text-[96px] font-black text-primary leading-none mb-lg">
            404
          </p>
          <h1 className="text-[24px] font-bold text-text-primary mb-md">
            페이지를 찾을 수 없습니다
          </h1>
          <p className="text-[15px] text-text-secondary mb-2xl">
            요청하신 페이지가 존재하지 않거나 이동되었습니다.
          </p>
          <Link
            href="/"
            className="inline-flex items-center h-[48px] px-xl text-[15px] font-semibold bg-primary text-bg rounded-sm hover:opacity-90 transition-opacity"
          >
            홈으로 돌아가기
          </Link>
        </div>
      </main>

      <Footer />
    </div>
  );
}
