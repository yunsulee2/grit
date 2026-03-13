import { cn } from '@/lib/utils';

type SkeletonVariant = 'line' | 'circle' | 'card' | 'image';

interface SkeletonProps {
  variant?: SkeletonVariant;
  className?: string;
  width?: string;
  height?: string;
}

const baseClass = 'animate-pulse bg-surface';

const variantStyles: Record<SkeletonVariant, string> = {
  line: 'h-[14px] w-full rounded-xs',
  circle: 'w-[48px] h-[48px] rounded-full',
  card: 'w-full h-[200px] rounded-md',
  image: 'w-full aspect-[85/100] rounded-md',
};

function Skeleton({ variant = 'line', className, width, height }: SkeletonProps) {
  return (
    <div
      className={cn(baseClass, variantStyles[variant], className)}
      style={{
        ...(width ? { width } : {}),
        ...(height ? { height } : {}),
      }}
      aria-hidden="true"
    />
  );
}

export { Skeleton };
export type { SkeletonProps, SkeletonVariant };
