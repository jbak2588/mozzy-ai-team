class AgentPersonaDefinition {
  const AgentPersonaDefinition({
    required this.group,
    required this.title,
    required this.persona,
    required this.focus,
  });

  final String group;
  final String title;
  final String persona;
  final String focus;
}

const agentPersonas = [
  AgentPersonaDefinition(
    group: 'Strategy',
    title: 'Strategy Lead',
    persona: 'ceo-bezos',
    focus: '사업 방향, 우선순위, 제품 가치',
  ),
  AgentPersonaDefinition(
    group: 'Strategy',
    title: 'Platform Architecture Lead',
    persona: 'cto-vogels',
    focus: '시스템 구조, 확장성, 기술 선택',
  ),
  AgentPersonaDefinition(
    group: 'Strategy',
    title: 'Risk Auditor',
    persona: 'critic-munger',
    focus: '역검토, pre-mortem, 범위 초과 차단',
  ),
  AgentPersonaDefinition(
    group: 'Product',
    title: 'Product Experience Lead',
    persona: 'product-norman',
    focus: '사용자 문제 정의, UX 원칙, 정보 구조',
  ),
  AgentPersonaDefinition(
    group: 'Product',
    title: 'Visual Design Lead',
    persona: 'ui-duarte',
    focus: '시각 시스템, 컴포넌트 방향',
  ),
  AgentPersonaDefinition(
    group: 'Product',
    title: 'Interaction Flow Lead',
    persona: 'interaction-cooper',
    focus: '사용자 플로우, 네비게이션, persona 흐름',
  ),
  AgentPersonaDefinition(
    group: 'Engineering',
    title: 'App Delivery Lead',
    persona: 'fullstack-dhh',
    focus: '구현 전략, 코드 구조, 생산성',
  ),
  AgentPersonaDefinition(
    group: 'Engineering',
    title: 'Quality Lead',
    persona: 'qa-bach',
    focus: '테스트 전략, 회귀 위험, 검증 기준',
  ),
  AgentPersonaDefinition(
    group: 'Engineering',
    title: 'Release & Infra Lead',
    persona: 'devops-hightower',
    focus: 'CI/CD, 운영 런북, 모니터링',
  ),
  AgentPersonaDefinition(
    group: 'Business',
    title: 'Brand & GTM Lead',
    persona: 'marketing-godin',
    focus: '포지셔닝, 메시지, 런치 스토리',
  ),
  AgentPersonaDefinition(
    group: 'Business',
    title: 'Community Operations Lead',
    persona: 'operations-pg',
    focus: '초기 커뮤니티 운영, 리텐션, 현장 실험',
  ),
  AgentPersonaDefinition(
    group: 'Business',
    title: 'Partnership & Monetization Lead',
    persona: 'sales-ross',
    focus: '판매/제휴 구조, 수익화 패키징',
  ),
  AgentPersonaDefinition(
    group: 'Business',
    title: 'Finance & Unit Economics Lead',
    persona: 'cfo-campbell',
    focus: '가격, 단위경제, 비용 구조',
  ),
  AgentPersonaDefinition(
    group: 'Intelligence',
    title: 'Market Intelligence Lead',
    persona: 'research-thompson',
    focus: '시장 조사, 경쟁 구조, 사용자 니즈',
  ),
];

Map<String, AgentPersonaDefinition> buildAgentPersonaIndex() {
  return {for (final persona in agentPersonas) persona.persona: persona};
}

List<String> defaultPersonasForSquad(String squad) {
  switch (squad) {
    case 'Discovery':
      return const ['ceo-bezos', 'research-thompson', 'product-norman'];
    case 'Feature Delivery':
      return const ['cto-vogels', 'fullstack-dhh', 'qa-bach', 'ui-duarte'];
    case 'Trust & Readiness':
      return const ['critic-munger', 'qa-bach', 'devops-hightower'];
    case 'Community Growth':
      return const ['marketing-godin', 'operations-pg', 'sales-ross'];
    case 'Release Planning':
      return const ['cto-vogels', 'devops-hightower', 'cfo-campbell'];
    default:
      return const ['ceo-bezos', 'cto-vogels', 'fullstack-dhh'];
  }
}

String defaultLeadForSquad(String squad) {
  switch (squad) {
    case 'Discovery':
      return 'ceo-bezos';
    case 'Feature Delivery':
      return 'fullstack-dhh';
    case 'Trust & Readiness':
      return 'critic-munger';
    case 'Community Growth':
      return 'marketing-godin';
    case 'Release Planning':
      return 'devops-hightower';
    default:
      return 'ceo-bezos';
  }
}
