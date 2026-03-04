import { Header } from '@/components/layout/Header';
import { Footer } from '@/components/layout/Footer';

const steps = [
  {
    num: 1,
    title: '공동구매 둘러보기',
    desc: '홈 화면에서 다양한 피트니스 용품 공동구매 상품을 확인하세요. 카테고리 필터와 검색 기능을 이용해 원하는 상품을 쉽게 찾을 수 있습니다. 각 상품 카드에서 현재 참여 인원, 목표 인원, 마감 기한, 할인율을 한눈에 확인할 수 있습니다.',
  },
  {
    num: 2,
    title: '마음에 드는 상품 참여하기',
    desc: '상품을 클릭해 상세 페이지로 이동하세요. 상품 정보, 판매자 정보, 배송 안내를 꼼꼼히 확인한 후 "공동구매 참여하기" 버튼을 눌러 참여 신청을 합니다. 로그인이 필요하며, 결제는 목표 인원 달성 후 진행됩니다.',
  },
  {
    num: 3,
    title: '목표 인원 달성 시 할인 적용',
    desc: '마감 기한 내 목표 인원이 달성되면 공동구매가 성사됩니다. 참여하신 이메일로 알림이 발송되며, 할인된 가격으로 최종 결제가 진행됩니다. 목표 인원 미달 시 참여 신청이 자동으로 취소되고 결제 금액은 전액 환불됩니다.',
  },
  {
    num: 4,
    title: '배송 받기',
    desc: '결제 완료 후 판매자가 배송을 준비합니다. 마이페이지에서 주문 현황과 배송 상태를 실시간으로 확인할 수 있습니다. 배송 관련 문의는 고객센터를 통해 접수해 주세요.',
  },
];

const faqs = [
  {
    q: '공동구매 참여 후 취소할 수 있나요?',
    a: '목표 인원 달성 전까지는 취소가 가능합니다. 마이페이지 > 주문 내역에서 취소 신청을 해주세요. 목표 인원 달성 후에는 판매자와의 협의가 필요하며, 경우에 따라 취소가 제한될 수 있습니다.',
  },
  {
    q: '목표 인원이 달성되지 않으면 어떻게 되나요?',
    a: '마감 기한까지 목표 인원이 달성되지 않으면 공동구매는 자동으로 취소됩니다. 결제하신 금액은 영업일 기준 3~5일 이내에 전액 환불됩니다.',
  },
  {
    q: '배송은 얼마나 걸리나요?',
    a: '배송 기간은 상품마다 다릅니다. 상품 상세 페이지에서 예상 배송 기간을 확인하세요. 공동구매 성사 후 판매자 발송 기준으로 평균 3~7 영업일 소요됩니다.',
  },
  {
    q: '교환 및 환불은 어떻게 하나요?',
    a: '상품 수령 후 7일 이내에 마이페이지에서 교환/환불 신청이 가능합니다. 단, 상품의 하자가 아닌 단순 변심의 경우 왕복 배송비가 발생할 수 있습니다.',
  },
  {
    q: '공동구매 알림을 받을 수 있나요?',
    a: '관심 있는 카테고리나 상품을 찜해두면, 공동구매 시작 및 마감 임박 알림을 이메일과 앱 푸시로 받을 수 있습니다. 알림 설정은 마이페이지 > 알림 설정에서 변경 가능합니다.',
  },
];

export default function GuidePage() {
  return (
    <div className="min-h-screen flex flex-col bg-bg">
      <Header />

      <main className="flex-1">
        <div className="max-w-content mx-auto px-lg mobile:px-xl tablet:px-2xl py-4xl">
          {/* Hero */}
          <section className="mb-4xl">
            <h1 className="text-[32px] font-black text-text-primary mb-md">
              이용 가이드
            </h1>
            <p className="text-[16px] text-text-secondary">
              GRIT 공동구매를 처음 이용하시나요? 아래 가이드를 따라 쉽게 시작해보세요.
            </p>
          </section>

          {/* Steps */}
          <section className="mb-4xl">
            <h2 className="text-[22px] font-bold text-text-primary mb-xl">
              공동구매 참여 방법
            </h2>
            <div className="space-y-lg">
              {steps.map((step) => (
                <div
                  key={step.num}
                  className="flex gap-xl bg-surface border border-border-subtle rounded-md p-xl"
                >
                  <div className="flex-shrink-0 w-[48px] h-[48px] rounded-full bg-primary flex items-center justify-center">
                    <span className="text-[18px] font-black text-bg">
                      {step.num}
                    </span>
                  </div>
                  <div>
                    <h3 className="text-[17px] font-bold text-text-primary mb-sm">
                      {step.title}
                    </h3>
                    <p className="text-[14px] text-text-secondary leading-relaxed">
                      {step.desc}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </section>

          {/* FAQ */}
          <section>
            <h2 className="text-[22px] font-bold text-text-primary mb-xl">
              자주 묻는 질문
            </h2>
            <div className="space-y-md">
              {faqs.map((faq, idx) => (
                <div
                  key={idx}
                  className="bg-surface border border-border-subtle rounded-md p-xl"
                >
                  <h3 className="text-[15px] font-bold text-text-primary mb-sm">
                    Q. {faq.q}
                  </h3>
                  <p className="text-[14px] text-text-secondary leading-relaxed">
                    A. {faq.a}
                  </p>
                </div>
              ))}
            </div>
          </section>
        </div>
      </main>

      <Footer />
    </div>
  );
}
