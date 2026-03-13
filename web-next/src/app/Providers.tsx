'use client';

import { ToastProvider } from '@/components/ui/Toast';
import { UserProvider } from '@/components/auth/UserContext';
import { ScrollToTop } from '@/components/ui/ScrollToTop';

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <UserProvider>
      <ToastProvider>
        {children}
        <ScrollToTop />
      </ToastProvider>
    </UserProvider>
  );
}
