# README

## Running in local development environment

### System requirements

- Docker
  - Postgres -- https://hub.docker.com/_/postgres/ -- `docker pull postgres:12`
  - Redis -- https://hub.docker.com/_/redis/ -- `docker pull redis:6`
- Ruby -- required version is in `.ruby-version`. Recommended: use rvm (Ruby Version Manager) to manage Rubies.
- Node -- required version is in `.node-version`. Recommended: use [nvm](https://github.com/nvm-sh/nvm) to manage Node.js versions
- Yarn -- https://classic.yarnpkg.com/en/docs/install (`npm install --global yarn`)
- Python (2 is required for `node-sass`)

### Initial steps

- Clone this repo
- `cd` into the repo directory
- `bundle install`
- `yarn install`
- `./bootstrap.sh` -- Docker must be available for this to access Postgres and Redis. Blows away any existing databases and rebuilds them from Rails migrations and seeds

Successful run of `bootstrap.sh` looks something like:

``` bash
❯  ./bootstrap.sh
Using default DB PostgreSQL port 5432
postgres
postgres
redis
redis
c3d50301a64ff6402a4e0acab9fc9d3b587a4b64d1aae1f28840ec66d3fe68af
528a8836e84b7ce4a1d194dc5d27e840ec5c1813fb64a78177f6794c7cb943d4
Dev cache is already enabled.
Created database 'importer_development'
Created database 'importer_test'
```

### Running the app

- Start the Rails server in one terminal: `./bin/rails s`
- Start Sidekiq in another terminal: `bundle exec sidekiq` (Otherwise the jobs you kick of in the app will sit in queue and never finish)
- http://127.0.0.1:3000/users/sign_in

### Run app in Console

`./bin/rails c`

### Run tests

`./bin/rails t`

## Config notes

Environment:

- APP_URL
- AWS_ACCESS_KEY_ID
- AWS_BUCKET
- AWS_REGION
- AWS_SECRET_ACCESS_KEY
- DATABASE_URL
- LANG
- LOCKBOX_MASTER_KEY
- MAPPERS_URL
- RACK_ENV
- RAILS_ENV
- RAILS_LOG_TO_STDOUT
- RAILS_SERVE_STATIC_FILES
- RAILS_STORAGE_SERVICE
- REDIS_URL
- SECRET_KEY_BASE

The `REDIS_URL` can be set on a per cache basis using:

- REDIS_CABLE_URL # websockets
- REDIS_CACHE_URL # rails cache and session storage
- REDIS_REFCACHE_URL # refcache
- REDIS_SIDEKIQ_URL # background jobs


For development only:

- CBI_DB_PORT: set the Postgres port for the dev & test databases
