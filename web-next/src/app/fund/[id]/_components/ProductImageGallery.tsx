'use client';

import { useState, useCallback, useRef, type TouchEvent } from 'react';
import NextImage from 'next/image';
import { cn } from '@/lib/utils';
import { MAX_IMAGES } from '@/lib/constants';
import { Skeleton } from '@/components/ui/Skeleton';

interface ProductImageGalleryProps {
  images: string[];
  productName: string;
  className?: string;
}

function ProductImageGallery({ images, productName, className }: ProductImageGalleryProps) {
  const displayImages = images.slice(0, MAX_IMAGES);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [loadedImages, setLoadedImages] = useState<Set<number>>(new Set());
  const [errorImages, setErrorImages] = useState<Set<number>>(new Set());
  const touchStartX = useRef(0);
  const touchEndX = useRef(0);

  const goTo = useCallback(
    (index: number) => {
      if (index < 0) setCurrentIndex(displayImages.length - 1);
      else if (index >= displayImages.length) setCurrentIndex(0);
      else setCurrentIndex(index);
    },
    [displayImages.length]
  );

  const handleTouchStart = (e: TouchEvent) => {
    touchStartX.current = e.touches[0].clientX;
  };

  const handleTouchMove = (e: TouchEvent) => {
    touchEndX.current = e.touches[0].clientX;
  };

  const handleTouchEnd = () => {
    const diff = touchStartX.current - touchEndX.current;
    const threshold = 50;
    if (diff > threshold) {
      goTo(currentIndex + 1);
    } else if (diff < -threshold) {
      goTo(currentIndex - 1);
    }
  };

  const handleLoad = useCallback((index: number) => {
    setLoadedImages((prev) => new Set(prev).add(index));
  }, []);

  const handleError = useCallback((index: number) => {
    setErrorImages((prev) => new Set(prev).add(index));
  }, []);

  const CameraPlaceholder = () => (
    <svg
      width="48"
      height="48"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.5"
      className="text-text-tertiary"
    >
      <rect x="3" y="3" width="18" height="18" rx="2" ry="2" />
      <circle cx="8.5" cy="8.5" r="1.5" />
      <polyline points="21 15 16 10 5 21" />
    </svg>
  );

  if (displayImages.length === 0) {
    return (
      <div
        className={cn('relative w-full aspect-square bg-surface flex items-center justify-center', className)}
      >
        <CameraPlaceholder />
      </div>
    );
  }

  return (
    <div className={cn('relative w-full', className)}>
      {/* Image viewport */}
      <div
        className="relative w-full aspect-square overflow-hidden bg-surface"
        onTouchStart={handleTouchStart}
        onTouchMove={handleTouchMove}
        onTouchEnd={handleTouchEnd}
      >
        <div
          className="flex h-full transition-transform duration-300 ease-out"
          style={{ transform: `translateX(-${currentIndex * 100}%)` }}
        >
          {displayImages.map((src, i) => (
            <div key={i} className="relative w-full h-full shrink-0">
              {/* Loading skeleton shown until image loads */}
              {!loadedImages.has(i) && !errorImages.has(i) && (
                <Skeleton variant="image" className="absolute inset-0 aspect-auto h-full rounded-none" />
              )}
              {/* Error fallback */}
              {errorImages.has(i) ? (
                <div className="absolute inset-0 flex items-center justify-center bg-surface">
                  <CameraPlaceholder />
                </div>
              ) : (
                <NextImage
                  src={src}
                  alt={`${productName} ${i + 1}`}
                  fill
                  className="object-cover"
                  sizes="(max-width: 960px) 100vw, 480px"
                  priority={i === 0}
                  onLoad={() => handleLoad(i)}
                  onError={() => handleError(i)}
                />
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Dot indicators */}
      {displayImages.length > 1 && (
        <div className="absolute bottom-md left-1/2 -translate-x-1/2 flex items-center gap-[6px]">
          {displayImages.map((_, i) => (
            <button
              key={i}
              type="button"
              onClick={() => goTo(i)}
              className={cn(
                'w-[6px] h-[6px] rounded-full transition-all duration-200',
                i === currentIndex
                  ? 'bg-white w-[16px]'
                  : 'bg-white/50'
              )}
              aria-label={`이미지 ${i + 1}`}
            />
          ))}
        </div>
      )}
    </div>
  );
}

export { ProductImageGallery };
export type { ProductImageGalleryProps };
