import { updateSession } from '@/lib/supabase/middleware';
import { type NextRequest, NextResponse } from 'next/server';

export async function middleware(request: NextRequest) {
  const response = await updateSession(request);

  const isKakaoUA = request.headers.get('user-agent')?.includes('KAKAOTALK') ?? false;
  if (isKakaoUA) {
    response.cookies.set('x-kakao-inapp', '1', {
      path: '/',
      sameSite: 'lax',
      httpOnly: false, // readable by client JS if needed
    });
  }

  return response;
}

export const config = {
  matcher: [
    /*
     * Match all routes except:
     * - _next/static (static files)
     * - _next/image (image optimization)
     * - favicon.ico (browser icon)
     * - public assets (svg, png, jpg, etc.)
     */
    '/((?!_next/static|_next/image|favicon\\.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
};
