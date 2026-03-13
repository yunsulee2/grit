'use client';

import {
  createContext,
  useContext,
  useEffect,
  useState,
  useCallback,
  useMemo,
  type ReactNode,
} from 'react';
import { createClient } from '@/lib/supabase/client';
import { isKakaoInAppBrowser } from '@/lib/kakao-inapp';
import type { UserProfile } from '@/types/user';
import type { User } from '@supabase/supabase-js';

interface UserContextValue {
  user: UserProfile | null;
  isLoading: boolean;
  signInWithKakao: () => void;
  signOut: () => void;
}

const UserContext = createContext<UserContextValue | null>(null);

function mapAuthUserToProfile(authUser: User): UserProfile {
  return {
    id: authUser.id,
    kakaoId: authUser.user_metadata?.provider_id ?? '',
    name:
      authUser.user_metadata?.full_name ??
      authUser.user_metadata?.name ??
      '사용자',
    phone: authUser.user_metadata?.phone ?? null,
    address: null,
    addressDetail: null,
    zipcode: null,
  };
}

export function UserProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<UserProfile | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const supabase = useMemo(() => createClient(), []);

  useEffect(() => {
    // Get initial session
    supabase.auth.getUser().then(({ data: { user: authUser } }) => {
      setUser(authUser ? mapAuthUserToProfile(authUser) : null);
      setIsLoading(false);
    });

    // Listen for auth state changes
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user ? mapAuthUserToProfile(session.user) : null);
      setIsLoading(false);
    });

    return () => {
      subscription.unsubscribe();
    };
  }, [supabase]);

  const signInWithKakao = useCallback(async () => {
    const _isKakao = isKakaoInAppBrowser();
    const redirectTo =
      window.location.origin +
      '/api/auth/callback?next=' +
      encodeURIComponent(window.location.pathname);

    const { error } = await supabase.auth.signInWithOAuth({
      provider: 'kakao',
      options: {
        redirectTo,
        queryParams: { prompt: 'login' },
      },
    });

    if (error) {
      console.error('Kakao login error:', error);
    }
  }, [supabase]);

  const signOut = useCallback(async () => {
    await supabase.auth.signOut();
    setUser(null);
  }, [supabase]);

  return (
    <UserContext.Provider value={{ user, isLoading, signInWithKakao, signOut }}>
      {children}
    </UserContext.Provider>
  );
}

export function useUser() {
  const context = useContext(UserContext);
  if (!context) {
    throw new Error('useUser must be used within a UserProvider');
  }
  return context;
}
