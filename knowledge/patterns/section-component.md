# Pattern: Dashboard Section Component

Extracted from: CEO Dashboard (HospitalitySection, ChatbotSection, TenantHealthSection)
Applicable: Bất kỳ section trong dashboard chứa nhiều metrics + chart

---

## Structure

Section = container chứa:
1. Header (title)
2. Primary metrics grid (4 cols)
3. Chart component
4. Secondary metrics grid (2 cols, optional)

## Template

```vue
<script setup lang="ts">
interface SectionData {
    primaryMetric1: { value: number; delta?: number; trend?: string }
    primaryMetric2: { value: number; delta?: number }
    // ... more metrics
    trendData: Array<{ label: string; value: number }>
}

const props = defineProps<{
    data: SectionData
}>();

function formatCompact(val: number): string {
    if (val >= 1000000) return `${(val / 1000000).toFixed(1)}M`;
    if (val >= 1000) return `${(val / 1000).toFixed(1)}K`;
    return val.toString();
}

function formatDelta(delta: number): string {
    const sign = delta > 0 ? '+' : '';
    return `${sign}${delta.toFixed(1)}%`;
}

function deltaClass(delta: number, invert = false): string {
    if (delta === 0) return 'text-slate-400';
    const isPositive = invert ? delta < 0 : delta > 0;
    return isPositive ? 'text-emerald-400' : 'text-red-400';
}
</script>

<template>
    <div class="bg-[#0F1629] border border-slate-800 rounded-xl p-5">
        <!-- Header -->
        <h2 class="text-sm font-semibold uppercase tracking-wider text-slate-500 mb-4">
            Section Title
        </h2>

        <!-- Primary Metrics Grid -->
        <div class="grid grid-cols-2 lg:grid-cols-4 gap-3 mb-5">
            <div class="bg-[#070B14] rounded-lg p-4">
                <div class="text-xs font-medium uppercase tracking-wider text-slate-500 mb-1">
                    Metric Label
                </div>
                <div class="text-xl font-bold text-slate-100">
                    {{ formatCompact(data.primaryMetric1.value) }}
                </div>
                <div v-if="data.primaryMetric1.delta !== undefined"
                     class="text-xs mt-1"
                     :class="deltaClass(data.primaryMetric1.delta)">
                    {{ formatDelta(data.primaryMetric1.delta) }}
                </div>
            </div>
            <!-- ... more metric cards -->
        </div>

        <!-- Chart -->
        <TrendChart :data="data.trendData" />

        <!-- Secondary Metrics (optional) -->
        <div class="grid grid-cols-2 gap-3 mt-4 max-w-xs">
            <div class="bg-[#070B14] rounded-lg p-3">
                <div class="text-xs text-slate-500">Label</div>
                <div class="text-lg font-bold text-slate-100">Value</div>
            </div>
        </div>
    </div>
</template>
```

## Nesting Depths

```
Page bg:       #070B14
  Section bg:  #0F1629  (border border-slate-800 rounded-xl p-5)
    Metric bg: #070B14  (rounded-lg p-4)
```

## Responsive

- Primary metrics: `grid-cols-2 lg:grid-cols-4`
- Secondary metrics: `grid-cols-2 max-w-xs`
- Section itself: full width hoặc `xl:grid-cols-2` trong parent grid
