export interface ApiResponse<T> {
  data: T | null;
  error: string | null;
}

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  pageSize: number;
}

export interface ShareRequest {
  fundId: string;
  channel: 'kakao' | 'link_copy' | 'instagram';
}
