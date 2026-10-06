# AGENTS.md

This repository is a Rails application template for `rails new -m`. It is not a Rails app.

Ruby files and comments are English. The README is English.

## Layout

- `template.rb` — entry. Clones this repo when loaded from a URL, then `apply` recipes.
- `recipes/` — one concern per file. `after_bundle.rb` runs after `bundle install`.
- `templates/` — files copied into the generated app (`copy_file` / `template`).
- `bin/new` — installs the newest Rails gem, then runs `rails new` with this template.
- `script/test-generate` — generates a dummy app and asserts files (and `bin/rspec` when `RUN_APP_CI=1`).

## Commands

| Action | Command |
|--------|---------|
| Create an app | `bin/new ~/code/myapp` |
| Optional modules | `bin/new ~/code/myapp --with=administrate,caprover` |
| Template CI | `bash script/test-generate` |
| Template CI with MySQL | `RUN_APP_CI=1 bash script/test-generate` |

Do not pin extra gems in recipes. New apps resolve the newest compatible versions at create time. This template does not upgrade apps after they exist.

## Conventions

- Keep `template.rb` short. Put behaviour in recipes.
- Recipe steps must be skippable when the file or snippet already exists (`file_contains?`, `gem_declared?`).
- Generated app comments, logs, identifiers, and commit messages are English. User-facing copy goes through `t(...)`.
- Conventional Commits.
