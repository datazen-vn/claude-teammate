# NestJS Test Failure Analysis — March 2026

Total: 248 failures / 2134 tests (88% pass rate)

## Categories
| Category | Tests | Fix |
|---|---|---|
| DI/Mock missing provider | ~210 | Add `{ provide: X, useValue: jest.fn() }` per suite |
| Real bugs (logic mismatch) | ~20 | Read service, align test assertions |
| Missing express import | ~16 | `pnpm add -D express @types/express` |
| Missing JoinColumn mock | 2 | Add to typeorm mock factory |

## DI/Mock Failures (14 suites, ~210 tests)
All same pattern: new dep added to constructor but test providers[] not updated.
Fix: add one mock line per missing dep in beforeEach.

Key suites: openai-chat (39), conversation-orchestrator (~20), webhook-signature (16),
agent-runtime (14), rag-sync (12), faq-search (11), knowledge-gpt-chunker (11)

## Real Bugs (5 suites, ~20 tests)
- central-database: platform→capability field rename
- response-parser: case change (Products vs PRODUCTS)
- rag-result-formatter: template wraps in {braces}
- subscription-feature: platformFeatureId=NaN
- layered-prompt-builder: layer ordering changed
