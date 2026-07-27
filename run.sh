#!/usr/bin/env bash
# Parity runner: executes both analyzers and checks every probe against
# expectations.json. Exit 0 = reality matches the manifest, probe by probe.
set -uo pipefail
cd "$(dirname "$0")"
[ -d vendor ] || composer install --no-interaction --quiet
mkdir -p var/phpstan

vendor/bin/phpstan analyse --no-progress --error-format=json > .phpstan.out 2>&1
mago analyze > .mago.out 2>&1

python3 - <<'PYEOF'
import json, re, sys
exp = json.load(open('expectations.json'))
# JSON, not raw: the raw format only prints [identifier=...] depending on
# the phpstan version — measured 2026-07-27: green locally, seven FAILs in
# CI on identical code. The JSON format exposes identifiers stably.
raw = open('.phpstan.out').read()
psmap = {}
try:
    doc = json.loads(raw[raw.index('{'):])
    for path, info in (doc.get('files') or {}).items():
        for m in info.get('messages', []):
            if m.get('identifier'):
                psmap.setdefault(path.split('/')[-1], set()).add(m['identifier'])
except ValueError:
    pass
mg = re.sub(r'\x1b\[[0-9;]*m', '', open('.mago.out').read())
fail = 0
print(f"{'Probe':44} {'phpstan':28} {'mago':30}")
for probe, e in exp.items():
    if probe.startswith('_'): continue
    def present(out, code):
        return bool(re.search(rf'{probe}\.php.*{re.escape(code)}', out))
    ids = psmap.get(f'{probe}.php', set())
    ok_ps = (e['phpstan'] in ids) if e.get('phpstan') else not ids
    noise = e.get('mago_observed_noise')
    if e.get('mago'):
        ok_mg, mg_lbl = present(mg, e['mago']), e['mago']
    elif noise:
        # Blind noise is a measured STATE: the noise code must be there, the
        # real detection must not. If either changes, reality moved.
        ok_mg, mg_lbl = present(mg, noise), f'(blind: {noise})'
    else:
        ok_mg, mg_lbl = not re.search(rf'{probe}\.php.*error\[', mg), '(silent, as measured)'
    def lbl(ok, t): return ('OK   ' if ok else 'FAIL ') + t
    print(f"{probe:44} {lbl(ok_ps, e.get('phpstan') or '(silent)'):30} {lbl(ok_mg, mg_lbl):34}")
    fail += (not ok_ps) + (not ok_mg)
print(f"\n{'PARITY MANIFEST HOLDS' if fail == 0 else f'{fail} MISMATCH(ES) — reality moved, re-measure and update expectations.json'}")
if fail:
    # A failure without raw output is undiagnosable in CI: dumping what each
    # tool actually saw is the difference between "reality moved" and
    # "the tool never started".
    print('\n--- phpstan identifiers seen ---')
    print(json.dumps({k: sorted(v) for k, v in psmap.items()}, indent=1) or '(none)')
    print('\n--- mago output (tail) ---')
    print('\n'.join(mg.strip().splitlines()[-6:]) or '(empty)')
sys.exit(1 if fail else 0)
PYEOF
