import os
import re
import json

arabic_pattern = re.compile(r'[\u0600-\u06FF]+')
total_strings = 0
files_with_strings = {}

for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file).replace('\\', '/')
            with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                lines = f.readlines()
            matches = []
            for idx, line in enumerate(lines):
                stripped = line.strip()
                if stripped.startswith('//') or stripped.startswith('*') or stripped.startswith('/*'):
                    continue
                # find string literals
                str_matches = re.finditer(r'[\'\"]([^\'\"\n]*[\u0600-\u06FF]+[^\'\"\n]*)[\'\"]', line)
                for m in str_matches:
                    val = m.group(1).strip()
                    if val and not val.startswith('//'):
                        matches.append({
                            'line': idx + 1,
                            'text': val
                        })
            if matches:
                files_with_strings[path] = matches
                total_strings += len(matches)

output = {
    'total_files': len(files_with_strings),
    'total_strings': total_strings,
    'files': {k: v for k, v in sorted(files_with_strings.items(), key=lambda x: -len(x[1]))}
}

with open('scratch_all_arabic_strings.json', 'w', encoding='utf-8') as f:
    json.dump(output, f, ensure_ascii=False, indent=2)

print("Total files with Arabic strings:", output['total_files'])
print("Total Arabic strings occurrences:", output['total_strings'])
print("\nTop files by string count:")
for p, s in list(output['files'].items())[:15]:
    print(f"  {p}: {len(s)} strings")
