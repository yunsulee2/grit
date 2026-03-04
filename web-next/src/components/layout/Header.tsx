'use client';

import { useState } from 'react';
import Link from 'next/link';
import { cn } from '@/lib/utils';
import { useUser } from '@/components/auth/UserContext';
import LoginModal from '@/components/auth/LoginModal';

interface HeaderProps {
  className?: string;
}

function Header({ className }: HeaderProps) {
  const { user, signOut } = useUser();
  const [showLoginModal, setShowLoginModal] = useState(false);
  const [showMobileMenu, setShowMobileMenu] = useState(false);

  return (
    <>
      <header
        className={cn(
          'sticky top-0 z-40 bg-bg border-b border-border-subtle',
          className
        )}
      >
        <div className="max-w-content mx-auto h-[56px] flex items-center justify-between px-lg mobile:px-xl tablet:px-2xl">
          {/* Logo */}
          <Link
            href="/"
            className="text-[22px] font-black tracking-tight text-primary"
          >
            GRIT
          </Link>

          {/* Desktop nav — hidden below tablet */}
          <div className="hidden tablet:flex items-center gap-md">
            {user ? (
              <Link
                href="/mypage"
                className="h-[36px] px-md flex items-center text-[13px] font-semibold text-text-primary border border-border rounded-sm hover:bg-surface transition-colors"
              >
                마이페이지
              </Link>
            ) : (
              <button
                type="button"
                onClick={() => setShowLoginModal(true)}
                className="h-[36px] px-md flex items-center text-[13px] font-semibold text-text-primary border border-border rounded-sm hover:bg-surface transition-colors"
              >
                로그인
              </button>
            )}
          </div>

          {/* Mobile hamburger — shown below tablet */}
          <button
            type="button"
            className="tablet:hidden flex items-center justify-center w-[36px] h-[36px]"
            onClick={() => setShowMobileMenu(true)}
            aria-label="메뉴 열기"
          >
            <svg width="20" height="20" viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round">
              <path d="M3 5h14M3 10h14M3 15h14" />
            </svg>
          </button>
        </div>
      </header>

      {/* Mobile menu overlay */}
      {showMobileMenu && (
        <div className="fixed inset-0 z-50 tablet:hidden">
          {/* Backdrop */}
          <div
            className="absolute inset-0 bg-black/50 animate-fade-in"
            onClick={() => setShowMobileMenu(false)}
          />

          {/* Slide-in panel */}
          <nav
            className="absolute top-0 right-0 bottom-0 w-[280px] bg-bg shadow-elevated flex flex-col animate-slide-right"
            aria-label="모바일 메뉴"
          >
            {/* Close button */}
            <div className="flex items-center justify-end h-[56px] px-lg">
              <button
                type="button"
                onClick={() => setShowMobileMenu(false)}
                className="flex items-center justify-center w-[36px] h-[36px]"
                aria-label="메뉴 닫기"
              >
                <svg width="20" height="20" viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round">
                  <path d="M5 5l10 10M15 5L5 15" />
                </svg>
              </button>
            </div>

            {/* Menu items */}
            <div className="flex flex-col px-lg gap-xs">
              <Link
                href="/"
                onClick={() => setShowMobileMenu(false)}
                className="py-md text-[15px] font-medium text-text-primary hover:text-primary transition-colors"
              >
                홈
              </Link>
              <Link
                href="/guide"
                onClick={() => setShowMobileMenu(false)}
                className="py-md text-[15px] font-medium text-text-primary hover:text-primary transition-colors"
              >
                이용안내
              </Link>
              <Link
                href="/terms"
                onClick={() => setShowMobileMenu(false)}
                className="py-md text-[15px] font-medium text-text-primary hover:text-primary transition-colors"
              >
                이용약관
              </Link>

              {/* Divider */}
              <div className="border-t border-border-subtle my-sm" />

              {user ? (
                <>
                  <Link
                    href="/mypage"
                    onClick={() => setShowMobileMenu(false)}
                    className="py-md text-[15px] font-medium text-text-primary hover:text-primary transition-colors"
                  >
                    마이페이지
                  </Link>
                  <button
                    type="button"
                    onClick={() => {
                      setShowMobileMenu(false);
                      signOut();
                    }}
                    className="py-md text-[15px] font-medium text-text-secondary hover:text-primary transition-colors text-left"
                  >
                    로그아웃
                  </button>
                </>
              ) : (
                <button
                  type="button"
                  onClick={() => {
                    setShowMobileMenu(false);
                    setShowLoginModal(true);
                  }}
                  className="py-md text-[15px] font-medium text-text-primary hover:text-primary transition-colors text-left"
                >
                  로그인
                </button>
              )}
            </div>
          </nav>
        </div>
      )}

      {/* Login modal */}
      <LoginModal
        isOpen={showLoginModal}
        onClose={() => setShowLoginModal(false)}
      />
    </>
  );
}

export { Header };
export type { HeaderProps };
