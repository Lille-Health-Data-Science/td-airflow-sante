#!/usr/bin/env bash
# Voies B et C : relit tout de suite le dossier dags/ et signale les fichiers en erreur.
# Usage, depuis le dossier td-airflow-sante :  bash scripts/rafraichir.sh
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/env.sh
python3 - <<'PY'
import importlib.util, pathlib, traceback
ok = True
for f in sorted(pathlib.Path("dags").glob("*.py")):
    try:
        spec = importlib.util.spec_from_file_location(f.stem, f)
        spec.loader.exec_module(importlib.util.module_from_spec(spec))
    except Exception as e:
        ok = False
        print(f"ERREUR dans {f} :")
        print("".join(traceback.format_exception_only(type(e), e)).strip())
if ok:
    print("Aucune erreur dans dags/.")
PY
airflow dags reserialize >/dev/null 2>&1 && echo "Dossier dags/ relu : rechargez la page d'Airflow."
