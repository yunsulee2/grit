'use client';

import Link from 'next/link';
import { useUser } from '@/components/auth/UserContext';
import { useToast } from '@/components/ui/Toast';

interface MenuItem {
  type: 'link';
  label: string;
  href: string;
}

interface MenuActionItem {
  type: 'button';
  label: string;
  onClick: () => void;
  danger?: boolean;
}

type MenuEntry = MenuItem | MenuActionItem;

function ChevronRight() {
  return (
    <svg
      className="w-[16px] h-[16px] text-text-tertiary"
      fill="none"
      stroke="currentColor"
      viewBox="0 0 24 24"
    >
      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
    </svg>
  );
}

function MenuSection() {
  const { signOut } = useUser();
  const { toast } = useToast();

  function showComingSoon() {
    toast({ variant: 'info', message: '준비 중입니다' });
  }

  const entries: MenuEntry[] = [
    { type: 'button', label: '배송지 관리', onClick: showComingSoon },
    { type: 'button', label: '문의하기', onClick: showComingSoon },
    { type: 'link', label: '이용약관', href: '/terms' },
    { type: 'link', label: '개인정보처리방침', href: '/privacy' },
    { type: 'button', label: '로그아웃', onClick: signOut, danger: true },
  ];

  return (
    <div className="mt-xl bg-bg border border-border-subtle rounded-sm overflow-hidden">
      {entries.map((entry, idx) => {
        const isLast = idx === entries.length - 1;
        const divider = !isLast ? (
          <div className="mx-lg border-b border-border-subtle" />
        ) : null;

        if (entry.type === 'link') {
          return (
            <div key={entry.href}>
              <Link
                href={entry.href}
                className="flex items-center justify-between px-lg py-md hover:bg-surface transition-colors"
              >
                <span className="text-[15px] text-text-primary">{entry.label}</span>
                <ChevronRight />
              </Link>
              {divider}
            </div>
          );
        }

        return (
          <div key={entry.label}>
            <button
              onClick={entry.onClick}
              className="w-full flex items-center justify-between px-lg py-md hover:bg-surface transition-colors"
            >
              <span
                className={
                  entry.danger
                    ? 'text-[15px] text-semantic-error'
                    : 'text-[15px] text-text-primary'
                }
              >
                {entry.label}
              </span>
              <ChevronRight />
            </button>
            {divider}
          </div>
        );
      })}
    </div>
  );
}

export { MenuSection };
