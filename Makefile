SHELL := /bin/sh

HTML_FILES := index.html web_arcade.html
CODEX_NODE := /Users/simonwaldherr/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node
NODE ?= $(shell command -v node 2>/dev/null || test ! -x $(CODEX_NODE) || printf '%s\n' $(CODEX_NODE))
PYTHON ?= python3
TIDY ?= tidy
PORT ?= 8080

.PHONY: help lint lint-js lint-html beautify format serve run check status

help:
	@printf '%s\n' \
		'Web Arcade make targets:' \
		'  make lint       Parse inline scripts and run basic HTML checks' \
		'  make beautify   Format inline JavaScript in HTML files' \
		'  make format     Alias for beautify' \
		'  make serve      Run python3 -m http.server 8080' \
		'  make run        Alias for serve' \
		'  make check      Alias for lint' \
		'  make status     Show git status'

lint: lint-js lint-html

lint-js:
	@$(NODE) -e 'const fs=require("fs"); let failed=false; for (const f of process.argv.slice(1)) { const html=fs.readFileSync(f,"utf8"); const scripts=[...html.matchAll(/<script[^>]*>([\s\S]*?)<\/script>/gi)].map(m=>m[1]); for (let i=0;i<scripts.length;i++) { try { new Function(scripts[i]); } catch (err) { failed=true; console.error(`$${f}: script $${i + 1}: $${err.message}`); } } console.log(`$${f}: parsed $${scripts.length} inline script(s)`); } if (failed) process.exit(1);' $(HTML_FILES)

lint-html:
	@$(NODE) -e 'const fs=require("fs"); let failed=false; for (const f of process.argv.slice(1)) { const html=fs.readFileSync(f,"utf8"); const lower=html.toLowerCase(); const checks=[[/<!doctype html>/,"missing <!doctype html>"],[/<html[\s>]/,"missing <html>"],[/<\/html>/,"missing </html>"],[/<head[\s>]/,"missing <head>"],[/<\/head>/,"missing </head>"],[/<body[\s>]/,"missing <body>"],[/<\/body>/,"missing </body>"],[/<title>[\s\S]+<\/title>/,"missing <title>"]]; for (const [re,msg] of checks) if (!re.test(lower)) { failed=true; console.error(`$${f}: $${msg}`); } const opened=(html.match(/<script\b[^>]*>/gi)||[]).length; const closed=(html.match(/<\/script>/gi)||[]).length; if (opened !== closed) { failed=true; console.error(`$${f}: unbalanced script tags`); } if (!failed) console.log(`$${f}: basic HTML checks passed`); } if (failed) process.exit(1);' $(HTML_FILES)

beautify:
	@$(NODE) tools/beautify-inline-js.mjs $(HTML_FILES)

format: beautify

serve:
	$(PYTHON) -m http.server $(PORT)

run: serve

check: lint

status:
	@git status --short
