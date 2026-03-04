'use client';

import { cn } from '@/lib/utils';
import { FILTERS } from '@/lib/constants';

const SORT_FILTERS = new Set(['인기순', '최저가순', '최신순']);

interface FilterChipsProps {
  activeFilters: Set<string>;
  onFilterToggle: (filter: string) => void;
}

function FilterChips({ activeFilters, onFilterToggle }: FilterChipsProps) {
  return (
    <div className="max-w-content mx-auto px-lg mobile:px-xl tablet:px-2xl pt-md pb-sm">
      <div
        role="group"
        aria-label="정렬"
        className="flex items-center gap-sm overflow-x-auto scrollbar-none"
        style={{ scrollbarWidth: 'none', msOverflowStyle: 'none' }}
      >
        {FILTERS.map((filter) => {
          const isActive = activeFilters.has(filter);
          return (
            <button
              key={filter}
              aria-pressed={activeFilters.has(filter)}
              onClick={() => onFilterToggle(filter)}
              className={cn(
                'flex-shrink-0 h-[32px] px-md rounded-full text-[12px] font-semibold border transition-all duration-200',
                'active:scale-[0.97]',
                isActive
                  ? 'border-primary text-primary bg-surface'
                  : 'border-border text-text-secondary bg-bg hover:border-primary hover:text-primary'
              )}
            >
              {filter}
            </button>
          );
        })}
      </div>
    </div>
  );
}

export { FilterChips };
export { SORT_FILTERS };
