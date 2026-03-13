'use client';

import { useState, useCallback, useMemo } from 'react';
import { CategoryTabs } from './CategoryTabs';
import { FilterChips, SORT_FILTERS } from './FilterChips';
import { FundGrid } from './FundGrid';
import type { FundCardData } from '@/types/fund';
import { trackEvent } from '@/lib/analytics';

interface HomeClientProps {
  initialFunds: FundCardData[];
}

function HomeClient({ initialFunds }: HomeClientProps) {
  const [activeCategory, setActiveCategory] = useState<string>('전체');
  const [activeFilters, setActiveFilters] = useState<Set<string>>(new Set());

  const handleCategoryChange = useCallback((category: string) => {
    trackEvent('filter_change', { type: 'category', value: category });
    setActiveCategory(category);
  }, []);

  const handleFilterToggle = useCallback((filter: string) => {
    trackEvent('filter_change', { type: 'sort', value: filter });
    setActiveFilters((prev) => {
      const next = new Set(prev);
      if (next.has(filter)) {
        next.delete(filter);
      } else {
        // Sort filters are mutually exclusive
        if (SORT_FILTERS.has(filter)) {
          SORT_FILTERS.forEach((sf) => next.delete(sf));
        }
        next.add(filter);
      }
      return next;
    });
  }, []);

  const filteredFunds = useMemo(() => {
    let result = [...initialFunds];

    // 1. Category filter
    if (activeCategory !== '전체') {
      result = result.filter((f) => f.category === activeCategory);
    }

    // 2. 마감임박 — endAt within 24h
    if (activeFilters.has('마감임박')) {
      const now = Date.now();
      const threshold = 24 * 60 * 60 * 1000;
      result = result.filter((f) => {
        const diff = new Date(f.endAt).getTime() - now;
        return diff > 0 && diff < threshold;
      });
    }

    // 3. 무료배송 toggle
    if (activeFilters.has('무료배송')) {
      result = result.filter((f) => f.freeShipping);
    }

    // 4. Sort (mutually exclusive)
    if (activeFilters.has('인기순')) {
      result.sort((a, b) => b.currentParticipants - a.currentParticipants);
    } else if (activeFilters.has('최저가순')) {
      result.sort((a, b) => a.targetPrice - b.targetPrice);
    } else if (activeFilters.has('최신순')) {
      result.sort((a, b) => new Date(b.endAt).getTime() - new Date(a.endAt).getTime());
    }

    return result;
  }, [initialFunds, activeCategory, activeFilters]);

  return (
    <>
      <CategoryTabs
        activeCategory={activeCategory}
        onCategoryChange={handleCategoryChange}
      />
      <div className="max-w-content mx-auto">
        <FilterChips activeFilters={activeFilters} onFilterToggle={handleFilterToggle} />
        <div className="px-lg mobile:px-xl tablet:px-2xl pb-4xl">
          <FundGrid funds={filteredFunds} />
        </div>
      </div>
    </>
  );
}

export { HomeClient };
