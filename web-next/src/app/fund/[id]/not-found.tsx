import Link from 'next/link';
import { Header } from '@/components/layout/Header';
import { Footer } from '@/components/layout/Footer';

export default function FundNotFound() {
  return (
    <div className="min-h-screen flex flex-col bg-bg">
      <Header />
      <main className="flex-1 flex items-center justify-center px-lg">
        <div className="text-center max-w-form mx-auto py-4xl">
          {/* Icon */}
          <div className="flex justify-center mb-2xl">
            <div className="w-[80px] h-[80px] rounded-full bg-surface flex items-center justify-center">
              <svg
                width="40"
                height="40"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="1.5"
                strokeLinecap="round"
                strokeLinejoin="round"
                className="text-text-tertiary"
              >
                <circle cx="11" cy="11" r="8" />
                <line x1="21" y1="21" x2="16.65" y2="16.65" />
                <line x1="8" y1="11" x2="14" y2="11" />
              </svg>
            </div>
          </div>

          {/* Message */}
          <h1 className="text-[20px] font-bold text-text-primary mb-sm">
            펀드를 찾을 수 없습니다
          </h1>
          <p className="text-[14px] text-text-secondary leading-relaxed mb-3xl">
            요청하신 공동구매 펀드가 존재하지 않거나{'\n'}
            이미 종료되었을 수 있습니다.
          </p>

          {/* CTA */}
          <Link
            href="/"
            className="inline-flex items-center justify-center h-[48px] px-2xl bg-primary text-onPrimary rounded-sm font-bold text-[15px] hover:bg-primary/90 active:bg-primary/80 transition-colors"
          >
            홈으로 돌아가기
          </Link>
        </div>
      </main>
      <Footer />
    </div>
  );
}
