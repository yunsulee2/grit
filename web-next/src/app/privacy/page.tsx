import { Header } from '@/components/layout/Header';
import { Footer } from '@/components/layout/Footer';

const sections = [
  {
    title: '1. 수집하는 개인정보 항목',
    content:
      '회사는 서비스 제공을 위해 다음과 같은 개인정보를 수집합니다.\n\n[필수 항목]\n- 회원가입 시: 이름, 이메일 주소, 비밀번호, 휴대폰 번호\n- 주문 시: 배송지 주소, 수령인 이름, 연락처\n- 결제 시: 결제수단 정보(카드번호는 PG사에서 암호화하여 처리)\n\n[자동 수집 항목]\n- 서비스 이용 기록, 접속 로그, 쿠키, 접속 IP 정보',
  },
  {
    title: '2. 개인정보의 수집 목적',
    content:
      '회사는 수집한 개인정보를 다음의 목적을 위해 활용합니다.\n\n① 서비스 제공 및 계약 이행\n- 공동구매 참여, 결제, 배송 서비스 제공\n- 주문 확인, 영수증 발급, 배송 현황 안내\n\n② 회원 관리\n- 회원제 서비스 이용에 따른 본인확인\n- 불량 회원의 부정 이용 방지 및 비인가 사용 방지\n- 서비스 이용 관련 분쟁 조정\n\n③ 마케팅 및 광고\n- 신규 공동구매 상품 안내 및 이벤트 정보 전달 (동의한 경우에 한함)',
  },
  {
    title: '3. 개인정보의 보유 및 이용기간',
    content:
      '회사는 개인정보 수집 및 이용목적이 달성된 후에는 해당 정보를 지체 없이 파기합니다. 단, 다음의 정보에 대해서는 아래의 이유로 명시한 기간 동안 보존합니다.\n\n[회사 내부 방침에 의한 정보 보유]\n- 부정 이용 방지를 위한 이용 제한 기록: 1년\n\n[관련 법령에 의한 정보 보유]\n- 계약 또는 청약철회 등에 관한 기록: 5년\n- 대금결제 및 재화 등의 공급에 관한 기록: 5년\n- 소비자의 불만 또는 분쟁처리에 관한 기록: 3년\n- 웹사이트 방문에 관한 기록: 3개월',
  },
  {
    title: '4. 개인정보의 제3자 제공',
    content:
      '회사는 원칙적으로 이용자의 개인정보를 외부에 제공하지 않습니다. 단, 다음의 경우에는 예외로 합니다.\n\n① 이용자가 사전에 동의한 경우\n② 법령의 규정에 의거하거나, 수사 목적으로 법령에 정해진 절차와 방법에 따라 수사기관의 요구가 있는 경우\n③ 배송 서비스를 위한 배송업체에 배송에 필요한 최소한의 정보(수령인, 주소, 연락처) 제공',
  },
  {
    title: '5. 개인정보 처리의 위탁',
    content:
      '회사는 서비스 향상을 위해 아래와 같이 개인정보를 위탁하고 있으며, 관계 법령에 따라 위탁 계약 시 개인정보가 안전하게 관리될 수 있도록 필요한 사항을 규정하고 있습니다.\n\n- 결제 처리: ㈜토스페이먼츠\n- 이메일 발송: Amazon Web Services\n- 고객 상담: 사내 고객서비스팀',
  },
  {
    title: '6. 이용자의 권리',
    content:
      '이용자는 언제든지 자신의 개인정보를 조회하거나 수정, 삭제를 요청할 수 있습니다.\n\n① 개인정보 조회/수정: 마이페이지 > 회원정보 수정\n② 회원 탈퇴: 마이페이지 > 회원 탈퇴\n③ 그 외 개인정보 관련 요청: 고객센터(support@grit.kr)를 통해 문의',
  },
  {
    title: '7. 개인정보의 안전성 확보조치',
    content:
      '회사는 이용자의 개인정보를 처리함에 있어 개인정보가 분실, 도난, 유출, 변조 또는 훼손되지 않도록 다음과 같은 안전성 확보 조치를 취하고 있습니다.\n\n- 비밀번호의 암호화: 비밀번호는 단방향 암호화되어 저장 및 관리\n- 해킹 등에 대비한 기술적 대책: 보안프로그램 설치, 시스템 정기 점검\n- 개인정보 처리시스템 등의 접근 권한 관리\n- 개인정보 취급 직원의 최소화 및 교육',
  },
  {
    title: '8. 쿠키(Cookie) 운용',
    content:
      '회사는 이용자에게 맞춤화된 서비스를 제공하기 위해 쿠키를 사용합니다. 이용자는 웹 브라우저의 설정을 통해 쿠키를 허용하거나 거부할 수 있습니다. 단, 쿠키 저장을 거부할 경우 일부 서비스 이용에 제한이 있을 수 있습니다.',
  },
  {
    title: '9. 개인정보 보호책임자',
    content:
      '회사는 개인정보 처리에 관한 업무를 총괄해서 책임지고, 개인정보 처리와 관련한 이용자의 불만처리 및 피해구제 등을 위하여 아래와 같이 개인정보 보호책임자를 지정하고 있습니다.\n\n개인정보 보호책임자\n- 성명: GRIT 개인정보보호팀\n- 이메일: privacy@grit.kr\n- 연락처: 고객센터를 통해 문의',
  },
  {
    title: '10. 개인정보처리방침의 변경',
    content:
      '이 개인정보처리방침은 2026년 1월 1일부터 적용되며, 법령 및 방침에 따른 변경 내용의 추가, 삭제 및 정정이 있는 경우에는 변경사항의 시행 7일 전부터 공지사항을 통하여 고지할 것입니다.',
  },
];

export default function PrivacyPage() {
  return (
    <div className="min-h-screen flex flex-col bg-bg">
      <Header />

      <main className="flex-1">
        <div className="max-w-content mx-auto px-lg mobile:px-xl tablet:px-2xl py-4xl">
          {/* Header */}
          <section className="mb-4xl">
            <h1 className="text-[32px] font-black text-text-primary mb-md">
              개인정보처리방침
            </h1>
            <p className="text-[14px] text-text-tertiary">
              시행일: 2026년 1월 1일
            </p>
          </section>

          <p className="text-[15px] text-text-secondary leading-relaxed mb-3xl">
            GRIT(이하 "회사")은 이용자의 개인정보를 중요시하며, 「개인정보 보호법」, 「정보통신망 이용촉진 및 정보보호 등에 관한 법률」 등 관련 법령을 준수하고 있습니다. 회사는 개인정보처리방침을 통하여 이용자의 개인정보가 어떠한 용도와 방식으로 이용되고 있으며, 개인정보 보호를 위해 어떠한 조치가 취해지고 있는지 알려드립니다.
          </p>

          {/* Sections */}
          <div className="space-y-2xl">
            {sections.map((section) => (
              <section key={section.title}>
                <h2 className="text-[17px] font-bold text-text-primary mb-md">
                  {section.title}
                </h2>
                <div className="text-[14px] text-text-secondary leading-loose whitespace-pre-line">
                  {section.content}
                </div>
              </section>
            ))}
          </div>
        </div>
      </main>

      <Footer />
    </div>
  );
}
