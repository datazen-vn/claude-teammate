# Decision: Mock Data First, Real Queries Later

Date: 2026-03-27
Context: CEO Dashboard development

## Decision

Khi build dashboard/analytics page mới: mock data service trước, real DB queries sau.

## Reasoning

1. **Full UI immediately** — Designer/CEO review giao diện ngay, không chờ DB schema
2. **Parallel work** — Frontend build trên mock, backend build real queries song song
3. **Realistic feedback** — Mock data 400+ lines, 7 methods → dashboard nhìn production-ready
4. **Iterate faster** — Thay đổi data shape dễ hơn khi mock (không cần migration)
5. **Phase 2 clear** — Service interface đã define, chỉ cần swap mock → real

## When To Apply

- Dashboard / analytics pages
- Report pages
- Any page where data visualization > data input
- NOT for CRUD modules (cần real DB từ đầu)

## Implementation

```php
// Phase 1: Mock
class DashboardService
{
    public function getDashboardData(): array
    {
        return [
            'metrics' => $this->getMockMetrics(),
            'charts' => $this->getMockChartData(),
        ];
    }
}

// Phase 2: Replace mock methods with real queries
// Interface KHÔNG đổi → frontend KHÔNG cần thay đổi
```
