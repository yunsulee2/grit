'use client';

import { useToast } from '@/components/ui/Toast';
import type { UserProfile } from '@/types/user';

interface ProfileSectionProps {
  user: UserProfile;
}

function ProfileSection({ user }: ProfileSectionProps) {
  const { toast } = useToast();
  const initials = user.name.slice(0, 2);

  function handleEditProfile() {
    toast({ variant: 'info', message: '준비 중입니다' });
  }

  return (
    <div className="bg-surface-tinted border-b border-border-subtle px-lg py-xl">
      <div className="flex items-center gap-lg">
        {/* Avatar */}
        <div className="w-[48px] h-[48px] rounded-full bg-primary flex items-center justify-center flex-shrink-0 overflow-hidden">
          <span className="text-[18px] font-bold text-text-inverse select-none">
            {initials}
          </span>
        </div>

        {/* Name */}
        <div className="flex-1 min-w-0">
          <p className="text-[16px] font-semibold text-text-primary leading-tight truncate">
            {user.name}
          </p>
          {user.phone && (
            <p className="text-[13px] text-text-secondary mt-[2px]">{user.phone}</p>
          )}
        </div>

        {/* Edit button (프로필 수정 page not yet implemented) */}
        <button
          type="button"
          onClick={handleEditProfile}
          className="flex-shrink-0 text-[13px] font-medium text-text-secondary border border-border rounded-xs px-sm py-[6px] hover:bg-surface transition-colors"
        >
          프로필 수정
        </button>
      </div>
    </div>
  );
}

export { ProfileSection };
