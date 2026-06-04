# Review Checklist — Detailed Patterns

This reference contains concrete code patterns for each review dimension. The agent reads this file when more context is needed on a specific finding category.

---

## 1. Correctness & Logic

### Null / Undefined Mishandling

```typescript
// BAD — optional chain hides the real bug
const name = user?.profile?.name ?? 'Unknown';
// If user should never be null here, this silently masks a broken invariant.

// GOOD — fail fast at the boundary, trust the type downstream
if (!user) throw new Error('User must be loaded before rendering');
const name = user.profile.name;
```

### Async Race Conditions

```typescript
// BAD — no cancellation on rapid calls
async onSearchInput(query: string) {
  const results = await this.searchService.search(query);
  this.results = results; // stale if a newer search completed first
}

// GOOD — abort previous request
private _searchController?: AbortController;
async onSearchInput(query: string) {
  this._searchController?.abort();
  this._searchController = new AbortController();
  const results = await this.searchService.search(query, {
    signal: this._searchController.signal,
  });
  this.results = results;
}
```

---

## 2. Code Quality & Maintainability

### Dead Code Indicators

- Functions or methods with zero call-sites (search the repo before flagging).
- Commented-out code blocks (should be deleted, not commented).
- Feature-flag-gated code where the flag has been permanently enabled.
- Enum members or type union branches never matched.

### Complexity Thresholds

Flag when:
- A function exceeds ~40 lines of logic (excluding type declarations).
- Nesting depth exceeds 3 levels (if/for/try).
- A switch/case exceeds 6 branches without delegation.

---

## 3. Pattern Consistency

Identify the project's conventions by reading existing files, then flag deviations in the diff. The examples below use Lit/MobX as one stack — adapt the principle (consistent ordering, scoped state access, conventional naming) to whatever framework the repo uses.

### Component Structure (example: Lit)

A common ordering convention:
1. Static properties / decorators (`@property`, `@state`)
2. Private fields
3. Lifecycle (`connectedCallback`, `disconnectedCallback`, `willUpdate`, `updated`)
4. Public methods
5. Private methods / handlers
6. `render()` at the bottom

Flag deviations from the order the rest of the codebase uses.

### State Access (example: MobX stores)

- Components access stores via context/injection, not by importing singletons directly.
- Reactions should be scoped to the component lifecycle (e.g., disposed on disconnect), not bare global subscriptions.
- Distinguish source-of-truth state from derived/computed values; flag when one is used for the other.

### Event Naming

- Custom events use the codebase's convention (e.g., kebab-case `my-component-changed`, not `myComponentChanged`).
- Events dispatched with the platform-appropriate constructor (e.g., `new CustomEvent('...')` in DOM environments).

---

## 4. TypeScript Type Safety

### Unsafe Patterns to Flag

| Pattern | Why It's Risky |
|---------|---------------|
| `as any` | Disables all type checking at that point |
| `as unknown as T` | Double assertion bypasses structural checks |
| `// @ts-ignore` / `// @ts-expect-error` without explanation | Hides real type errors |
| `!` (non-null assertion) on external data | Runtime null will crash |
| `Function` type | Accepts anything callable, no signature checking |
| `object` type | Too broad, prefer specific interface |

### Prefer

- Discriminated unions over type assertions.
- `satisfies` operator for type-safe object literals.
- Explicit return types on exported functions and public methods.

---

## 5. Rendering Performance

### Example: Reactive UI frameworks (Lit shown below)

```typescript
// BAD — new array every render triggers dirty check
render() {
  return html`<my-list .items=${this.data.filter(d => d.active)}></my-list>`;
}

// GOOD — cache the derived value in a pre-render lifecycle hook
willUpdate(changed: PropertyValues) {
  if (changed.has('data')) {
    this._activeItems = this.data.filter(d => d.active);
  }
}
render() {
  return html`<my-list .items=${this._activeItems}></my-list>`;
}
```

The same principle applies in any reactive framework: derive values once when inputs change, not on every render.

### Object Identity

- Passing new object/array literals as property values in render paths causes child re-renders every cycle.
- Inline style/class maps with literal objects — cache them.

### Derived/Observable State

- Derived values that touch collections by identity (`.slice()`, `.filter()`) recompute every time. Use memoization helpers or structural comparison when appropriate.

---

## 6. Import Hygiene

### Circular Dependency Detection

If file A imports from file B and file B imports from file A (directly or transitively), flag it. Common symptoms:
- `undefined` at runtime for an imported class.
- Webpack/Rollup warnings about circular references.

### Package Boundary Violations

Importing from internal paths of another package:

```typescript
// BAD — reaches into another package's internals
import { helper } from '@myorg/other-package/src/utils/helper';

// GOOD — import from the public API
import { helper } from '@myorg/other-package';
```

---

## 7. Error Handling

### Swallowed Errors

```typescript
// BAD
try { await riskyOp(); } catch { /* nothing */ }

// GOOD — at minimum, log
try {
  await riskyOp();
} catch (error) {
  logger.error('riskyOp failed', { error });
}
```

### Unhandled Rejections

```typescript
// BAD — floating promise
this.loadData();

// GOOD
this.loadData().catch(err => this._handleError(err));
// or
void this.loadData(); // if intentionally fire-and-forget AND error is handled inside
```

---

## 8. Test Coverage

### What to Look For

- New public method → should have at least one test.
- New conditional branch → should have positive and negative cases.
- Bug fix → should have a regression test that would have caught the bug.
- Changed behaviour → existing tests should be updated, not deleted.

### Test Smell Patterns

- Testing implementation details (private methods, internal state) rather than observable behaviour.
- Tests with no assertions or only `expect(true).toBe(true)`.
- Copy-paste test blocks with minor variations (should be parameterized).

---

## 9. Security

### DOM Injection

```typescript
// BAD — user input into innerHTML
this.container.innerHTML = `<div>${userInput}</div>`;

// GOOD — use Lit's html tagged template (auto-escapes)
render() {
  return html`<div>${this.userInput}</div>`;
}
```

### URL Construction

```typescript
// BAD — open redirect
window.location.href = params.get('redirect');

// GOOD — validate against allowlist
const redirect = params.get('redirect');
if (ALLOWED_ORIGINS.some(o => redirect?.startsWith(o))) {
  window.location.href = redirect;
}
```

---

## 10. Accessibility

### Interactive Elements Checklist

- Clickable `<div>` or `<span>` → should be `<button>` or have `role="button"` + `tabindex="0"` + keyboard handler.
- Custom input → needs `aria-label` or `aria-labelledby`.
- Dynamic content change → needs `aria-live` region or focus management.
- Toggle control → needs `aria-pressed` or `aria-expanded`.
- Modal/dialog → needs focus trap and `aria-modal="true"`.

---

## 11. Breaking Changes

### Detection Heuristics

- Exported symbol renamed or removed → check if any other package imports it.
- Function parameter added as required → callers will break.
- Event payload shape changed → listeners expecting old shape will break.
- CSS custom property removed or renamed → themed consumers will break.
- Default value changed → callers relying on old default may break silently.

When flagging a breaking change, search the repo for usages to quantify the blast radius.
