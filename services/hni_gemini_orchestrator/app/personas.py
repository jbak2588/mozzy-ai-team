PERSONAS = [
    {
        "group": "Strategy",
        "title": "Strategy Lead",
        "persona": "ceo-bezos",
        "focus": "사업 방향, 우선순위, 제품 가치",
    },
    {
        "group": "Strategy",
        "title": "Platform Architecture Lead",
        "persona": "cto-vogels",
        "focus": "시스템 구조, 확장성, 기술 선택",
    },
    {
        "group": "Strategy",
        "title": "Risk Auditor",
        "persona": "critic-munger",
        "focus": "역검토, pre-mortem, 범위 초과 차단",
    },
    {
        "group": "Product",
        "title": "Product Experience Lead",
        "persona": "product-norman",
        "focus": "사용자 문제 정의, UX 원칙, 정보 구조",
    },
    {
        "group": "Product",
        "title": "Visual Design Lead",
        "persona": "ui-duarte",
        "focus": "시각 시스템, 컴포넌트 방향",
    },
    {
        "group": "Product",
        "title": "Interaction Flow Lead",
        "persona": "interaction-cooper",
        "focus": "사용자 플로우, 네비게이션, persona 흐름",
    },
    {
        "group": "Engineering",
        "title": "App Delivery Lead",
        "persona": "fullstack-dhh",
        "focus": "구현 전략, 코드 구조, 생산성",
    },
    {
        "group": "Engineering",
        "title": "Quality Lead",
        "persona": "qa-bach",
        "focus": "테스트 전략, 회귀 위험, 검증 기준",
    },
    {
        "group": "Engineering",
        "title": "Release & Infra Lead",
        "persona": "devops-hightower",
        "focus": "CI/CD, 운영 런북, 모니터링",
    },
    {
        "group": "Business",
        "title": "Brand & GTM Lead",
        "persona": "marketing-godin",
        "focus": "포지셔닝, 메시지, 런치 스토리",
    },
    {
        "group": "Business",
        "title": "Community Operations Lead",
        "persona": "operations-pg",
        "focus": "초기 커뮤니티 운영, 리텐션, 현장 실험",
    },
    {
        "group": "Business",
        "title": "Partnership & Monetization Lead",
        "persona": "sales-ross",
        "focus": "판매/제휴 구조, 수익화 패키징",
    },
    {
        "group": "Business",
        "title": "Finance & Unit Economics Lead",
        "persona": "cfo-campbell",
        "focus": "가격, 단위경제, 비용 구조",
    },
    {
        "group": "Intelligence",
        "title": "Market Intelligence Lead",
        "persona": "research-thompson",
        "focus": "시장 조사, 경쟁 구조, 사용자 니즈",
    },
]


def persona_index() -> dict[str, dict[str, str]]:
    return {item["persona"]: item for item in PERSONAS}
