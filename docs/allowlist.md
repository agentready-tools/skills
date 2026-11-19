# Plugin file allowlist

The Claude directory accepts only these file types from non-verified organizations:
Markdown, text, JSON, YAML, and images. No shebang files, package-manager configs,
`.claude/skills`, extra `.claude-plugin` directories, or extensionless files.

Check locally (no CI needed), from the repo root:

```sh
git ls-files | grep -Ev '\.(md|txt|json|ya?ml|png|jpe?g|gif|svg|webp)$' && echo "FAIL: disallowed files" || echo "OK: extensions"
git ls-files | while read -r f; do head -c2 "$f" | grep -q '#!' && echo "FAIL: shebang in $f"; done
```
