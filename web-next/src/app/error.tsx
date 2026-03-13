'use client';

import Link from 'next/link';

interface ErrorProps {
  error: Error & { digest?: string };
  reset: () => void;
}

export default function GlobalError({ error, reset }: ErrorProps) {
  return (
    <div className="min-h-screen flex flex-col bg-bg">
      <main className="flex-1 flex items-center justify-center">
        <div className="text-center px-lg">
          <p className="text-[64px] font-black text-semantic-error leading-none mb-lg">
            :(
          </p>
          <h1 className="text-[24px] font-bold text-text-primary mb-md">
            오류가 발생했습니다
          </h1>
          <p className="text-[15px] text-text-secondary mb-sm">
            일시적인 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.
          </p>
          {error.digest && (
            <p className="text-[12px] text-text-tertiary mb-2xl font-mono">
              오류 코드: {error.digest}
            </p>
          )}
          {!error.digest && <div className="mb-2xl" />}
          <div className="flex flex-col mobile:flex-row items-center justify-center gap-md">
            <button
              onClick={reset}
              className="inline-flex items-center h-[48px] px-xl text-[15px] font-semibold bg-primary text-bg rounded-sm hover:opacity-90 transition-opacity"
            >
              다시 시도
            </button>
            <Link
              href="/"
              className="inline-flex items-center h-[48px] px-xl text-[15px] font-semibold border border-border text-text-primary rounded-sm hover:bg-surface transition-colors"
            >
              홈으로 돌아가기
            </Link>
          </div>
        </div>
      </main>
    </div>
  );
}
