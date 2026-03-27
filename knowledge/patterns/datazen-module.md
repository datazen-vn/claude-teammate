# Pattern: DataZen Standard CRUD Module

Extracted from: CRM, Lodging, Reception modules
Applicable: Bất kỳ feature module nào cần CRUD operations

---

## Overview

Standard datazen module = modular monolith pattern. Extends base classes (BaseCrudAbstract, BaseCrudService, BaseModelAbstract) từ `laravel-crud-foundation` package. Vue frontend via Inertia.js.

## Directory Structure

```
Modules/{ModuleName}/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── Tenant/
│   │   │   │   ├── {Entity}Controller.php (extends CoreController)
│   │   │   │   └── Api/
│   │   │   │       └── {Entity}{Action}Controller.php
│   │   │   └── Central/ (optional)
│   │   ├── Requests/
│   │   │   └── {Entity}/
│   │   │       ├── SnU{Entity}Request.php (Store/Update)
│   │   │       └── Index{Entity}Request.php
│   │   ├── Resources/
│   │   │   └── {Entity}/
│   │   │       └── {Entity}Resource.php (JsonResource)
│   │   └── Middleware/
│   ├── Models/
│   │   └── {ModulePrefix}{EntityName}.php (extends BaseModelAbstract)
│   ├── Services/
│   │   └── {Entity}Service.php (extends BaseCrudService)
│   ├── Repositories/
│   │   └── {Entity}/
│   │       └── {Entity}Repository.php
│   ├── Providers/
│   │   ├── {Module}ServiceProvider.php
│   │   └── PoliciesServiceProvider.php
│   ├── Traits/
│   ├── Events/
│   └── Policies/ (optional)
├── resources/js/vue/
│   └── tenant/
│       ├── pages/{entity}/
│       │   ├── Index.vue
│       │   ├── Create.vue
│       │   ├── Edit.vue
│       │   └── Show.vue
│       ├── components/
│       ├── composables/
│       ├── constants/
│       └── locales/
├── routes/
│   ├── tenant.php
│   └── central.php (optional)
├── database/
│   ├── migrations/
│   ├── factories/
│   └── seeders/
├── config/ (optional)
├── module.json
├── composer.json
└── package.json
```

## Backend Patterns

### Controller (extends CoreController)
```php
namespace Modules\{Module}\Http\Controllers\Tenant;

use Modules\Core\Http\Controllers\CoreController;
use Modules\{Module}\Models\{ModulePrefix}{Entity};
use Modules\{Module}\Http\Resources\{Entity}\{Entity}Resource;

class {Entity}Controller extends CoreController
{
    protected ?string $model = {ModulePrefix}{Entity}::class;
    protected ?string $resourceClass = {Entity}Resource::class;
    protected string $resourceName = '{entities}';  // kebab-case plural
    protected string $viewPath = '{module}';         // module alias
    protected ?string $viewContext = 'tenant';

    // Optional hooks:
    protected function getFormViewData(?string $context): array
    {
        return [
            'relatedOptions' => SomeService::getOptions(),
        ];
    }

    protected function afterShow($item, array $itemData, Request $request): array
    {
        return ['stats' => $this->getStats($item)];
    }
}
```

### Service (extends BaseCrudService)
```php
namespace Modules\{Module}\Services;

use Modules\{Module}\Models\{ModulePrefix}{Entity};
use Modules\{Module}\Repositories\{Entity}\{Entity}Repository;

class {Entity}Service extends BaseCrudService
{
    protected $relations = ['relation1', 'relation2'];

    public function __construct(
        {Entity}Repository $repository,
    ) {
        parent::__construct(new {ModulePrefix}{Entity}, $repository);
    }

    // Hooks:
    protected function prepareDataForCreate(array $data): array { }
    protected function processRelations(Model $model, array $data) { }

    // Custom business logic methods
}
```

### Model (extends BaseModelAbstract)
```php
namespace Modules\{Module}\Models;

use DataZen\CrudFoundation\Models\BaseModelAbstract;
use Illuminate\Database\Eloquent\SoftDeletes;

class {ModulePrefix}{Entity} extends BaseModelAbstract
{
    use HasSubscriptionScope;  // Multi-tenancy
    use SoftDeletes;           // Optional

    protected $table = '{module}_{entities}';

    protected $fillable = ['name', 'subscription_uuid', ...];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
        ];
    }

    // Relationships
    public function relatedEntity(): HasMany { }
}
```

### Naming Conventions
| Item | Pattern | Example |
|------|---------|---------|
| Model | `{ModulePrefix}{Entity}` | `CrmCustomer`, `LgRoom`, `RcBooking` |
| Controller | `{Entity}Controller` | `CustomerController` |
| Service | `{Entity}Service` | `CustomerService` |
| Repository | `{Entity}Repository` | `CustomerRepository` |
| Resource | `{Entity}Resource` | `CustomerResource` |
| Table | `{module}_{entities}` | `crm_customers`, `lg_rooms` |
| Routes | `{module}.{entities}.{action}` | `crm.customers.index` |

### Routes (tenant.php)
```php
Route::group([
    'middleware' => ['auth', 'tenant', BindSubscriptionContext::class],
    'prefix' => '{subscription}/app/{moduleName}',
], function () {
    // Custom API routes
    Route::prefix('api/{entities}/{id}')->name('{module}.api.{entities}.')->group(function () {
        Route::get('timeline', [TimelineController::class, 'listTimeline']);
    });
});
```

## Frontend Patterns

### Page (Vue 3 + script setup)
```vue
<script setup lang="ts">
import { useDynamicPageContext } from '...';

defineOptions({ layout: {Module}Layout });

const { data, routes, props } = useDynamicPageContext();
</script>
```

### Key shared components (dz-vue-ui):
- `DzDataView` — List/table view with pagination, search, filters
- `DzFormLayoutMain` — Form layout with validation
- `DzContentSubMenuLayout` — Sidebar + content layout
- `DzTabPanes` / `DzTabPane` — Tab navigation

### Composable pattern:
```typescript
// composables/use{Entity}.ts
export function use{Entity}Detail() {
    const currentTab = ref('overview');
    const tabDataCache = ref<Record<string, any>>({});
    return { currentTab, tabDataCache, isTabLoaded, setTabData };
}
```

## Migration Pattern
```php
Schema::create('{module}_{entities}', function (Blueprint $table) {
    $table->id();
    $table->uuid('subscription_uuid');
    $table->string('name');
    // ... entity-specific fields
    $table->timestamps();    // millisecond precision via base model
    $table->softDeletes();   // optional

    $table->foreign('subscription_uuid')
          ->references('uuid')
          ->on('subscriptions');
});
```

## Shared Packages
- `laravel-crud-foundation` — Base classes (controller, service, model)
- `dz-vue-ui` — Shared Vue components + composables (auto-imported)
- `laravel-case-converter` — Auto camelCase ↔ snake_case
- `laravel-media-manager` — Media handling
- `laravel-tenancy-modules` — Multi-tenancy routing + scoping
