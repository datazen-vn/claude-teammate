# Pattern: Dashboard Page (Full-Stack)

Extracted from: CEO Dashboard (2026-03-27)
Applicable: Bất kỳ dashboard/analytics page nào trong datazen

---

## Overview

Dashboard page = standalone dark-theme page với KPI cards, charts, tables. Không dùng CRUD base classes — custom controller + service trả data cho Inertia Vue page.

## Directory Structure

```
Modules/{ModuleName}/
├── app/
│   ├── Http/
│   │   ├── Controllers/{Name}Controller.php
│   │   └── Middleware/{Name}AccessMiddleware.php
│   ├── Services/{Name}Service.php
│   └── Providers/
│       ├── {Name}ServiceProvider.php
│       ├── EventServiceProvider.php
│       └── RouteServiceProvider.php
├── resources/js/vue/central/
│   ├── layouts/{Name}Layout.vue
│   ├── pages/dashboard/Index.vue
│   └── components/
│       ├── KpiStatCard.vue
│       ├── {Metric}Chart.vue (ApexCharts)
│       ├── {Domain}Section.vue (section containers)
│       └── {Entity}Table.vue (data tables)
├── routes/central.php
├── module.json
└── composer.json
```

## Backend Pattern

### Controller
```php
namespace Modules\{Name}\Http\Controllers;

use App\Http\Controllers\Controller;
use Inertia\Inertia;
use Inertia\Response;
use Modules\{Name}\Services\{Name}Service;

class {Name}Controller extends Controller
{
    public function __construct(
        protected {Name}Service $dashboardService
    ) {}

    public function index(): Response
    {
        return Inertia::render(
            '{moduleName}/central/pages/dashboard/Index',
            ['dashboardData' => $this->dashboardService->getDashboardData()]
        )->rootView('core::vue.app');
    }
}
```

### Service — Data Provider
```php
class {Name}Service
{
    public function getDashboardData(): array
    {
        try {
            return [
                'section1' => $this->getSection1Data(),
                'section2' => $this->getSection2Data(),
                // ... more sections
                'lastUpdated' => now()->toISOString(),
            ];
        } catch (\Exception $e) {
            logger()->error('{Name} data failed: ' . $e->getMessage(), ['exception' => $e]);
            return $this->getEmptyDashboardData();
        }
    }

    // Each section method returns structured array
    private function getSection1Data(): array
    {
        return [
            'metric1' => [
                'value' => 15420,
                'delta' => 12.3,         // % change
                'trend' => 'up',         // 'up' | 'down' | 'stable'
                'sparkline' => [8200, 9100, ...],
                'status' => 'good',      // optional: 'good' | 'warning' | 'danger'
            ],
        ];
    }

    private function getEmptyDashboardData(): array { /* zero-value fallback */ }
}
```

### Metric Value Interface (standard across all dashboards)
```typescript
interface MetricValue {
    value: number
    delta?: number
    trend?: 'up' | 'down' | 'stable'
    sparkline?: number[]
    status?: string
    unit?: string
}
```

### Routes
```php
Route::middleware(['auth', {Name}AccessMiddleware::class])
    ->prefix('{url-prefix}')
    ->group(function () {
        Route::get('/dashboard', [{Name}Controller::class, 'index'])
            ->name('{route.name}.dashboard');
    });
```

## Frontend Pattern

### Layout (Dark Theme)
```
Colors:
  Main bg:   #070B14
  Header:    #0A0F1E
  Cards:     #0F1629
  Borders:   border-slate-800 (#1E293B)
  Text:      text-slate-100 (primary), text-slate-500 (labels)
  Positive:  text-emerald-400, bg-emerald-500/20
  Negative:  text-red-400, bg-red-500/20
  Warning:   text-amber-400, bg-amber-500/20
```

### Page Composition (Index.vue)
```
Section 1: KPI Cards Row — grid xl:grid-cols-6
Section 2: Charts Row — grid lg:grid-cols-5 (3/5 + 2/5 split)
Section 3: Full-width Chart
Section 4: Operations Side-by-Side — grid xl:grid-cols-2
Section 5: Data Section (chart + table)
Section 6: Pipeline/Growth Section
```

### Responsive Grid Patterns
```
KPI cards:      grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6
Revenue split:  grid-cols-1 lg:grid-cols-5 (col-span-3 + col-span-2)
Operations:     grid-cols-1 xl:grid-cols-2
Metric cards:   grid-cols-2 lg:grid-cols-4
```

### Typography
```
Section headers: text-sm font-semibold uppercase tracking-wider text-slate-500 mb-4
Card titles:     text-xs font-medium uppercase tracking-wider text-slate-500
KPI values:      text-2xl font-bold text-slate-100
Metric values:   text-xl font-bold text-slate-100
Labels:          text-xs text-slate-500
```

## Module Registration

### module.json
```json
{
    "name": "{ModuleName}",
    "version": "1.0.0",
    "alias": "{modulealias}",
    "description": "...",
    "providers": ["Modules\\{ModuleName}\\Providers\\{ModuleName}ServiceProvider"]
}
```

### Also update:
- `modules_statuses.json` — add `"{ModuleName}": true`
- `Modules/Core/vite.config.js` — add alias `$module-name-central`

## Key Learnings
- Mock data first, real queries later — full UI immediately
- invertDelta prop for "lower = better" metrics (churn, cost)
- min-w on tables for mobile (horizontal scroll > squished columns)
- Playwright + WebSocket: use curl login + set cookies approach
