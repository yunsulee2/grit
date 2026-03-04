import { createClient } from '@/lib/supabase/server';
import { NextResponse } from 'next/server';

function getSafeRedirect(next: string | null): string {
  if (!next || !next.startsWith('/') || next.startsWith('//')) {
    return '/';
  }
  return next;
}

export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url);
  const code = searchParams.get('code');
  const next = getSafeRedirect(searchParams.get('next'));

  if (code) {
    const supabase = await createClient();
    const { error } = await supabase.auth.exchangeCodeForSession(code);

    if (!error) {
      // Redirect to the page the user was on before login
      return NextResponse.redirect(`${origin}${next}`);
    }
  }

  // OAuth error — redirect to home with error indicator
  return NextResponse.redirect(`${origin}/?auth_error=1`);
}
