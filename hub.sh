#!/bin/bash
# platform_hub: what is open for a project, a new question, a summary.
# Usage:
#   hub.sh <project>                       open questions to <project>, open conflicts, items for Alexey
#   hub.sh status                          counts per queue, conflicts, items for Alexey
#   hub.sh new <from> <to> "title"         append a numbered question to QUEUE/<to>.md
# Projects: lightplan, eventos, bronios, site.
set -euo pipefail
HUB="$(cd "$(dirname "$0")" && pwd)"
PROJECTS="lightplan eventos bronios site"

die() { echo "hub.sh: $*" >&2; exit 1; }
known() { for p in $PROJECTS; do [ "$p" = "$1" ] && return 0; done; return 1; }

# Question headings that are not closed. Heading format:
# ### Q-001 · от: bronios · кому: lightplan · 2026-10-08 · статус: открыт
open_q() { grep -n '^### Q-' "$1" 2>/dev/null | grep -v 'статус: закрыт' || true; }

next_id() {
  local max=0 n
  for f in "$HUB"/QUEUE/*.md; do
    for n in $(grep -o '^### Q-[0-9]*' "$f" 2>/dev/null | sed 's/^### Q-0*//'); do
      [ -n "$n" ] && [ "$n" -gt "$max" ] && max=$n
    done
  done
  printf 'Q-%03d' $((max + 1))
}

case "${1:-}" in
  ""|-h|--help)
    sed -n '2,7p' "$0" | sed 's/^# \{0,1\}//'
    ;;
  status)
    for p in $PROJECTS; do
      f="$HUB/QUEUE/$p.md"
      total=$(grep -c '^### Q-' "$f" 2>/dev/null || true)
      open=$(open_q "$f" | grep -c 'статус: открыт' || true)
      ans=$(open_q "$f" | grep -c 'статус: отвечен' || true)
      wait=$(open_q "$f" | grep -c 'статус: ждёт Алексея' || true)
      printf '%-10s всего %3s · открыт %3s · отвечен %3s · ждёт Алексея %3s\n' "$p" "$total" "$open" "$ans" "$wait"
    done
    echo "противоречий открыто: $(grep -c '^### C-.*статус: открыт' "$HUB/CONFLICTS.md" 2>/dev/null || true)"
    echo "для Алексея открыто:  $(grep -c '^### A-.*статус: открыт' "$HUB/FOR_ALEXEY.md" 2>/dev/null || true)"
    ;;
  new)
    [ $# -eq 4 ] || die 'нужно: hub.sh new <от> <кому> "заголовок"'
    known "$2" || die "неизвестный проект: $2 ($PROJECTS)"
    known "$3" || die "неизвестный проект: $3 ($PROJECTS)"
    id=$(next_id)
    f="$HUB/QUEUE/$3.md"
    printf '\n### %s · от: %s · кому: %s · %s · статус: открыт\n%s\n(текст вопроса)\n**Что меняет:** (простыми словами)\n' \
      "$id" "$2" "$3" "$(date +%Y-%m-%d)" "$4" >> "$f"
    echo "$id добавлен в QUEUE/$3.md — допиши текст под заголовком"
    ;;
  *)
    known "$1" || die "неизвестный проект: $1 ($PROJECTS)"
    echo "== вопросы к $1 (не закрытые)"
    open_q "$HUB/QUEUE/$1.md" | sed 's/^[0-9]*:/  /'
    echo "== ответы на вопросы $1 к другим (ждут закрытия)"
    for p in $PROJECTS; do
      [ "$p" = "$1" ] && continue
      grep '^### Q-' "$HUB/QUEUE/$p.md" 2>/dev/null | grep "от: $1 " | grep 'статус: отвечен' | sed 's/^/  /' || true
    done
    echo "== противоречия (открытые)"
    grep '^### C-' "$HUB/CONFLICTS.md" 2>/dev/null | grep 'статус: открыт' | sed 's/^/  /' || true
    echo "== для Алексея (открытые)"
    grep '^### A-' "$HUB/FOR_ALEXEY.md" 2>/dev/null | grep 'статус: открыт' | sed 's/^/  /' || true
    ;;
esac
