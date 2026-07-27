#!/usr/bin/env bash
# Parity runner: executes both analyzers and checks every probe against
# expectations.json. Exit 0 = reality matches the manifest, probe by probe.
set -uo pipefail
cd "$(dirname "$0")"
[ -d vendor ] || composer install --no-interaction --quiet
mkdir -p var/phpstan

vendor/bin/phpstan analyse --no-progress --error-format=raw > .phpstan.out 2>&1
mago analyze > .mago.out 2>&1

python3 - <<'PYEOF'
import json, re, sys
exp = json.load(open('expectations.json'))
ps = open('.phpstan.out').read()
mg = re.sub(r'\x1b\[[0-9;]*m', '', open('.mago.out').read())
fail = 0
print(f"{'Probe':44} {'phpstan':28} {'mago':30}")
for probe, e in exp.items():
    if probe.startswith('_'): continue
    def present(out, code):
        return bool(re.search(rf'{probe}\.php.*{re.escape(code)}', out))
    ok_ps = present(ps, e['phpstan']) if e.get('phpstan') else not re.search(rf'{probe}\.php.*error\[', ps)
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
sys.exit(1 if fail else 0)
PYEOF
