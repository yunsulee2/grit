import { Header } from '@/components/layout/Header';
import { Footer } from '@/components/layout/Footer';

export default function AboutPage() {
  return (
    <div className="min-h-screen flex flex-col bg-bg">
      <Header />

      <main className="flex-1">
        <div className="max-w-content mx-auto px-lg mobile:px-xl tablet:px-2xl py-4xl">
          {/* Hero */}
          <section className="mb-4xl">
            <h1 className="text-[32px] font-black text-text-primary mb-md">
              GRIT 소개
            </h1>
            <p className="text-[18px] text-text-secondary leading-relaxed">
              공동구매로 더 좋은 가격에, 함께 모여 더 큰 할인을.
            </p>
          </section>

          {/* Mission */}
          <section className="mb-4xl">
            <h2 className="text-[22px] font-bold text-text-primary mb-lg">
              우리의 미션
            </h2>
            <p className="text-[15px] text-text-secondary leading-loose mb-md">
              GRIT은 피트니스 용품을 더 합리적인 가격에 구매할 수 있도록 소비자들을 연결하는 공동구매 플랫폼입니다.
              혼자서는 받기 어려운 대량 할인 혜택을 여럿이 함께 모여 누릴 수 있습니다.
            </p>
            <p className="text-[15px] text-text-secondary leading-loose">
              우리는 건강한 라이프스타일을 누구나 부담 없이 시작할 수 있는 세상을 만들고자 합니다.
              좋은 피트니스 장비와 용품이 가격 때문에 포기되는 일이 없도록, GRIT이 함께합니다.
            </p>
          </section>

          {/* How it works */}
          <section className="mb-4xl">
            <h2 className="text-[22px] font-bold text-text-primary mb-xl">
              이용 방법
            </h2>
            <div className="grid gap-lg mobile:grid-cols-3">
              {[
                {
                  step: '01',
                  title: '참여',
                  desc: '마음에 드는 공동구매 상품을 찾아 참여 신청을 합니다. 목표 인원과 마감 기한을 확인하세요.',
                },
                {
                  step: '02',
                  title: '모집',
                  desc: '다른 구매자들이 함께 모입니다. 목표 인원이 달성되면 공동구매가 성사됩니다.',
                },
                {
                  step: '03',
                  title: '할인',
                  desc: '목표 인원 달성 시 할인된 가격으로 상품을 구매할 수 있습니다. 함께할수록 더 큰 혜택!',
                },
              ].map((item) => (
                <div
                  key={item.step}
                  className="bg-surface border border-border-subtle rounded-md p-xl"
                >
                  <span className="text-[13px] font-bold text-accent mb-sm block">
                    STEP {item.step}
                  </span>
                  <h3 className="text-[18px] font-bold text-text-primary mb-sm">
                    {item.title}
                  </h3>
                  <p className="text-[14px] text-text-secondary leading-relaxed">
                    {item.desc}
                  </p>
                </div>
              ))}
            </div>
          </section>

          {/* Vision */}
          <section className="bg-surface border border-border-subtle rounded-lg p-2xl">
            <h2 className="text-[22px] font-bold text-text-primary mb-md">
              팀 비전
            </h2>
            <p className="text-[15px] text-text-secondary leading-loose mb-md">
              GRIT 팀은 피트니스에 대한 열정과 합리적 소비에 대한 믿음을 가진 사람들로 구성되어 있습니다.
              우리는 공동구매라는 모델이 단순히 가격을 낮추는 것을 넘어, 같은 목표를 가진 사람들을 연결하는
              커뮤니티가 될 수 있다고 믿습니다.
            </p>
            <p className="text-[15px] text-text-secondary leading-loose">
              앞으로도 더 다양한 카테고리, 더 많은 파트너사와 함께 여러분의 건강한 생활을 응원하겠습니다.
            </p>
          </section>
        </div>
      </main>

      <Footer />
    </div>
  );
}
