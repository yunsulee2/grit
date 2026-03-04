import { cn } from '@/lib/utils';
import type { ReactNode } from 'react';

interface MobileLayoutProps {
  children: ReactNode;
  className?: string;
  maxWidth?: 'content' | 'form' | 'detail' | 'page';
}

const maxWidthMap: Record<NonNullable<MobileLayoutProps['maxWidth']>, string> = {
  content: 'max-w-content',
  form: 'max-w-form',
  detail: 'max-w-detail',
  page: 'max-w-page',
};

function MobileLayout({ children, className, maxWidth = 'content' }: MobileLayoutProps) {
  return (
    <div
      className={cn(
        'w-full mx-auto px-lg mobile:px-xl tablet:px-2xl',
        maxWidthMap[maxWidth],
        className
      )}
    >
      {children}
    </div>
  );
}

export { MobileLayout };
export type { MobileLayoutProps };
