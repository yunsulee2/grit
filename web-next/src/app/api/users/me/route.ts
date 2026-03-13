import { createClient } from '@/lib/supabase/server';
import { NextResponse } from 'next/server';
import type { UserProfile, UpdateProfileRequest } from '@/types/user';
import type { UserRow } from '@/types/database';

const MOCK_USER: UserProfile = {
  id: 'mock-user-id',
  kakaoId: 'mock-kakao-id',
  name: '테스트 유저',
  phone: null,
  address: null,
  addressDetail: null,
  zipcode: null,
};

function rowToProfile(row: UserRow): UserProfile {
  return {
    id: row.id,
    kakaoId: row.kakao_id,
    name: row.name,
    phone: row.phone,
    address: row.address,
    addressDetail: row.address_detail,
    zipcode: row.zipcode,
  };
}

export async function GET() {
  const isConfigured =
    process.env.NEXT_PUBLIC_SUPABASE_URL &&
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

  if (!isConfigured) {
    return NextResponse.json({ data: MOCK_USER, error: null });
  }

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const { data, error } = await supabase
    .from('users')
    .select('*')
    .eq('id', user.id)
    .single<UserRow>();

  if (error || !data) {
    return NextResponse.json(
      { error: error?.message ?? 'User not found' },
      { status: 404 }
    );
  }

  return NextResponse.json({ data: rowToProfile(data), error: null });
}

export async function PUT(request: Request) {
  const isConfigured =
    process.env.NEXT_PUBLIC_SUPABASE_URL &&
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

  if (!isConfigured) {
    const body: UpdateProfileRequest = await request.json();
    return NextResponse.json({
      data: { ...MOCK_USER, ...body },
      error: null,
    });
  }

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  let body: UpdateProfileRequest;
  try {
    body = await request.json();
  } catch {
    return NextResponse.json({ error: 'Invalid JSON body' }, { status: 400 });
  }

  // Validate — at least one field required
  const allowedFields = ['name', 'phone', 'address', 'addressDetail', 'zipcode'] as const;
  const hasField = allowedFields.some((f) => f in body);
  if (!hasField) {
    return NextResponse.json(
      { error: 'At least one field required' },
      { status: 400 }
    );
  }

  // Validate name if provided
  if (body.name !== undefined && body.name.trim().length === 0) {
    return NextResponse.json({ error: 'Name cannot be empty' }, { status: 400 });
  }

  // Map camelCase → snake_case for DB
  const updates: Partial<UserRow> = {};
  if (body.name !== undefined) updates.name = body.name.trim();
  if (body.phone !== undefined) updates.phone = body.phone;
  if (body.address !== undefined) updates.address = body.address;
  if (body.addressDetail !== undefined) updates.address_detail = body.addressDetail;
  if (body.zipcode !== undefined) updates.zipcode = body.zipcode;

  const { data, error } = await supabase
    .from('users')
    .update(updates)
    .eq('id', user.id)
    .select('*')
    .single<UserRow>();

  if (error || !data) {
    return NextResponse.json(
      { error: error?.message ?? 'Update failed' },
      { status: 500 }
    );
  }

  return NextResponse.json({ data: rowToProfile(data), error: null });
}
