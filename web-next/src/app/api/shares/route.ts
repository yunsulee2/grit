import { createClient } from '@/lib/supabase/server';
import { NextResponse } from 'next/server';
import type { ShareRequest } from '@/types/api';
import type { ShareChannel } from '@/types/database';

const VALID_CHANNELS: ShareChannel[] = ['kakao', 'link_copy', 'instagram'];

export async function POST(request: Request) {
  let body: ShareRequest;
  try {
    body = await request.json();
  } catch {
    return NextResponse.json({ error: 'Invalid JSON body' }, { status: 400 });
  }

  // Validate required fields
  if (!body.fundId) {
    return NextResponse.json({ error: 'fundId is required' }, { status: 400 });
  }

  if (!body.channel || !VALID_CHANNELS.includes(body.channel)) {
    return NextResponse.json(
      { error: `channel must be one of: ${VALID_CHANNELS.join(', ')}` },
      { status: 400 }
    );
  }

  const isConfigured =
    process.env.NEXT_PUBLIC_SUPABASE_URL &&
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

  if (!isConfigured) {
    return NextResponse.json({
      data: { id: 'mock-share-id' },
      error: null,
    });
  }

  const supabase = await createClient();

  // Auth is optional — get user if logged in, null otherwise
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { data, error } = await supabase
    .from('shares')
    .insert({
      fund_id: body.fundId,
      channel: body.channel,
      user_id: user?.id ?? null,
    })
    .select('id')
    .single();

  if (error || !data) {
    return NextResponse.json(
      { error: error?.message ?? 'Failed to record share' },
      { status: 500 }
    );
  }

  return NextResponse.json({ data: { id: data.id }, error: null });
}
