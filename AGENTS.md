# Project Conventions — www.terminal7.dev

## Language & Framework
- **Static site generator**: Hugo (extended edition, v0.153.4)
- **Theme**: `terminal7-theme` (local, under `themes/terminal7-theme/`)
- **Templating**: Go templates (`.html` files in `layouts/`)
- **Styling**: SCSS (processed by Hugo's built-in Sass compiler — requires Hugo **extended**)
- **Content**: Markdown in `content/`

## Build & Run
- `just build` — runs `./build.sh`, which fetches GitHub contributors (needs `curl` + `jq`) then runs `hugo --gc --minify`
- `just run` — `hugo serve` (dev server on port 1313)
- `just lint` — `hugo --printPathWarnings` to check for broken internal links
- `just test` — dry build (`hugo --minify --gc`) to verify site compiles
- `just clean` — removes `public/`, `resources/`, `.hugo_build.lock`

## Style
- Commit messages: present progressive tense, start with capital letter, end with issue number if linked
- Branch names: no convention enforced
- Contributions via PR only

## Key Files
- `config.toml` — Hugo site configuration
- `build.sh` — production build script (fetches contributors then builds)
- `netlify.toml` — Netlify deploy config
- `content/` — site content (Markdown)
- `layouts/` — page templates (overrides theme)
- `themes/terminal7-theme/` — theme templates, SCSS, JS

## Dependencies
- Hugo extended (required for SCSS pipeline)
- `jq` (used by `build.sh` to parse GitHub API responses)
- `curl` (used by `build.sh` to fetch contributor data)

## Notes
- The `public/` directory is generated output — do not edit directly
- The theme is committed directly (not a git submodule)
