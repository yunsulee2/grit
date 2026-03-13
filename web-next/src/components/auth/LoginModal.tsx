'use client';

import { useEffect, useRef } from 'react';
import { useUser } from './UserContext';

interface LoginModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export default function LoginModal({ isOpen, onClose }: LoginModalProps) {
  const { signInWithKakao } = useUser();
  const dialogRef = useRef<HTMLDivElement>(null);

  // Close on Escape key
  useEffect(() => {
    if (!isOpen) return;

    function handleKeyDown(e: KeyboardEvent) {
      if (e.key === 'Escape') onClose();
    }

    document.addEventListener('keydown', handleKeyDown);
    return () => document.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, onClose]);

  // Prevent body scroll when modal is open
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = '';
    }
    return () => {
      document.body.style.overflow = '';
    };
  }, [isOpen]);

  if (!isOpen) return null;

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/50"
      onClick={(e) => {
        // Close when clicking backdrop
        if (e.target === e.currentTarget) onClose();
      }}
      role="dialog"
      aria-modal="true"
      aria-label="로그인"
    >
      <div
        ref={dialogRef}
        className="relative mx-lg w-full max-w-login bg-surface-elevated rounded-lg p-2xl shadow-elevated"
      >
        {/* Close button */}
        <button
          onClick={onClose}
          className="absolute top-lg right-lg text-text-tertiary hover:text-text-primary transition-colors"
          aria-label="닫기"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="24"
            height="24"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
          >
            <line x1="18" y1="6" x2="6" y2="18" />
            <line x1="6" y1="6" x2="18" y2="18" />
          </svg>
        </button>

        {/* Logo */}
        <div className="flex justify-center pt-lg pb-2xl">
          <span className="text-2xl font-bold tracking-tight text-text-primary">
            GRIT
          </span>
        </div>

        {/* Message */}
        <p className="text-center text-text-primary font-medium leading-relaxed mb-3xl whitespace-pre-line">
          {'공동구매에 참여하려면\n로그인이 필요해요'}
        </p>

        {/* Kakao login button */}
        <button
          onClick={signInWithKakao}
          className="flex w-full items-center justify-center gap-sm rounded-md bg-[#FEE500] px-xl py-md text-[#3A1D1D] font-semibold transition-opacity hover:opacity-90 active:opacity-80"
        >
          {/* Kakao icon */}
          <svg
            width="20"
            height="20"
            viewBox="0 0 20 20"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              fillRule="evenodd"
              clipRule="evenodd"
              d="M10 2.5C5.306 2.5 1.5 5.473 1.5 9.122c0 2.347 1.553 4.41 3.892 5.584-.127.467-.818 3.007-.846 3.2 0 0-.017.143.076.197.093.055.202.025.202.025.266-.037 3.085-2.012 3.57-2.35.504.074 1.023.113 1.556.113 4.694 0 8.5-2.973 8.5-6.622S14.694 2.5 10 2.5Z"
              fill="#3A1D1D"
            />
          </svg>
          카카오로 시작하기
        </button>
      </div>
    </div>
  );
}
