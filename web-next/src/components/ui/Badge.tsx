import { cn } from '@/lib/utils';
import type { ReactNode } from 'react';

type BadgeVariant = 'success' | 'error' | 'warning' | 'info' | 'accent' | 'default';

interface BadgeProps {
  variant?: BadgeVariant;
  children: ReactNode;
  className?: string;
}

const variantStyles: Record<BadgeVariant, string> = {
  success: 'bg-semantic-success-muted text-semantic-success',
  error: 'bg-semantic-error-muted text-semantic-error',
  warning: 'bg-semantic-warning-muted text-semantic-warning',
  info: 'bg-semantic-info-muted text-semantic-info',
  accent: 'bg-accent-muted text-onAccent',
  default: 'bg-surface text-text-secondary',
};

function Badge({ variant = 'default', children, className }: BadgeProps) {
  return (
    <span
      className={cn(
        'inline-flex items-center px-sm py-[2px] rounded-xs text-[11px] font-semibold leading-[1.4] whitespace-nowrap',
        variantStyles[variant],
        className
      )}
    >
      {children}
    </span>
  );
}

export { Badge };
export type { BadgeProps, BadgeVariant };
