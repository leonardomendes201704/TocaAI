# TocaAI

Marketplace mobile para conectar **bares, casas e contratantes** a **músicos**, com foco em descoberta, candidatura, convite direto, contratação, operação do evento, reputação e pagamentos.

Este repositório concentra o produto inteiro em estágio de MVP expandido:

- aplicativo mobile Android-first em **Expo + React Native + TypeScript**
- backend em **Supabase**
- trilha de pagamentos em **Stripe Checkout + Stripe Connect**
- documentação operacional, backlog, modelo de dados e histórico de execução

## Visão do produto

O TocaAI resolve um problema operacional real de contratação artística:

- do lado do **Bar**, o produto permite publicar vagas, buscar artistas, receber candidaturas, avaliar perfis, conversar e contratar
- do lado do **Músico**, o produto permite montar perfil, portfolio, descobrir oportunidades, receber convites, negociar, confirmar shows e acompanhar repasses

O fluxo principal hoje já cobre:

1. cadastro e login
2. onboarding por tipo de conta
3. perfil completo de Bar e Músico
4. portfolio e mídia
5. criação e edição de vagas
6. candidatura do músico
7. convite direto do bar
8. chat contextual por oportunidade
9. contratação e agenda
10. avaliação bilateral pós-evento
11. reputação e sinais de confiança
12. pagamento com retenção e repasse via Stripe

## Estado atual

### Funcionalidades já implementadas

- autenticação por email com confirmação e recuperação de acesso
- perfis persistidos com Supabase
- CEP obrigatório com ViaCEP em fluxos de localização relevantes
- upload de fotos para perfil e portfolio
- vagas com recorrência, múltiplos estilos e filtros
- busca de artistas pelo Bar
- feed de oportunidades para o Músico
- candidatura, convite direto e chat contextual
- contratação, remarcação, cancelamento, agenda e lembretes operacionais
- reviews bilaterais e reputação pública
- observabilidade e telemetria básica
- Stripe Checkout da plataforma
- Stripe Connect onboarding do Músico
- repasse real em ambiente de teste
- fundação de notificações push no app e no Supabase

### Itens ainda em evolução

- automação completa de cobrança recorrente por ocorrência
- regra comercial final de `sinal` e `saldo`
- homologação final ponta a ponta da trilha de push remoto em device
- dashboards analíticos e trilha financeira auditável expandida

## Arquitetura resumida

### Frontend mobile

- **Expo**
- **React Native**
- **TypeScript**
- **Expo Router**
- **TanStack Query**
- **AsyncStorage**

### Backend

- **Supabase Auth**
- **Supabase Postgres**
- **Supabase Storage**
- **Supabase Edge Functions**
- **RLS**

### Pagamentos

- **Stripe Checkout** para cobrança do Bar
- **Stripe Connect** para onboarding e repasse ao Músico
- retenção do valor até conclusão do evento
- split entre taxa da plataforma e repasse do Músico

## Estrutura do repositório

