'use client';

import type { ReactNode } from 'react';
import { useUser } from './UserContext';

interface AuthGuardProps {
  children: ReactNode;
  onUnauthenticated: () => void;
}

/**
 * Wrapper that checks auth before rendering children.
 * If the user is not logged in, calls `onUnauthenticated` (typically opens LoginModal).
 * If logged in, renders children normally.
 *
 * Usage:
 * ```tsx
 * <AuthGuard onUnauthenticated={() => setShowLogin(true)}>
 *   <button onClick={handleParticipate}>참여하기</button>
 * </AuthGuard>
 * ```
 */
export default function AuthGuard({
  children,
  onUnauthenticated,
}: AuthGuardProps) {
  const { user, isLoading } = useUser();

  if (isLoading) {
    return <>{children}</>;
  }

  if (!user) {
    return (
      <div
        onClick={(e) => {
          e.preventDefault();
          e.stopPropagation();
          onUnauthenticated();
        }}
        onKeyDown={(e) => {
          if (e.key === 'Enter' || e.key === ' ') {
            e.preventDefault();
            e.stopPropagation();
            onUnauthenticated();
          }
        }}
        role="button"
        tabIndex={0}
        className="contents"
      >
        {children}
      </div>
    );
  }

  return <>{children}</>;
}
