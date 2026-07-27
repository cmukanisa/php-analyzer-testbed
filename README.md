# PHP Analyzer Testbed

Deliberate-defect probes for PHP static analyzers — **every probe ships with
its expected verdict, and every verdict was measured by execution**, never
assumed. `./run.sh` re-runs both tools and fails if reality no longer matches
the manifest (`expectations.json`).

Companion to the [Mago Symfony & Doctrine plugins RFC](https://github.com/cmukanisa/mago-symfony/blob/feat/doctrine-symfony-plugins/PLUGINS-RFC.md)
and the [benchmarks page](https://cmukanisa.github.io/mago-plugin-benchmarks/).

## The probes (measured 2026-07-27)

| Probe | Defect | PHPStan (level max + ext.) | Mago 1.45 (+psr-container) |
|---|---|---|---|
| A | nonexistent method on container service (`::class`) | ✅ `method.notFound` | ✅ `non-existent-method` |
| B | unknown field in `findOneBy([...])` | ✅ `doctrine.findOneByArgument` | ❌ silent — *Doctrine plugin, stage 1* |
| C | nonexistent method on string-id service | ✅ `method.notFound` | 😶‍🌫️ blind noise (`mixed-method-access`) — *Symfony plugin* |
| D | nullable `find()` used without guard | ✅ `method.nonObject` | ✅ `possible-method-access-on-null` |
| E | nonexistent method on entity | ✅ `method.notFound` | ✅ `non-existent-method` |
| F | `int` returned where `string` declared | ✅ `return.type` | ✅ `invalid-return-statement` |
| G | magic finder on unknown field | ✅ `method.notFound` | 😶‍🌫️ blind noise (`non-documented-method`) — *Doctrine plugin, stage 2* |

Three states, deliberately distinguished: **detected**, **silent**, and
**blind noise** — a warning that fires on correct and defective code alike is
not a detection, and the manifest pins it as its own state.

## Run it

```bash
composer install
./run.sh        # exit 0 = the manifest still matches reality
```

Notable detail: `fixtures/container.xml` is a **hand-written** minimal Symfony
container dump — enough for `phpstan-symfony` to resolve both `::class` and
string-id fetches, and the target fixture for the Mago Symfony plugin.
