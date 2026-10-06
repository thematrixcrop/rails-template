# thematrixcrop/rails-template

A Rails 8 application template for [`rails new`](https://guides.rubyonrails.org/generators.html#application-templates).

Each new app is generated with the **newest Rails gem on Rubygems** and a fresh `Gemfile.lock`. This repository does not upgrade apps after they exist. Run `bundle update` and `bin/rails app:update` inside the app when you need newer gems.

## Quick start

```bash
rails new myapp \
  --database=trilogy \
  --css=bootstrap \
  --javascript=importmap \
  --skip-jbuilder \
  --skip-action-mailbox \
  --skip-kamal \
  --skip-test \
  -m https://raw.githubusercontent.com/thematrixcrop/rails-template/main/template.rb
```

Needs a current `rails` gem (`gem install rails`) and Node.js (Bootstrap). Optional modules: prefix with `RAILS_TEMPLATE_WITH=administrate,caprover`.

## Stack

| Layer | Choice |
| --- | --- |
| Database | [trilogy](https://github.com/trilogy-libraries/trilogy) (MySQL protocol) |
| Jobs | Active Job + [Solid Queue](https://github.com/rails/solid_queue) |
| Cache | [Solid Cache](https://github.com/rails/solid_cache) |
| Cable | [Solid Cable](https://github.com/rails/solid_cable) |
| CSS | Bootstrap via `rails new --css=bootstrap` |
| JS | importmap + [turbo-rails](https://github.com/hotwired/turbo-rails) + [stimulus-rails](https://github.com/hotwired/stimulus-rails) |
| Tests | RSpec (`-T` skips Minitest) |
| i18n | `rails-i18n`, `en` + `zh-CN` (`en` is the source locale) |
| Jobs UI | [Mission Control](https://github.com/rails/mission_control-jobs) at `/jobs` |

The template also adds `AppLog`, `AppConfig`, dotenv, lefthook, and an `AGENTS.md` for the new app.

## Create an app

### Recommended: `bin/new`

```bash
git clone https://github.com/thematrixcrop/rails-template.git
cd rails-template
bin/new ~/Developer/rubyonrails/myapp
```

`bin/new` queries Rubygems, installs the latest `rails` gem if needed, then runs `rails new` with this template.

```bash
bin/new ~/Developer/rubyonrails/myapp --with=administrate,caprover
bin/new ~/Developer/rubyonrails/myapp --skip-latest-check
bin/new ~/Developer/rubyonrails/myapp -- --skip-docker
```

### `rails new -m`

The [Quick start](#quick-start) command is the copy-paste form. `template.rb` clones this repository when `-m` is the GitHub URL, so recipes and files load.

A local checkout:

```bash
rails new myapp -m /path/to/rails-template/template.rb
```

### Default flags via `~/.railsrc`

Copy [`.railsrc.example`](.railsrc.example) to `~/.railsrc` if you want a plain `rails new myapp` to apply the template. Do not combine `~/.railsrc` with `bin/new` (`bin/new` already passes `--no-rc`).

## Optional modules

Pass `--with=` to `bin/new`, or set `RAILS_TEMPLATE_WITH` for a raw `rails new -m` run.

| Module | Effect |
| --- | --- |
| `administrate` | Adds the Administrate gem and `Admin::ApplicationController` |
| `caprover` | Adds `captain-definition` and `docker-compose.production.yml` |

```bash
RAILS_TEMPLATE_WITH=administrate,caprover rails new myapp -m /path/to/template.rb
```

## What the template adds

- Four MySQL databases in development and production: `primary`, `cache`, `queue`, `cable`. Test uses `primary` only.
- Solid Queue and Solid Cache in **development** as well as production.
- RSpec, Capybara, WebMock (net connect off), `bin/rspec`, and an RSpec step in `bin/ci`.
- `config/locales/en.yml` and `zh-CN.yml`, plus `spec/i18n_spec.rb`.
- lefthook: RuboCop on pre-commit; Brakeman and bundler-audit on pre-push.
- `.env` for local development (dotenv) and Rails credentials for env-independent config. See [Configuration](#configuration).

## Configuration

| Store | When it loads | What belongs there |
| --- | --- | --- |
| `.env` / `.env.local` | development and test, via [dotenv](https://github.com/bkeepers/dotenv) | Machine-specific and environment-specific: database, `APP_HOST`, log level |
| Process ENV | production | The same keys, set by the host (CapRover, systemd) |
| Rails credentials | every environment, one encrypted file | Shared secrets and config that do not change with the environment: OAuth client IDs, API tokens |

```bash
cp .env.example .env          # bin/setup does this when .env is missing
bin/rails credentials:edit    # layout in config/credentials.example.yml
```

Read credentials through `AppConfig.credential(:google, :client_id)`. Read host and database through ENV / `AppConfig.app_host`. Tests inject credentials with `AppConfig.with_overrides` and never open the real credentials file.

`.env` is gitignored. `.env.example` and `config/credentials.example.yml` are committed. `config/master.key` is gitignored; production sets `RAILS_MASTER_KEY`.

## Existing apps

This template does not bump gems in an app that already exists. You can still apply one recipe:

```bash
bin/rails app:template LOCATION=/path/to/rails-template/recipes/lefthook.rb
```

Recipes skip work when the target file or snippet is already present.

## Local MySQL

Default connection: user `root`, password `root`, socket `/tmp/mysql.sock`.

TCP (CI, Docker):

```bash
export DB_HOST=127.0.0.1
export DB_USER=root
export DB_PASSWORD=root
```

Bootstrap CSS needs Node.js on the machine that runs `rails new`.

## Version policy

1. `bin/new` installs the newest `rails` gem before it generates the app.
2. Extra gems in the template have **no** pessimistic pins, so `bundle` / `bundle update` during generation resolve the newest compatible versions.
3. Weekly CI generates a dummy app against current Rails and runs that app's RSpec.
4. A new Rails **major** needs a template change. The generator will not jump majors on its own.

## Develop this template

See [AGENTS.md](AGENTS.md).

```bash
# syntax
find . -name "*.rb" -print0 | xargs -0 -n1 ruby -c

# generate a dummy app and assert files
bash script/test-generate

# also boot the dummy app (needs MySQL)
RUN_APP_CI=1 bash script/test-generate
```

## License

MIT. See [LICENSE](LICENSE).
