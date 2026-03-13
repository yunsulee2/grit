import Link from 'next/link';
import { cn } from '@/lib/utils';

interface FooterProps {
  className?: string;
}

const footerLinks = [
  { href: '/about', label: '소개' },
  { href: '/guide', label: '이용안내' },
  { href: '/terms', label: '이용약관' },
  { href: '/privacy', label: '개인정보처리방침' },
] as const;

function Footer({ className }: FooterProps) {
  return (
    <footer
      className={cn(
        'bg-surface border-t border-border-subtle',
        className
      )}
    >
      <div className="max-w-content mx-auto px-lg mobile:px-xl tablet:px-2xl py-3xl">
        {/* Links */}
        <nav className="flex flex-wrap gap-lg mb-lg">
          {footerLinks.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              className="text-[13px] text-text-secondary hover:text-text-primary transition-colors"
            >
              {link.label}
            </Link>
          ))}
        </nav>

        {/* Copyright */}
        <p className="text-[12px] text-text-tertiary">
          &copy; {new Date().getFullYear()} GRIT. All rights reserved.
        </p>
      </div>
    </footer>
  );
}

export { Footer };
export type { FooterProps };
