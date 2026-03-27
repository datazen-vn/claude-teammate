# Pattern: Chart Component (Dark Theme)

Extracted from: CEO Dashboard (MrrChart, OccupancyChart, ConversationTrendChart, etc.)
Applicable: Bất kỳ chart/visualization component nào

---

## ApexCharts Component (Complex Charts)

```vue
<script setup lang="ts">
import VueApexCharts from 'vue3-apexcharts';
import type { ApexOptions } from 'apexcharts';

const props = defineProps<{
    data: Array<{ label: string; value: number; value2?: number }>
}>();

const series = computed(() => [
    { name: 'Series 1', data: props.data.map(d => d.value) },
]);

const chartOptions = computed<ApexOptions>(() => ({
    chart: {
        type: '{area|bar|donut|line}',
        height: 280,
        background: 'transparent',
        toolbar: { show: false },
        zoom: { enabled: false },
    },
    theme: { mode: 'dark' },
    colors: ['#6366F1', '#818CF8', '#A78BFA'],  // indigo palette
    fill: {
        type: 'gradient',
        gradient: { shadeIntensity: 1, opacityFrom: 0.4, opacityTo: 0.05 },
    },
    stroke: { curve: 'smooth', width: 2 },
    grid: { borderColor: '#1E293B', strokeDashArray: 3 },
    xaxis: {
        categories: props.data.map(d => d.label),
        labels: { style: { colors: '#64748B', fontSize: '11px' } },
    },
    yaxis: {
        labels: {
            style: { colors: '#64748B' },
            formatter: (val: number) => `$${(val / 1000).toFixed(0)}k`,
        },
    },
    tooltip: {
        theme: 'dark',
        y: { formatter: (val: number) => formatValue(val) },
    },
    legend: {
        labels: { colors: '#94A3B8' },
        position: 'top',
        horizontalAlign: 'right',
    },
    dataLabels: { enabled: false },
}));
</script>

<template>
    <div class="bg-[#0F1629] border border-slate-800 rounded-xl p-5">
        <h3 class="text-sm font-semibold uppercase tracking-wider text-slate-500 mb-4">
            Chart Title
        </h3>
        <VueApexCharts type="{type}" height="280" :options="chartOptions" :series="series" />
    </div>
</template>
```

## Chart Types Reference

| Type | Use Case | Colors |
|------|----------|--------|
| `area` | Trend over time (MRR, revenue) | `#6366F1`, `#818CF8` |
| `bar` (stacked) | Breakdown comparison | `#10B981`, `#6366F1`, `#F59E0B`, `#EF4444` |
| `donut` | Proportion/distribution | `#6366F1`, `#8B5CF6`, `#EC4899`, `#F59E0B`, `#10B981` |
| `line` | Simple trend | `#6366F1` |

## Chart.js Sparkline (Inline Mini Charts)

For KPI cards — lightweight, no axis, just the line:

```typescript
// Inside KpiStatCard.vue
import { Chart, registerables } from 'chart.js';
Chart.register(...registerables);

function renderSparkline(canvas: HTMLCanvasElement, data: number[]) {
    new Chart(canvas, {
        type: 'line',
        data: {
            labels: data.map((_, i) => i),
            datasets: [{
                data,
                borderColor: '#6366F1',
                borderWidth: 1.5,
                fill: true,
                backgroundColor: createGradient(canvas),  // Fade to transparent
                pointRadius: 0,
                tension: 0.4,
            }],
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false }, tooltip: { enabled: false } },
            scales: { x: { display: false }, y: { display: false } },
        },
    });
}
```

## Dark Theme Color Constants

```
Background:   #0F1629 (card), #070B14 (page)
Grid:         #1E293B (border-slate-800)
Text labels:  #64748B (slate-500)
Legend text:   #94A3B8 (slate-400)
Primary:      #6366F1 (indigo-500)
Secondary:    #818CF8 (indigo-400)
Success:      #10B981 (emerald-500)
Warning:      #F59E0B (amber-500)
Danger:       #EF4444 (red-500)
```

## Formatting Helpers

```typescript
function formatCurrency(val: number): string {
    return new Intl.NumberFormat('en-US', {
        style: 'currency', currency: 'USD',
        minimumFractionDigits: 0, maximumFractionDigits: 0,
    }).format(val);
}

function formatCompact(val: number): string {
    if (val >= 1000000) return `${(val / 1000000).toFixed(1)}M`;
    if (val >= 1000) return `${(val / 1000).toFixed(1)}K`;
    return val.toString();
}

function formatPercent(val: number): string {
    return `${val.toFixed(1)}%`;
}
```
