# HNI Channel Live Integration Phase 1

## Purpose

이 문서는
HNI auto-company v1.1 backend 위에
실제 Telegram / WhatsApp 채널을 붙이는
1차 설계 기준을 정리한다.

이번 문서는 **설계만 포함**한다.
실제 production webhook 개통과 메시지 발송은
범위 밖이다.

## Phase 1 Objective

- Telegram을 첫 실채널로 연결할 수 있는
  backend ingress 구조를 확정한다.
- WhatsApp은
  notification + 제한형 command 채널로 설계한다.
- channel command가
  HNI work order action으로 정규화되는 경로를 고정한다.

## Design Principles

- 채널은 입력 채널이지
  최종 의사결정자가 아니다.
- 모든 채널 명령은
  backend의 표준 work order action으로 변환되어야 한다.
- CEO 승인 게이트는
  채널 메시지에서도 동일하게 유지된다.
- production token, webhook secret,
  business verification은
  앱 코드와 분리해 backend secret store로 관리한다.

## Phase 1 Channel Priority

1. Telegram command channel
2. WhatsApp notification channel
3. WhatsApp limited command channel

## Telegram Phase 1

### Telegram Use

- `/new_order`
- `/approve`
- `/hold`
- `/resume`
- `/status`
- completion summary push

### Telegram Backend Flow

1. Telegram webhook가 backend ingress로 들어온다.
2. secret header / route verification을 수행한다.
3. inbound update를 standard command event로 변환한다.
4. command parser가 work order action으로 정규화한다.
5. backend orchestration service가 mutation 또는 status query를 처리한다.
6. 결과를 Telegram reply와 dashboard snapshot에 반영한다.

### Required Backend Modules

- `telegram_webhook_handler`
- `telegram_update_normalizer`
- `telegram_response_dispatcher`
- `channel_audit_logger`

## WhatsApp Phase 1

### WhatsApp Use

- approval request notification
- completion summary notification
- 제한된 structured command
  (`APPROVE WO-123`, `STATUS WO-123`)

### Reason for Restriction

- WhatsApp Cloud API는
  템플릿/정책/비즈니스 설정의 영향이 커서
  1차는 command-rich 채널보다
  notification 우선이 안전하다.
- free-form command보다
  구조형 command가 운영 리스크가 낮다.

### WhatsApp Backend Flow

1. WhatsApp webhook 수신
2. phone number / business account context 확인
3. supported command grammar 여부 검사
4. 지원되는 command만 표준 action으로 변환
5. 미지원 입력은 dashboard review queue로 보낸다

## Unified Channel Contract

### Standard Inbound Event

- `channel`
- `external_message_id`
- `sender_id`
- `sender_label`
- `received_at`
- `raw_text`
- `normalized_command`
- `target_order_id`
- `parse_status`

### Standard Outbound Event

- `channel`
- `target_user_or_chat`
- `message_type`
- `template_or_format`
- `payload`
- `sent_at`
- `delivery_status`

## Recommended Backend Additions After v1.1

### Phase 1.1

- webhook ingress routes
- secret validation
- inbound/outbound channel audit table

### Phase 1.2

- retry queue
- failed command review queue
- structured outbound notification templates

### Phase 1.3

- role-based channel permissions
- CEO-only approval command policy
- branch/product scoped command policy

## Security Rules

- bot token / app secret / verify token은
  코드 저장소에 두지 않는다.
- channel webhook는
  backend만 직접 받는다.
- desktop client는
  channel token을 직접 알지 않는다.
- approval command는
  허용된 sender identity와 policy check를 통과해야 한다.

## Recommended Implementation Order

1. backend webhook ingress abstraction 추가
2. Telegram 실연동
3. Telegram reply + completion summary
4. WhatsApp notification-only 연동
5. WhatsApp limited command 연동

## Exit Criteria for Phase 1

- Telegram inbound command가
  backend work order action으로 변환된다.
- dashboard와 channel audit에
  동일 event가 기록된다.
- completion report summary가
  Telegram 또는 WhatsApp notification으로 발송된다.
- CEO approval command 정책이
  backend에서 강제된다.

## Reference Links

- Telegram Bot API:
  [Telegram Bot API](https://core.telegram.org/bots/api)
- WhatsApp Cloud API overview:
  [WhatsApp Cloud API overview](https://developers.facebook.com/docs/whatsapp/cloud-api/overview/)
- WhatsApp Cloud API webhooks:
  [WhatsApp Cloud API webhooks](https://developers.facebook.com/docs/whatsapp/cloud-api/guides/set-up-webhooks/)