```text
TocaAI/
|-- mobile/                  # app mobile Expo/React Native
|-- supabase/                # migrations e Edge Functions
|-- landing/                 # landing institucional
|-- backlog-viewer/          # viewer local de backlog/tasks
|-- Prototipo/               # referências visuais e HTML dos protótipos
|-- tasks/                   # histórico de execução por task
|-- BACKLOG.md               # backlog do produto
|-- TASKS.md                 # índice cronológico das tasks
|-- ARCHITECTURE.md          # arquitetura técnica
|-- DATA_MODEL.md            # modelo de dados
|-- USER_FLOWS.md            # fluxos do usuário
|-- UI_MAP.md                # mapa de telas
|-- MARKETPLACE_RULES.md     # regras de produto e operação
|-- MARKETPLACE_POLICIES.md  # políticas operacionais
|-- OBSERVABILITY.md         # observabilidade e telemetria
|-- NOTIFICATIONS.md         # push notifications
`-- PAYMENTS.md              # pagamentos Stripe
```

## Módulos principais do app

### Auth

Responsável por:

- cadastro
- login
- confirmação por deep link nativo
- recuperação de senha
- restauração de sessão

Arquivos centrais:

- [auth-provider.tsx](mobile/src/features/auth/auth-provider.tsx)
- [auth-gate.tsx](mobile/src/features/auth/auth-gate.tsx)
- [email.tsx](mobile/app/auth/email.tsx)
- [callback.tsx](mobile/app/auth/callback.tsx)
- [recovery.tsx](mobile/app/auth/recovery.tsx)

### Perfis

Responsável por:

- perfil do Bar
- perfil do Músico
- CEP e endereço
- portfolio e fotos
- completude do perfil
- reputação agregada

Arquivos centrais:

- [bar/profile.tsx](mobile/app/bar/profile.tsx)
- [musician/profile.tsx](mobile/app/musician/profile.tsx)
- [profile-editor.ts](mobile/src/features/profiles/profile-editor.ts)
- [profile-media.ts](mobile/src/features/profiles/profile-media.ts)
- [profile-reputation.tsx](mobile/src/features/reputation/profile-reputation.tsx)

### Marketplace

Responsável por:

- criação de vagas
- listagem de oportunidades
- detalhe da vaga
- busca de artistas
- candidatura
- convite direto
- filtros de região, cache e distância

Arquivos centrais:

- [opportunities.ts](mobile/src/features/opportunities/opportunities.ts)
- [opportunity-editor-screen.tsx](mobile/src/features/opportunities/opportunity-editor-screen.tsx)
- [opportunity-detail-screen.tsx](mobile/src/features/opportunities/opportunity-detail-screen.tsx)
- [bar-artist-search.ts](mobile/src/features/search/bar-artist-search.ts)
- [bar-artist-search-screen.tsx](mobile/src/features/search/bar-artist-search-screen.tsx)
- [bar-artist-detail-screen.tsx](mobile/src/features/search/bar-artist-detail-screen.tsx)

### Operação

Responsável por:

- chat contextual
- contratação
- agenda
- cancelamento e remarcação
- lembretes operacionais
- reviews pós-evento

Arquivos centrais:

- [chat.ts](mobile/src/features/chat/chat.ts)
- [contracts.ts](mobile/src/features/contracts/contracts.ts)
- [chat-thread-screen.tsx](mobile/src/features/chat/chat-thread-screen.tsx)
- [contract-review-screen.tsx](mobile/src/features/reviews/contract-review-screen.tsx)

### Pagamentos

Responsável por:

- checkout da plataforma
- onboarding Stripe Connect
- sincronização manual de conta conectada
- repasse pós-evento
- status financeiro por ocorrência

Arquivos centrais:

- [payments.ts](mobile/src/features/payments/payments.ts)
- [stripe-create-platform-checkout](supabase/functions/stripe-create-platform-checkout/index.ts)
- [stripe-platform-webhook](supabase/functions/stripe-platform-webhook/index.ts)
- [stripe-create-musician-connect-onboarding](supabase/functions/stripe-create-musician-connect-onboarding/index.ts)
- [stripe-sync-musician-connect-account](supabase/functions/stripe-sync-musician-connect-account/index.ts)
- [stripe-release-musician-payout](supabase/functions/stripe-release-musician-payout/index.ts)
- [stripe-connect-webhook](supabase/functions/stripe-connect-webhook/index.ts)

### Push notifications

Responsável por:

- permissão de notificação no device
- preferências por conta
- registro do token Expo
- dispatch remoto para eventos-chave do marketplace

Arquivos centrais:

- [notifications.ts](mobile/src/features/notifications/notifications.ts)
- [notifications-provider.tsx](mobile/src/features/notifications/notifications-provider.tsx)
- [notification-preferences-card.tsx](mobile/src/features/notifications/notification-preferences-card.tsx)
- [marketplace-push-dispatch](supabase/functions/marketplace-push-dispatch/index.ts)

## Modelo de negócio implementado até aqui

### Para o Bar

- cria vagas
- recebe candidaturas
- envia convites diretos
- faz pagamento do evento
- acompanha contratação, agenda e operação

### Para o Músico

- constrói perfil profissional
- recebe candidaturas/convites
- confirma contratação
- executa evento
- recebe repasse depois da conclusão

### Pagamento atual

O modelo atual já implementado é:

- cobrança do Bar por ocorrência
- retenção do valor na plataforma
- cálculo de taxa da plataforma
- repasse ao Músico após conclusão

O que ainda está em definição:

- regra final de `sinal` e `saldo`
- automação completa da cobrança recorrente em `T-48h`

## Banco de dados e backend

O projeto usa Supabase como backend principal. A evolução do schema foi feita por migrations versionadas em [supabase/migrations](supabase/migrations).

Entidades centrais:

- `public.accounts`
- `public.venue_profiles`
- `public.artist_profiles`
- `public.opportunities`
- `public.opportunity_applications`
- `public.contracts`
- `public.opportunity_chat_threads`
- `public.opportunity_chat_messages`
- `public.venue_reviews`
- `public.artist_reviews`
- `public.account_payment_profiles`
- `public.contract_payment_occurrences`
- `public.telemetry_events`
- `public.app_error_events`
- `public.account_notification_preferences`
- `public.account_push_registrations`
- `public.push_notification_deliveries`

Para detalhes completos:

- [DATA_MODEL.md](DATA_MODEL.md)

## Documentação importante

Se você está entrando agora no projeto, a leitura mais útil é:

1. [BACKLOG.md](BACKLOG.md)
2. [TASKS.md](TASKS.md)
3. [ARCHITECTURE.md](ARCHITECTURE.md)
4. [USER_FLOWS.md](USER_FLOWS.md)
5. [DATA_MODEL.md](DATA_MODEL.md)
6. [UI_MAP.md](UI_MAP.md)
7. [PAYMENTS.md](PAYMENTS.md)
8. [NOTIFICATIONS.md](NOTIFICATIONS.md)
9. [OBSERVABILITY.md](OBSERVABILITY.md)

## Como rodar localmente

### Pré-requisitos

Recomendado ter:

- Node.js compatível com Expo SDK 54
- npm
- Android Studio
- Android SDK
- Java 17
- Supabase configurado

### Variáveis de ambiente

Arquivo de exemplo:

- [mobile/.env.example](mobile/.env.example)

Variáveis públicas esperadas:

- `EXPO_PUBLIC_SUPABASE_URL`
- `EXPO_PUBLIC_SUPABASE_PUBLISHABLE_KEY`
- `EXPO_PUBLIC_APP_ENV`
- `EXPO_PUBLIC_EXPO_PROJECT_ID`

Observação:

- `mobile/.env.local` é local e não sobe para o repositório

### Instalação

```powershell
cd C:\Leonardo\Labs\TocaAI\mobile
npm install
```

### Rodar em desenvolvimento

```powershell
cd C:\Leonardo\Labs\TocaAI\mobile
npm run android
```

## Build Android para homologação

O projeto usa **build `release`** para homologação standalone em device, sem depender do Metro.

Comando validado:

```powershell
cd C:\Leonardo\Labs\TocaAI\mobile\android
$env:NODE_ENV='production'
.\gradlew.bat assembleRelease --no-daemon --console=plain
```

APK esperada:

```text
C:\Leonardo\Labs\TocaAI\mobile\android\app\build\outputs\apk\release\app-release.apk
```

Instalação ADB Wi‑Fi:

```powershell
adb connect IP:PORTA
adb -s IP:PORTA install -r C:\Leonardo\Labs\TocaAI\mobile\android\app\build\outputs\apk\release\app-release.apk
adb -s IP:PORTA shell monkey -p com.tocaai.app -c android.intent.category.LAUNCHER 1
```

Playbook completo:

- [AGENTS.md](AGENTS.md)

## Stripe

O projeto já está integrado com Stripe em ambiente de teste.

Hoje o fluxo suporta:

- Checkout para cobrança do Bar
- retenção do valor
- taxa da plataforma
- onboarding Stripe Connect do Músico
- repasse ao Músico após conclusão

Detalhes completos:

- [PAYMENTS.md](PAYMENTS.md)

## Notificações push

Há uma fundação de push já implementada, mas a homologação final do token/entrega ainda depende da configuração real do runtime Expo no aparelho.

Hoje a base cobre:

- candidatura
- convite direto
- mensagem de chat
- confirmação de contratação

Detalhes completos:

- [NOTIFICATIONS.md](NOTIFICATIONS.md)

## Observabilidade

O app já envia telemetria e erros estruturados para o Supabase.

Uso principal:

- diagnosticar falhas
- acompanhar funil
- preparar dashboards futuros

Detalhes completos:

- [OBSERVABILITY.md](OBSERVABILITY.md)

## Backlog e execução

O projeto é controlado por dois documentos vivos:

- [BACKLOG.md](BACKLOG.md): visão do produto e itens por épico
- [TASKS.md](TASKS.md): execução real, cronológica, por task

Isso permite responder com clareza:

- o que já está pronto
- o que está em andamento
- o que ainda falta
- quais evidências técnicas já foram geradas

## Situação do roadmap

### Concluído ou muito avançado

- fundação técnica do app
- onboarding e perfis
- marketplace inicial
- contratação, chat e agenda
- reputação e confiança
- telemetria
- pagamentos em test mode

### Em andamento

- `BKL-031` pagamento com sinal e saldo
- `BKL-032` notificações push
- `BKL-039` cobrança recorrente por ocorrência

### Futuro já registrado

- `BKL-042` ganhos do músico no perfil
- `BKL-043` trilha financeira auditável e base para dashboards

## Repositório e governança

Este repositório é a fonte de verdade de:

- código mobile
- migrations e Edge Functions
- backlog
- histórico de execução
- playbooks operacionais

Cada trilha relevante do projeto foi registrada em `tasks/TASK-###.md`, o que permite reconstituir a evolução do produto e das decisões técnicas sem depender de contexto externo.

## Observações finais

- O projeto foi pensado para **Android-first**
- O fluxo operacional do marketplace já funciona de ponta a ponta no MVP
- A documentação do repositório é parte do produto e deve evoluir junto com o código

Se você vai continuar a evolução daqui, o melhor ponto de entrada é:

1. ler [BACKLOG.md](BACKLOG.md)
2. ler [TASKS.md](TASKS.md)
3. escolher uma trilha aberta e continuar a partir das evidências já registradas
