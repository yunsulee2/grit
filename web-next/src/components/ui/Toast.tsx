'use client';

import { createContext, useContext, useState, useCallback, useRef, type ReactNode } from 'react';
import { cn } from '@/lib/utils';

type ToastVariant = 'success' | 'error' | 'info';

interface Toast {
  id: number;
  variant: ToastVariant;
  message: string;
}

interface ToastContextValue {
  toast: (options: { variant: ToastVariant; message: string; duration?: number }) => void;
}

const ToastContext = createContext<ToastContextValue | null>(null);

export function useToast() {
  const ctx = useContext(ToastContext);
  if (!ctx) throw new Error('useToast must be used within ToastProvider');
  return ctx;
}

const variantStyles: Record<ToastVariant, string> = {
  success: 'bg-semantic-success text-white',
  error: 'bg-semantic-error text-white',
  info: 'bg-primary text-text-inverse',
};

const variantIcons: Record<ToastVariant, string> = {
  success: '\u2713',
  error: '!',
  info: 'i',
};

export function ToastProvider({ children }: { children: ReactNode }) {
  const [toasts, setToasts] = useState<Toast[]>([]);
  const nextId = useRef(0);

  const addToast = useCallback(({ variant, message, duration = 3000 }: { variant: ToastVariant; message: string; duration?: number }) => {
    const id = nextId.current++;
    setToasts((prev) => [...prev, { id, variant, message }]);
    setTimeout(() => {
      setToasts((prev) => prev.filter((t) => t.id !== id));
    }, duration);
  }, []);

  const removeToast = useCallback((id: number) => {
    setToasts((prev) => prev.filter((t) => t.id !== id));
  }, []);

  return (
    <ToastContext.Provider value={{ toast: addToast }}>
      {children}
      {/* Toast container */}
      <div className="fixed top-[72px] left-1/2 -translate-x-1/2 z-[100] flex flex-col items-center gap-sm pointer-events-none" aria-live="polite">
        {toasts.map((t) => (
          <div
            key={t.id}
            className={cn(
              'pointer-events-auto flex items-center gap-sm px-lg py-md rounded-sm shadow-elevated text-[14px] font-medium animate-fade-in min-w-[200px] max-w-[360px]',
              variantStyles[t.variant]
            )}
            role="alert"
          >
            <span className="w-[20px] h-[20px] rounded-full bg-white/20 flex items-center justify-center text-[12px] font-bold shrink-0">
              {variantIcons[t.variant]}
            </span>
            <span className="flex-1">{t.message}</span>
            <button
              type="button"
              onClick={() => removeToast(t.id)}
              className="ml-sm text-white/70 hover:text-white shrink-0 text-[16px] leading-none"
              aria-label="닫기"
            >
              &times;
            </button>
          </div>
        ))}
      </div>
    </ToastContext.Provider>
  );
}
