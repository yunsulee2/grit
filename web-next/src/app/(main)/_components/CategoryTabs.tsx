'use client';

import { cn } from '@/lib/utils';
import { CATEGORIES } from '@/lib/constants';
import { useRef, useState, useEffect } from 'react';

interface CategoryTabsProps {
  activeCategory: string;
  onCategoryChange: (category: string) => void;
}

function CategoryTabs({ activeCategory, onCategoryChange }: CategoryTabsProps) {
  const scrollRef = useRef<HTMLDivElement>(null);
  const [showLeftFade, setShowLeftFade] = useState(false);
  const [showRightFade, setShowRightFade] = useState(true);

  const checkScroll = () => {
    const el = scrollRef.current;
    if (!el) return;
    setShowLeftFade(el.scrollLeft >= 10);
    setShowRightFade(el.scrollLeft + el.clientWidth < el.scrollWidth - 10);
  };

  useEffect(() => {
    checkScroll();
  }, []);

  return (
    <div className="sticky top-[56px] z-30 bg-bg border-b border-border-subtle">
      <div className="max-w-content mx-auto px-lg mobile:px-xl tablet:px-2xl">
        <div className="relative">
          {/* Left fade */}
          {showLeftFade && (
            <div className="absolute top-0 bottom-0 left-0 w-[32px] pointer-events-none z-10 bg-gradient-to-r from-bg to-transparent" />
          )}
          {/* Right fade */}
          {showRightFade && (
            <div className="absolute top-0 bottom-0 right-0 w-[32px] pointer-events-none z-10 bg-gradient-to-l from-bg to-transparent" />
          )}
          <div
            ref={scrollRef}
            role="tablist"
            className="flex items-center gap-sm overflow-x-auto py-md scrollbar-none"
            style={{ scrollbarWidth: 'none', msOverflowStyle: 'none' }}
            onScroll={checkScroll}
          >
            {CATEGORIES.map((category) => {
              const isActive = activeCategory === category;
              return (
                <button
                  key={category}
                  role="tab"
                  aria-selected={category === activeCategory}
                  onClick={() => onCategoryChange(category)}
                  className={cn(
                    'flex-shrink-0 h-[34px] px-md rounded-full text-[13px] font-semibold transition-colors',
                    isActive
                      ? 'bg-primary text-text-inverse'
                      : 'bg-surface text-text-secondary hover:bg-border-subtle hover:text-text-primary'
                  )}
                >
                  {category}
                </button>
              );
            })}
          </div>
        </div>
      </div>
    </div>
  );
}

export { CategoryTabs };
