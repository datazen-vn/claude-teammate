# Decision: Dark Theme Standalone Layout for CEO Dashboard

Date: 2026-03-27
Context: CEO Dashboard design

## Decision

CEO Dashboard dùng dark theme layout riêng (`#070B14` bg), tách biệt visual với main app (light theme). Render via `->rootView('core::vue.app')` nhưng dùng custom layout Vue component.

## Reasoning

1. **Standalone product feel** — CEO dashboard cảm giác premium, không phải "thêm 1 menu item"
2. **Focus** — Dark bg + light text = executive dashboard best practice (Baremetrics, ChartMogul)
3. **No conflict** — Custom layout = không ảnh hưởng main app styles
4. **Reusable** — Dark layout pattern có thể dùng cho admin dashboards khác

## Color Palette

```
Main bg:     #070B14
Header bg:   #0A0F1E
Card bg:     #0F1629
Nested bg:   #070B14 (same as main — creates depth)
Border:      border-slate-800 (#1E293B)
```

## When To Apply

- Executive/CEO dashboards
- System admin dashboards
- Monitoring/ops dashboards
- NOT for regular tenant-facing pages (keep light theme)
