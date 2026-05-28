스킬 사용 통계를 테이블로 보여줘.

아래 명령어를 실행하고 결과를 그대로 출력할 것. 추가 설명 없이 결과만 보여줄 것.

```bash
python3 -c "
import json, sys
from collections import defaultdict

LOG = '/Users/mixxeo/my-claude-code-os/.claude/skill-usage.log'

try:
    with open(LOG) as f:
        rows = [json.loads(l) for l in f if l.strip()]
except FileNotFoundError:
    print('로그 파일이 없습니다: ' + LOG)
    sys.exit(0)

if not rows:
    print('기록된 스킬 호출이 없습니다.')
    sys.exit(0)

stats = defaultdict(lambda: {'count': 0, 'total': 0.0, 'last': ''})
for r in rows:
    s = stats[r['skill']]
    s['count'] += 1
    s['total'] += r['duration_sec']
    if r['timestamp'] > s['last']:
        s['last'] = r['timestamp']

header = ['스킬', '호출 횟수', '평균 소요시간', '마지막 호출']
col_w = [max(len(header[0]), max(len(k) for k in stats)),
         max(len(header[1]), 6),
         max(len(header[2]), 8),
         max(len(header[3]), 19)]

def row(cells):
    return '  '.join(str(c).ljust(w) for c, w in zip(cells, col_w))

sep = '  '.join('-' * w for w in col_w)
print(row(header))
print(sep)
for skill, s in sorted(stats.items()):
    avg = round(s['total'] / s['count'], 1)
    print(row([skill, s['count'], f'{avg}s', s['last']]))
"
```
