import os, re, json

arabic_regex = re.compile(r'[\u0600-\u06FF]+')

dirs_to_scan = [
    'lib/features/employee',
    'lib/features/marketer',
    'lib/features/profile',
    'lib/common/widgets',
]

results_theme = {}
results_localization = {}

for d in dirs_to_scan:
    for root, dirs, files in os.walk(d):
        for f in files:
            if f.endswith('.dart'):
                p = os.path.join(root, f).replace('\\', '/')
                with open(p, 'r', encoding='utf-8') as file:
                    content = file.read()
                
                # Check Theme
                has_white_bg = 'backgroundColor: Colors.white' in content or 'backgroundColor: const Color(0xFFFFFFFF)' in content
                has_hardcoded_card = 'color: Colors.white' in content or 'color: const Color(0xFFFFFFFF)' in content
                has_hardcoded_dark_text = '0xFF111B18' in content or '0xFF111827' in content
                has_theme_ctrl = 'ThemeController' in content or 'isDark' in content or 'Theme.of(context)' in content
                
                theme_issues = []
                if has_white_bg: theme_issues.append('Hardcoded white Scaffold background')
                if has_hardcoded_card and not has_theme_ctrl: theme_issues.append('Hardcoded white card/container without theme awareness')
                if has_hardcoded_dark_text and not has_theme_ctrl: theme_issues.append('Hardcoded dark text without dark theme alternative')
                
                if theme_issues:
                    results_theme[p] = theme_issues
                
                # Check Localization (Hardcoded Arabic strings in quotes)
                lines = content.split('\n')
                hardcoded_strings = []
                for line_num, l in enumerate(lines, 1):
                    stripped = l.strip()
                    if stripped.startswith('//') or stripped.startswith('*') or stripped.startswith('/*'):
                        continue
                    
                    matches = re.findall(r'(\'(?:[^\'\\]|\\.)*\'|\"(?:[^\"\\]|\\.)*\")', l)
                    for m in matches:
                        clean_str = m[1:-1]
                        if arabic_regex.search(clean_str):
                            if '.tr' not in l and not clean_str.startswith('package:'):
                                hardcoded_strings.append((line_num, clean_str))
                
                if hardcoded_strings:
                    results_localization[p] = hardcoded_strings

report = {
    'theme_issues_count': len(results_theme),
    'theme_issues': results_theme,
    'localization_issues_count': len(results_localization),
    'localization_issues': {k: v[:5] for k, v in results_localization.items()},
    'total_hardcoded_strings': sum(len(v) for v in results_localization.values())
}

with open('scratch_audit_results.json', 'w', encoding='utf-8') as f:
    json.dump(report, f, ensure_ascii=False, indent=2)

print('REPORT GENERATED: theme files =', len(results_theme), 'localization files =', len(results_localization), 'total strings =', report['total_hardcoded_strings'])
