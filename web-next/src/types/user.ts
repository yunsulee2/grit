export interface UserProfile {
  id: string;
  kakaoId: string;
  name: string;
  phone: string | null;
  address: string | null;
  addressDetail: string | null;
  zipcode: string | null;
}

export interface UpdateProfileRequest {
  name?: string;
  phone?: string;
  address?: string;
  addressDetail?: string;
  zipcode?: string;
}
