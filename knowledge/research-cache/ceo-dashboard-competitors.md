# Research Cache: CEO Dashboard Competitors & Best Practices

Date: 2026-03-27
Source: Strategy Analyst + Researcher advisory wave

## Competitors Analyzed

1. **Baremetrics** — SaaS metrics dashboard
   - MRR, ARR, churn, LTV, ARPU
   - Clean area charts, minimal UI
   - Dark mode available

2. **ChartMogul** — Subscription analytics
   - Revenue recognition, cohort analysis
   - Multi-chart layouts, drill-down
   - Premium dashboard feel

3. **Stripe Dashboard** — Payment analytics
   - Revenue, payments, subscriptions
   - Card-based KPIs, sparklines
   - Clean, functional design

4. **ProfitWell** — Revenue automation
   - Growth metrics, retention
   - Actionable insights, not just data

5. **Mixpanel** — Product analytics
   - Funnels, retention, user flows
   - Interactive charts, segmentation

6. **Metabase** — BI dashboard
   - SQL-based, card layout
   - Auto-generated summaries

7. **Geckoboard** — TV dashboard
   - Real-time metrics, large numbers
   - Status indicators (green/amber/red)

## Design Principles Extracted

1. **KPI cards top** — 4-6 key metrics, always visible
2. **Sparklines in cards** — Trend at a glance without needing full chart
3. **Delta indicators** — % change with color (green up, red down)
4. **Section grouping** — Related metrics together (Revenue, Operations, Health)
5. **Charts below KPIs** — Detail drill-down, time series primary
6. **Dark theme** — Executive dashboards prefer dark for focus
7. **Responsive grids** — 6 cols → 3 cols → 2 cols → 1 col
8. **Status colors** — Consistent: emerald=good, amber=warning, red=danger

## Anti-Patterns to Avoid

- Too many charts on one page (max 6-8)
- Charts without context (always include delta/trend)
- Inconsistent color meaning across sections
- No empty states
- Fixed-width tables on mobile

## Tech Recommendations Applied

- ApexCharts for complex charts (already in dz-vue-ui)
- Chart.js for sparklines (lightweight)
- No new dependencies needed
