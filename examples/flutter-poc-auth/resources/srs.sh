#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(cd "$script_dir/.." && pwd)"
source_file="$script_dir/srs.md"
output_file="$project_root/srs-index.html"

if [[ ! -f "$source_file" ]]; then
  echo "Missing $source_file" >&2
  exit 1
fi

html_escape() {
  sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'
}

inline_md() {
  sed -E \
    -e 's/`([^`]*)`/<code>\1<\/code>/g' \
    -e 's/\*\*([^*]*)\*\*/<strong>\1<\/strong>/g'
}

slugify() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-//; s/-$//'
}

render_markdown() {
  local in_code=0
  local code_lang=""
  local in_ul=0
  local in_ol=0
  local in_table=0

  close_lists() {
    if [[ $in_ul -eq 1 ]]; then echo '</ul>'; in_ul=0; fi
    if [[ $in_ol -eq 1 ]]; then echo '</ol>'; in_ol=0; fi
  }

  close_table() {
    if [[ $in_table -eq 1 ]]; then echo '</tbody></table>'; in_table=0; fi
  }

  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ ^\`\`\`(.*)$ ]]; then
      if [[ $in_code -eq 0 ]]; then
        close_lists
        close_table
        code_lang="${BASH_REMATCH[1]}"
        if [[ "$code_lang" == "mermaid" ]]; then
          echo '<pre class="mermaid">'
        else
          echo '<pre><code>'
        fi
        in_code=1
      else
        if [[ "$code_lang" == "mermaid" ]]; then
          echo '</pre>'
        else
          echo '</code></pre>'
        fi
        in_code=0
        code_lang=""
      fi
      continue
    fi

    if [[ $in_code -eq 1 ]]; then
      printf '%s\n' "$line" | html_escape
      continue
    fi

    if [[ -z "$line" ]]; then
      close_lists
      close_table
      continue
    fi

    if [[ "$line" =~ ^\|.*\|$ ]]; then
      close_lists
      if [[ "$line" =~ ^\|[[:space:]-|:]+\|$ ]]; then
        continue
      fi
      if [[ $in_table -eq 0 ]]; then
        echo '<table><tbody>'
        in_table=1
      fi
      echo '<tr>'
      IFS='|' read -ra cells <<< "$line"
      for cell in "${cells[@]}"; do
        cell="$(printf '%s' "$cell" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')"
        [[ -z "$cell" ]] && continue
        printf '<td>%s</td>\n' "$(printf '%s' "$cell" | html_escape | inline_md)"
      done
      echo '</tr>'
      continue
    fi

    close_table

    if [[ "$line" =~ ^#[[:space:]]+(.+)$ ]]; then
      close_lists
      text="${BASH_REMATCH[1]}"
      id="$(slugify "$text")"
      printf '<h1 id="%s">%s</h1>\n' "$id" "$(printf '%s' "$text" | html_escape | inline_md)"
    elif [[ "$line" =~ ^##[[:space:]]+(.+)$ ]]; then
      close_lists
      text="${BASH_REMATCH[1]}"
      id="$(slugify "$text")"
      printf '<h2 id="%s">%s</h2>\n' "$id" "$(printf '%s' "$text" | html_escape | inline_md)"
    elif [[ "$line" =~ ^###[[:space:]]+(.+)$ ]]; then
      close_lists
      text="${BASH_REMATCH[1]}"
      id="$(slugify "$text")"
      printf '<h3 id="%s">%s</h3>\n' "$id" "$(printf '%s' "$text" | html_escape | inline_md)"
    elif [[ "$line" =~ ^-[[:space:]]+(.+)$ ]]; then
      if [[ $in_ul -eq 0 ]]; then close_lists; echo '<ul>'; in_ul=1; fi
      printf '<li>%s</li>\n' "$(printf '%s' "${BASH_REMATCH[1]}" | html_escape | inline_md)"
    elif [[ "$line" =~ ^[0-9]+\.[[:space:]]+(.+)$ ]]; then
      if [[ $in_ol -eq 0 ]]; then close_lists; echo '<ol>'; in_ol=1; fi
      printf '<li>%s</li>\n' "$(printf '%s' "${BASH_REMATCH[1]}" | html_escape | inline_md)"
    elif [[ "$line" =~ ^\>[[:space:]]*(.+)$ ]]; then
      close_lists
      printf '<blockquote>%s</blockquote>\n' "$(printf '%s' "${BASH_REMATCH[1]}" | html_escape | inline_md)"
    else
      close_lists
      printf '<p>%s</p>\n' "$(printf '%s' "$line" | html_escape | inline_md)"
    fi
  done < "$source_file"

  close_lists
  close_table
}

content_file="$(mktemp)"
render_markdown > "$content_file"

{
  cat <<'HTML'
<!doctype html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Software Requirements Specification</title>
  <script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
  <style>
    :root {
      --color-primary: #FCD535;
      --color-canvas: #ffffff;
      --color-surface: #fafafa;
      --color-surface-strong: #f3f3f5;
      --color-ink: #181a20;
      --color-muted: #707a8a;
      --color-hairline: #eaecef;
      --color-link: #2563eb;
      --font-body: "Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      --font-mono: "JetBrains Mono", ui-monospace, SFMono-Regular, Menlo, monospace;
    }
    * { box-sizing: border-box; }
    body { font-family: var(--font-body); color: var(--color-ink); background: var(--color-surface); margin: 0; padding: 0; line-height: 1.6; }
    .layout { display: grid; grid-template-columns: 280px 1fr; min-height: 100vh; }
    aside { position: sticky; top: 0; align-self: start; height: 100vh; overflow-y: auto; background: var(--color-canvas); border-right: 1px solid var(--color-hairline); padding: 24px 16px; }
    aside h2 { font-size: 14px; text-transform: uppercase; color: var(--color-muted); margin: 0 0 12px; letter-spacing: .03em; border: 0; padding: 0; }
    aside nav ol, aside nav ul { list-style: none; padding: 0; margin: 0; }
    aside nav .toc-h2 > a { font-weight: 600; font-size: 13px; color: var(--color-ink); display: block; padding: 6px 10px; border-radius: 6px; text-decoration: none; }
    aside nav .toc-h2 > a:hover { background: var(--color-surface); }
    aside nav .toc-h2.active > a { background: var(--color-primary); color: var(--color-ink); }
    aside nav .toc-h3 { padding-left: 18px; border-left: 2px solid var(--color-hairline); margin-left: 10px; }
    aside nav .toc-h3 a { display: block; padding: 4px 10px; font-size: 12px; color: var(--color-muted); border-radius: 4px; text-decoration: none; line-height: 1.4; }
    aside nav .toc-h3 a:hover { background: var(--color-surface); color: var(--color-ink); }
    aside nav .toc-h3 a.active { color: var(--color-ink); font-weight: 600; background: var(--color-surface); }
    aside nav .toc-h2.collapsed .toc-h3 { display: none; }
    aside nav .toggle { cursor: pointer; user-select: none; color: var(--color-muted); margin-right: 4px; display: inline-block; width: 12px; transition: transform .15s; }
    aside nav .toc-h2.collapsed .toggle { transform: rotate(-90deg); }
    main { padding: 40px 60px; max-width: 1100px; }
    main h1 { font-size: 32px; border-bottom: 2px solid var(--color-ink); padding-bottom: 12px; }
    main h2 { font-size: 24px; margin-top: 40px; border-bottom: 1px solid var(--color-hairline); padding-bottom: 6px; }
    main h3 { font-size: 18px; margin-top: 28px; color: var(--color-ink); }
    main h4 { font-size: 16px; margin-top: 20px; }
    main p, main li { font-size: 14px; }
    main code { font-family: var(--font-mono); font-size: 13px; background: var(--color-surface); padding: 2px 6px; border-radius: 4px; }
    main pre { background: var(--color-surface); border: 1px solid var(--color-hairline); border-radius: 8px; padding: 16px; overflow-x: auto; font-size: 13px; }
    main pre.mermaid { background: var(--color-canvas); text-align: center; color: var(--color-ink); white-space: pre; }
    main .mermaid svg { max-width: 100%; }
    main table { border-collapse: collapse; width: 100%; margin: 16px 0; font-size: 13px; }
    main th, main td { border: 1px solid var(--color-hairline); padding: 8px 12px; text-align: left; vertical-align: top; }
    main th { background: var(--color-surface); font-weight: 600; }
    main a { color: var(--color-link); text-decoration: none; }
    main a:hover { text-decoration: underline; }
    main hr { border: none; border-top: 1px solid var(--color-hairline); margin: 32px 0; }
    main blockquote { border-left: 4px solid var(--color-primary); margin: 16px 0; padding: 8px 16px; background: var(--color-surface); color: var(--color-muted); }
    .meta { color: var(--color-muted); font-size: 13px; margin-bottom: 24px; }
    footer { padding: 24px 60px; border-top: 1px solid var(--color-hairline); color: var(--color-muted); font-size: 13px; background: var(--color-canvas); }
    footer code { font-family: var(--font-mono); background: var(--color-surface); padding: 2px 6px; border-radius: 4px; }
    @media (max-width: 768px) { .layout { grid-template-columns: 1fr; } aside { position: static; height: auto; border-right: none; border-bottom: 1px solid var(--color-hairline); } main { padding: 24px; } footer { padding: 16px 24px; } }
  </style>
</head>
<body>
  <div class="layout">
    <aside>
      <h2>Flutter POC Auth</h2>
      <div class="meta">SRS Package</div>
      <nav><ol id="toc"></ol></nav>
    </aside>
    <main id="content">
HTML
  cat "$content_file"
  cat <<'HTML'
    </main>
  </div>
  <footer>Generated from <code>resources/srs.md</code> by <code>resources/srs.sh</code>.</footer>
  <script>
    mermaid.initialize({ startOnLoad: true, theme: 'default' });
    const toc = document.getElementById('toc');
    const headings = [...document.querySelectorAll('main h2, main h3')];
    let currentGroup = null;
    headings.forEach((heading) => {
      const item = document.createElement('li');
      const link = document.createElement('a');
      link.href = `#${heading.id}`;
      link.textContent = heading.textContent;
      if (heading.tagName === 'H2') {
        item.className = 'toc-h2';
        const toggle = document.createElement('span');
        toggle.className = 'toggle';
        toggle.textContent = '▾';
        link.prepend(toggle);
        item.appendChild(link);
        const sub = document.createElement('ul');
        sub.className = 'toc-h3';
        item.appendChild(sub);
        toc.appendChild(item);
        currentGroup = sub;
        toggle.addEventListener('click', (event) => {
          event.preventDefault();
          item.classList.toggle('collapsed');
        });
      } else if (currentGroup) {
        item.appendChild(link);
        currentGroup.appendChild(item);
      }
    });
    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        const link = document.querySelector(`aside nav a[href="#${entry.target.id}"]`);
        if (!link) return;
        if (entry.isIntersecting) {
          document.querySelectorAll('aside nav a.active, aside nav li.active').forEach((node) => node.classList.remove('active'));
          link.classList.add('active');
          link.closest('.toc-h2')?.classList.add('active');
        }
      });
    }, { rootMargin: '-20% 0px -70% 0px' });
    headings.forEach((heading) => observer.observe(heading));
  </script>
</body>
</html>
HTML
} > "$output_file"

rm -f "$content_file"

echo "Generated $output_file"

if command -v open >/dev/null 2>&1; then
  open "$output_file"
elif command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$output_file" >/dev/null 2>&1 &
fi
