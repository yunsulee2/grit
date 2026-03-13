import { Header } from '@/components/layout/Header';
import { Footer } from '@/components/layout/Footer';

const sections = [
  {
    title: '제1조 (목적)',
    content:
      '이 약관은 GRIT(이하 "회사")이 운영하는 공동구매 플랫폼 서비스(이하 "서비스")를 이용함에 있어 회사와 이용자의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.',
  },
  {
    title: '제2조 (정의)',
    content:
      '① "서비스"란 회사가 제공하는 피트니스 용품 공동구매 중개 서비스 및 이에 부가된 제반 서비스를 말합니다.\n② "이용자"란 이 약관에 따라 회사가 제공하는 서비스를 받는 회원 및 비회원을 말합니다.\n③ "회원"이란 회사에 개인정보를 제공하고 회원등록을 한 자로서, 회사의 정보를 지속적으로 제공받으며 서비스를 계속적으로 이용할 수 있는 자를 말합니다.\n④ "공동구매"란 다수의 이용자가 함께 상품을 구매하여 할인 혜택을 받는 구매 방식을 말합니다.',
  },
  {
    title: '제3조 (약관의 효력 및 변경)',
    content:
      '① 이 약관은 서비스를 이용하고자 하는 모든 이용자에 대하여 그 효력을 발생합니다.\n② 회사는 약관을 변경할 경우 최소 7일 전에 공지사항을 통해 공지합니다. 단, 이용자에게 불리한 변경의 경우 최소 30일 전에 공지합니다.\n③ 이용자가 개정 약관 시행일 이후에도 서비스를 계속 이용하면 개정 약관에 동의한 것으로 간주합니다.',
  },
  {
    title: '제4조 (서비스의 제공 및 변경)',
    content:
      '① 회사는 다음과 같은 서비스를 제공합니다.\n1. 공동구매 상품 정보 제공 서비스\n2. 공동구매 참여 신청 및 결제 중개 서비스\n3. 주문 및 배송 현황 조회 서비스\n4. 기타 회사가 정하는 서비스\n② 회사는 서비스의 내용을 변경할 수 있으며, 이 경우 변경된 서비스의 내용 및 제공일자를 명시하여 공지합니다.',
  },
  {
    title: '제5조 (회원가입)',
    content:
      '① 이용자는 회사가 정한 가입 양식에 따라 회원정보를 기입한 후 이 약관에 동의한다는 의사표시를 함으로써 회원가입을 신청합니다.\n② 회사는 다음 각 호에 해당하는 신청에 대하여는 승인을 하지 않거나 사후에 이용계약을 해지할 수 있습니다.\n1. 가입신청자가 이 약관에 의하여 이전에 회원자격을 상실한 적이 있는 경우\n2. 실명이 아니거나 타인의 명의를 이용한 경우\n3. 허위의 정보를 기재하거나 회사가 제시하는 내용을 기재하지 않은 경우',
  },
  {
    title: '제6조 (개인정보보호)',
    content:
      '회사는 관련 법령이 정하는 바에 따라 이용자의 개인정보를 보호하기 위해 노력합니다. 개인정보의 보호 및 사용에 대해서는 관련 법령 및 회사의 개인정보처리방침이 적용됩니다.',
  },
  {
    title: '제7조 (이용자의 의무)',
    content:
      '이용자는 다음 행위를 하여서는 안 됩니다.\n1. 신청 또는 변경 시 허위 내용의 등록\n2. 타인의 정보 도용\n3. 회사가 게시한 정보의 변경\n4. 회사가 정한 정보 이외의 정보(컴퓨터 프로그램 등) 등의 송신 또는 게시\n5. 회사와 기타 제3자의 저작권 등 지적재산권에 대한 침해\n6. 회사 및 기타 제3자의 명예를 손상시키거나 업무를 방해하는 행위',
  },
  {
    title: '제8조 (면책조항)',
    content:
      '① 회사는 천재지변 또는 이에 준하는 불가항력으로 인하여 서비스를 제공할 수 없는 경우에는 서비스 제공에 관한 책임이 면제됩니다.\n② 회사는 이용자의 귀책사유로 인한 서비스 이용의 장애에 대하여는 책임을 지지 않습니다.\n③ 회사는 이용자가 서비스를 이용하여 기대하는 수익을 상실한 것에 대하여 책임을 지지 않습니다.',
  },
  {
    title: '제9조 (분쟁해결)',
    content:
      '① 회사는 이용자가 제기하는 정당한 의견이나 불만을 반영하고 그 피해를 보상처리하기 위하여 피해보상처리기구를 설치, 운영합니다.\n② 회사와 이용자 간에 발생한 전자상거래 분쟁에 관한 소송은 제소 당시의 이용자의 주소에 의하고, 주소가 없는 경우에는 거소를 관할하는 지방법원의 전속관할로 합니다.',
  },
  {
    title: '부칙',
    content: '이 약관은 2026년 1월 1일부터 시행합니다.',
  },
];

export default function TermsPage() {
  return (
    <div className="min-h-screen flex flex-col bg-bg">
      <Header />

      <main className="flex-1">
        <div className="max-w-content mx-auto px-lg mobile:px-xl tablet:px-2xl py-4xl">
          {/* Header */}
          <section className="mb-4xl">
            <h1 className="text-[32px] font-black text-text-primary mb-md">
              이용약관
            </h1>
            <p className="text-[14px] text-text-tertiary">
              시행일: 2026년 1월 1일
            </p>
          </section>

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
