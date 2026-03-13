import { Header } from '@/components/layout/Header';

export default function FundDetailLoading() {
  return (
    <div className="min-h-screen flex flex-col bg-bg">
      <Header />
      <main className="flex-1 max-w-content mx-auto w-full animate-pulse">
        {/* Image skeleton */}
        <div className="w-full aspect-square bg-surface" />

        {/* Price section skeleton */}
        <div className="px-lg py-xl space-y-md">
          <div className="h-[14px] w-[60px] bg-border-subtle rounded" />
          <div className="h-[20px] w-[200px] bg-border-subtle rounded" />
          <div className="flex items-center gap-sm">
            <div className="h-[28px] w-[40px] bg-border-subtle rounded-xs" />
            <div className="h-[28px] w-[120px] bg-border-subtle rounded" />
            <div className="h-[16px] w-[80px] bg-border-subtle rounded" />
          </div>
        </div>

        <div className="h-[8px] bg-surface" />

        {/* Progress section skeleton */}
        <div className="px-lg py-xl space-y-lg">
          <div className="h-[36px] w-full bg-border-subtle rounded" />
          <div className="h-[12px] w-full bg-border-subtle rounded-full" />
          <div className="flex justify-between">
            <div className="h-[32px] w-[70px] bg-border-subtle rounded" />
            <div className="h-[32px] w-[70px] bg-border-subtle rounded" />
            <div className="h-[32px] w-[70px] bg-border-subtle rounded" />
          </div>
          <div className="h-[18px] w-[180px] bg-border-subtle rounded mx-auto" />
        </div>

        <div className="h-[8px] bg-surface" />

        {/* Real-time info skeleton */}
        <div className="px-lg py-lg flex items-center justify-between">
          <div className="h-[28px] w-[120px] bg-border-subtle rounded-xs" />
          <div className="h-[20px] w-[100px] bg-border-subtle rounded" />
        </div>

        <div className="h-[8px] bg-surface" />

        {/* Share buttons skeleton */}
        <div className="py-xl flex justify-center gap-3xl">
          {[1, 2, 3].map((i) => (
            <div key={i} className="flex flex-col items-center gap-[6px]">
              <div className="w-[48px] h-[48px] rounded-full bg-border-subtle" />
              <div className="h-[14px] w-[50px] bg-border-subtle rounded" />
            </div>
          ))}
        </div>

        <div className="h-[8px] bg-surface" />

        {/* Product details skeleton */}
        <div className="space-y-0">
          {[1, 2, 3, 4].map((i) => (
            <div key={i} className="px-lg py-lg border-b border-border-subtle flex items-center justify-between">
              <div className="h-[18px] w-[80px] bg-border-subtle rounded" />
              <div className="h-[18px] w-[18px] bg-border-subtle rounded" />
            </div>
          ))}
        </div>

        {/* Price tier table skeleton */}
        <div className="px-lg py-xl space-y-md">
          <div className="h-[18px] w-[80px] bg-border-subtle rounded" />
          <div className="border border-border-subtle rounded-md overflow-hidden">
            {[1, 2, 3].map((i) => (
              <div key={i} className="h-[44px] border-b border-border-subtle last:border-0 flex items-center px-md gap-lg">
                <div className="h-[14px] w-[80px] bg-border-subtle rounded" />
                <div className="h-[14px] w-[60px] bg-border-subtle rounded ml-auto" />
                <div className="h-[14px] w-[50px] bg-border-subtle rounded" />
              </div>
            ))}
          </div>
        </div>
      </main>

      {/* Sticky CTA skeleton */}
      <div className="fixed bottom-0 left-0 right-0 z-50 bg-surface-elevated border-t border-border-subtle">
        <div className="h-[72px] flex items-center px-lg max-w-content mx-auto">
          <div className="w-[48px] h-[48px] bg-border-subtle rounded-sm" />
          <div className="w-md" />
          <div className="flex-1 h-[48px] bg-border-subtle rounded-sm" />
        </div>
      </div>
    </div>
  );
}
