import { Skeleton } from '@/components/ui/Skeleton';

function FundCardSkeleton() {
  return (
    <div className="bg-surface-elevated rounded-md overflow-hidden shadow-card">
      {/* Image */}
      <Skeleton variant="image" />
      {/* Text area */}
      <div className="px-md pt-sm pb-md flex flex-col gap-sm">
        <Skeleton variant="line" className="w-1/3 h-[12px]" />
        <Skeleton variant="line" className="w-full" />
        <Skeleton variant="line" className="w-4/5" />
        <Skeleton variant="line" className="w-1/2 h-[18px] mt-xs" />
        <Skeleton variant="line" className="w-2/3 h-[14px]" />
      </div>
    </div>
  );
}

export default function HomeLoading() {
  return (
    <div className="min-h-screen flex flex-col bg-bg">
      {/* Header skeleton */}
      <div className="sticky top-0 z-40 bg-bg border-b border-border-subtle">
        <div className="max-w-content mx-auto h-[56px] flex items-center justify-between px-lg mobile:px-xl tablet:px-2xl">
          <Skeleton variant="line" className="w-[60px] h-[22px]" />
          <Skeleton variant="line" className="w-[64px] h-[36px] rounded-sm" />
        </div>
      </div>

      <main className="flex-1">
        {/* Hero skeleton */}
        <div className="w-full bg-primary">
          <div className="max-w-content mx-auto">
            <div className="flex flex-col tablet:flex-row">
              <div className="w-full tablet:w-[480px] aspect-[4/3] tablet:aspect-auto bg-white/10 animate-pulse" />
              <div className="flex-1 px-lg tablet:px-3xl py-2xl tablet:py-4xl flex flex-col gap-lg">
                <Skeleton variant="line" className="w-[100px] h-[24px] bg-white/20" />
                <div className="flex flex-col gap-sm">
                  <Skeleton variant="line" className="bg-white/20" />
                  <Skeleton variant="line" className="w-4/5 bg-white/20" />
                  <Skeleton variant="line" className="w-3/5 bg-white/20" />
                </div>
                <Skeleton variant="line" className="w-[180px] h-[52px] rounded-md bg-white/20" />
              </div>
            </div>
          </div>
        </div>

        {/* Section title skeleton */}
        <div className="max-w-content mx-auto px-lg mobile:px-xl tablet:px-2xl pt-3xl pb-sm">
          <Skeleton variant="line" className="w-[140px] h-[20px]" />
        </div>

        {/* Category tabs skeleton */}
        <div className="sticky top-[56px] z-30 bg-bg border-b border-border-subtle">
          <div className="max-w-content mx-auto px-lg mobile:px-xl tablet:px-2xl">
            <div className="flex items-center gap-sm py-md overflow-hidden">
              {[60, 70, 80, 90, 100, 110].map((w, i) => (
                <Skeleton
                  key={i}
                  variant="line"
                  className="flex-shrink-0 h-[34px] rounded-full"
                  width={`${w}px`}
                />
              ))}
            </div>
          </div>
        </div>

        {/* Filter chips skeleton */}
        <div className="max-w-content mx-auto px-lg mobile:px-xl tablet:px-2xl pt-md pb-sm">
          <div className="flex items-center gap-sm overflow-hidden">
            {[56, 64, 72, 80, 88].map((w, i) => (
              <Skeleton
                key={i}
                variant="line"
                className="flex-shrink-0 h-[32px] rounded-full"
                width={`${w}px`}
              />
            ))}
          </div>
        </div>

        {/* Fund grid skeleton */}
        <div className="max-w-content mx-auto px-lg mobile:px-xl tablet:px-2xl pb-4xl">
          <div className="grid grid-cols-2 tablet:grid-cols-3 gap-md">
            {Array.from({ length: 6 }).map((_, i) => (
              <FundCardSkeleton key={i} />
            ))}
          </div>
        </div>
      </main>
    </div>
  );
}
