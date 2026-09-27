import json
import re

with open('assets/language/ar.json', 'r', encoding='utf-8') as f:
    ar = json.load(f)
with open('assets/language/en.json', 'r', encoding='utf-8') as f:
    en = json.load(f)
with open('assets/language/bn.json', 'r', encoding='utf-8') as f:
    bn = json.load(f)
with open('assets/language/es.json', 'r', encoding='utf-8') as f:
    es = json.load(f)

def check_keys_in_file(filepath):
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    # Find all 'some_key'.tr
    keys = re.findall(r"['\"]([a-zA-Z0-9_\-]+)['\"]\s*\.\s*tr", content)
    missing = {'ar': [], 'en': [], 'bn': [], 'es': []}
    for k in keys:
        if k not in ar: missing['ar'].append(k)
        if k not in en: missing['en'].append(k)
        if k not in bn: missing['bn'].append(k)
        if k not in es: missing['es'].append(k)
    return set(keys), missing

files = [
    'lib/features/employee/requests/screens/employee_requests_screen.dart',
    'lib/features/employee/requests/models/employee_request_model.dart',
    'lib/features/employee/attendance/screens/select_work_zone_screen.dart',
    'lib/features/employee/attendance/screens/attendance_stepper_screen.dart',
]

for f in files:
    keys, miss = check_keys_in_file(f)
    print(f"=== {f} ===")
    print("Found keys count:", len(keys))
    for lang, m in miss.items():
        if m:
            print(f"  Missing in {lang}: {set(m)}")
