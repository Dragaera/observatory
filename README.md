# Observatory

This is the git repository of the Observatory - a basic webinterface to the
Hive 2 API of Natural Selection 2.

A live version of this application can be found at
https://observatory.morrolan.ch.

## Running

### Configuration

Configuration is done exclusively via environment variables. There are some
which need to be set for proper operation, but wherever possible, sane defaults
were used.

In the table below, 'Default value' defines the value which a setting is
initialized with, if you do not specify otherwise. 'Required' defines whether a
setting must be set - either explicitly or via its default value - for the
application to function properly.

Hence, required settings with no default value are the minimum set which you
must define manually.

#### General

| Variable          | Default value | Required | Description                                                                                                                           |
| ----------------- | ------------- | -------- | -----------------------------------------------                                                                                       |
| `DEBUG`           |               | n        | If set, this application will dump potentially sensitive session information into the log.                                            |
| `SESSION_SECRET`  |               | y        | An alphanumeric string which is used to encrypt cookies. This config must be identical on all hosts, if you run a loadbalanced setup! |
| `RACK_ENV`        | development   | y        | Application environment. `development`, `testing` and `production` have defined meaning, other values may cause undefined behaviour. |

#### Puma

| Variable            | Default value | Required | Description                                                                                                                                   |
| ------------------- | ------------- | -------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `PUMA_LISTEN_IP`    | 0.0.0.0       | y        | IP which the application server will bind to. If you run this application outside of a Docker container, you will likely want to change this! |
| `PUMA_LISTEN_PORT`  | 8080          | y        | Port which the application server will bind to.                                                                                               |
| `PUMA_THREADS_MIN`  | 0             | y        | Initial number of threads to spawn per worker.                                                                                                |
| `PUMA_THREADS_MAX`  | 16            | y        | Maximum number of threads to spawn per worker.                                                                                                |
| `PUMA_WORKERS`      | 2             | y        | Number of worker processes to spawn.                                                                                                          |

#### Timezone

Dealing with timezones can be rather frustrating, as the options available vary
depending on the database adapter.

With some adapters, you are able to use named timezones for the settings below
- these are timezones like `Europe/London` or `EST`.
With others you are limited to two options - `local` to use the server's local
time, and `utc` to use UTC. 

**Mind the capitalization!** `UTC` will use the
named-timezone for UTC, whereas `utc` will use the basic-behaviour UTC.

| Variable                | Default value        | Required | Description                                     |
| ----------------------- | -------------------- | -------- | ----------------------------------------------- |
| `TIMEZONE_DATABASE`     | utc                  | y        | Timezone which to use for storing timestamps in the database. Also the timezone which timestamps in the database are assumed to be in, unless specified otherwise. Only change this if you are certain of what you are doing. |
| `TIMEZONE_APPLICATION`  | utc                  | y        | Timezone which timestamps will be converted to when loaded from the database. This is essentially the timezone you will see in the application's frontend. |
| `TIMEZONE_TYPECAST`     | TIMEZONE_APPLICATION | y        | Timezone which *unmarked* timestamps will be assumed to be in. |


##### Recommended setup for named-timezone-capable adapters

* `TIMEZONE_DATABASE` = UTC
* `TIMEZONE_APPLICATION` = `Your/Local/Timezone`
* Do not set `TZ`

##### Recommended setup for non-named-timezone-capable adapters

* `TIMEZONE_DATABASE` = utc
* `TIMEZONE_APPLICATION` = local
* `TZ` = `Your/Local/Timezone`

This works (in my tests) well, at the cost of modifying the container's
timezone.

#### Redis

| Variable       | Default value | Required | Description              |
| -------------- | ------------- | -------- | ------------------------ |
| `REDIS_HOST`   | 127.0.0.1     | y        | Hostname of Redis server |
| `REDIS_PORT`   | 6379          | y        | Port of Redis server     |

#### Database

| Variable      | Default value | Required | Description                                                                                |
| ------------- | ------------- | -------- | ------------------------------------------------------------------------------------------ |
| `DB_ADAPTER`  |               | y        | Database adapter which to use. Only valid option is `postgres`.                            |
| `DB_HOST`     |               | n        | Hostname of database server. Empty will use whatever the adpater wants - likely localhost. |
| `DB_PORT`     |               | n        | Port of database server. Empty will use whatever the adpater wants.                        |
| `DB_DATABASE` |               | y        | Name of database which to use.                                                             |
| `DB_USER`     |               | n        | User which to authenticate as. Empty if no authentication needed.                          |
| `DB_PASS`     |               | n        | Password of user to authenticate as. Empty if no authentication needed.                    |

#### Resque

| Variable                    | Default value | Required | Description                                                                     |
| --------------------------- | ------------- | -------- | ------------------------------------------------------------------------------- |
| `RESQUE_WEB_PATH`           |               | n        | URL where the Resque GUI will be made available. Empty to disable Resque GUI.   |
| `RESQUE_DURATIONS_RECORDED` | 1000          | y        | Number of past jobs to use for calculation of floating average in stats plugin. |

#### Leaderboard

| Variable                             | Default value | Required | Description                                                         |
| ------------------------------------ | ------------- | -------- | ------------------------------------------------------------------- |
| `LEADERBOARD_PAGINATION_SIZE`        | 30            | y        | Number of per-page entries on leaderboard.                          |
| `LEADERBOARD_PAGINATION_LEADING`     | 5             | y        | Number of leading pages in pagination toolbar.                      |
| `LEADERBOARD_PAGINATION_SURROUNDING` | 3             | y        | Number of pages in pagination toolbar surrounding the current page. |
| `LEADERBOARD_PAGINATION_TRAILING`    | 5             | y        | Number of trailing pages in pagination toolbar.                     |

#### Profile

| Variable                         | Default value | Required | Description                                                         |
| -------------------------------- | ------------- | -------- | --------------------------------------------------------------------|
| `PROFILE_PAGINATION_SIZE`        | 30            | y        | Number of per-page entries on profile.                              |
| `PROFILE_PAGINATION_LEADING`     | 5             | y        | Number of leading pages in pagination toolbar.                      |
| `PROFILE_PAGINATION_SURROUNDING` | 3             | y        | Number of pages in pagination toolbar surrounding the current page. |
| `PROFILE_PAGINATION_TRAILING`    | 5             | y        | Number of trailing pages in pagination toolbar.                     |

##### ENSL

| Variable                         | Default value | Required | Description                                                         |
| -------------------------------- | ------------- | -------- | --------------------------------------------------------------------|
| `PROFILE_ENSL_SHOW_TUTORIALS`    | y             | y        | Whether to link the ENSL tutorials on weak player's profile pages. |
| `PROFILE_ENSL_SKILL_THRESHOLD`   | 2000          | y        | Skill below which to show ENSL tutorials on profile pages. |
| `PROFILE_ENSL_TIME_THRESHOLD`    | 8 * 60 * 60   | y        | Playtime above which to show ENSL tutorials on profile pages. |

#### Player

| Variable                         | Default value | Required | Description                                                         |
| -------------------------------- | ------------- | -------- | --------------------------------------------------------------------|
| `PLAYER_PAGINATION_SIZE`         | 30            | y        | Number of per-page entries in player search.                        |
| `PLAYER_PAGINATION_LEADING`      | 5             | y        | Number of leading pages in pagination toolbar.                      |
| `PLAYER_PAGINATION_SURROUNDING`  | 3             | y        | Number of pages in pagination toolbar surrounding the current page. |
| `PLAYER_PAGINATION_TRAILING`     | 5             | y        | Number of trailing pages in pagination toolbar.                     |
| `PLAYER_ERROR_THRESHOLD`         | 3             | y        | Number of failed data-retrieval attempts after which a player will be disabled.  This only affects players which never had a successful data retrieval. |
| `PLAYER_INVALID_RETENTION_TIME`  | 3600          | y        | Number of seconds after which disabled players without data will be removed. |

#### Player Data

| Variable                                      | Default value        | Required | Description                                                                                                                                  |
| --------------------------------------------- | -------------------- | -------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `PLAYER_DATA_BACKOFF_DELAY`                   | 300                  | y        | A random number between 0 and this settings is chosen to determine the amount of seconds which a rate-limited player update will be delayed. |
| `PLAYER_DATA_INITIAL_DELAY`                   | 60                   | y        | A random number between 0 and this settings is chosen to determine the amount of seconds which an automated player update will be delayed by initially. This serves to prevent all freshly-scheduled updates from trying to execute at once. |
| `PLAYER_DATA_CLEAR_UPDATE_SCHEDULED_AT_DELAY` | 7200                 | y        | Number of seconds after which a scheduled player update is assumed to have failed silently, and new scheduling new updates is allowed. You should not need to tune this setting, this is only to prevent a bug from causing updates to cease. |
| `PLAYER_DATA_EXPORT_ROOT`                     | /mnt/observatory     | y        | Path in the file system where generated CSVs will be stored for a certain duration. Default value is suitable for running in a Docker container and mounting a volume there - but feel free to adjust to your liking. |
| `PLAYER_DATA_EXPORT_EXPIRY_THRESHOLD`         | 604800               | y        | Number of seconds after which a player data export will be expired, that is its file deleted. Set to 0 to keep indefinitely. |
| `PLAYER_DATA_SCORE_PER_SECOND_THRESHOLD`      | 1                    | y        | Score-per-second value at which (`>=`) to treat score changes as a result of the known score-multiplying bug, and discard them. |

#### Rate Limiting

| Variable                                  | Default value | Required | Description                                                        |
| ----------------------------------------- | ------------- | -------- | ------------------------------------------------------------------ |
| `HIVE_RATE_LIMITING_TOTAL_THRESHOLD`      | 2             | y        | Maximum number of Hive API queries in set interval.                |
| `HIVE_RATE_LIMITING_TOTAL_INTERVAL`       | 1             | y        | Interval duration in seconds.                                      |
| `HIVE_RATE_LIMITING_USER_THRESHOLD`       | 2             | y        | Maximum number of user-initiated Hive API queries in set interval. |
| `HIVE_RATE_LIMITING_USER_INTERVAL`        | 1             | y        | Interval duration in seconds.                                      |
| `HIVE_RATE_LIMITING_BACKGROUND_THRESHOLD` | 2             | y        | Maximum number of user-initiated Hive API queries in set interval. |
| `HIVE_RATE_LIMITING_BACKGROUND_INTERVAL`  | 1             | y        | Interval duration in seconds.                                      |
| `STEAM_RATE_LIMITING_TOTAL_THRESHOLD`     | 3             | y        | Maximum number of Steam API queries in set interval.               |
| `STEAM_RATE_LIMITING_TOTAL_INTERVAL`      | 1             | y        | Interval duration in seconds.                                      |

#### Steam

| Variable             | Default value | Required | Description                                                                                               |
| -------------------- | ------------- | -------- | --------------------------------------------------------------------------------------------------------- |
| `STEAM_WEB_API_KEY`  |               | n        | Key for Steam Web API, used for name resolution. If undefined, name resolution will not be supported.     |
| `STEAM_HTTP_PROXIES` |               | n        | List of comma-separated HTTP proxy URLs which to use for Steam inventory API calls. Empty to not use any. |

#### Colour

| Variable        | Default value | Required | Description                                       |
| --------------- | ------------- | -------- | ------------------------------------------------- |
| `COLOUR_ALIEN`  | #FF0000       | y        | RGB colour to use to represent aliens on graphs.  |
| `COLOUR_MARINE` | #0000FF       | y        | RGB colour to use to represent marines on graphs. |

#### Localization

| Variable                       | Default value | Required | Description                                                                                                                                                                                |
| ------------------------------ | ------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `LOCALIZATION_DATE_FORMAT`     | %F            | y        | Formatting directive which to use for formatting dates. Check the Ruby documentation for specifics, although it behaves nearly identical to `strftime` of the ISO C / POSIX standard.      |
| `LOCALIZATION_DATETIME_FORMAT` | %FT%T%:z      | y        | Formatting directive which to use for formatting date-times. Check the Ruby documentation for specifics, although it behaves nearly identical to `strftime` of the ISO C / POSIX standard. |

#### Piwik

| Variable        | Default value | Required | Description                                       |
| --------------- | ------------- | -------- | ------------------------------------------------- |
| `PIWIK_ENABLED` | false         | y        | Set to `true` to enable Piwik integration.        |
| `PIWIK_SERVER`  |               | n        | Host of Piwik server, eg `piwik.example.com`.     |
| `PIWIK_SITE_ID` |               | n        | Site ID of Piwik site.                            |

#### Gorge

| Variable                     | Default value | Required | Description                                                |
| ---------------------------- | ------------- | -------- | ---------------------------------------------------------- |
| `GORGE_BASE_URL`             |               | n        | Base URL of Gorge. Empty to disable Gorge integration.     |
| `GORGE_HTTP_BASIC_USER`      |               | n        | User for HTTP basic authentication. Empty to disable.      |
| `GORGE_HTTP_BASIC_PASSWORD ` |               | n        | Password for HTTP basic authentication. Empty to disable.  |
| `GORGE_CONNECT_TIMEOUT`      | 1             | y        | HTTP connect timeout towards Gorge API.                    |
| `GORGE_TIMEOUT`              | 2             | y        | HTTP timeout towards Gorge API.                            |
| `STATISTICS_CLASSES`         | n_30,n_100    | y        | Comma-separated statistics classes of Gorge which to query |

#### Sentry

| Variable     | Default value | Required | Description                                        |
| ------------ | ------------- | -------- | -------------------------------------------------- |
| `SENTRY_DSN` |               | n        | Full Sentry DSN URL which to report exceptions to. |

#### MOTD

| Variable       | Default value | Required | Description                              |
| -------------- | ------------- | -------- | ---------------------------------------- |
| `MOTD_ENABLED` | false         | y        | Set to `true` to enable showing of MOTD. |
| `MOTD_MESSAGE` |               | n        | String to show as MOTD on top of site.   |

#### NSL

| Variable                    | Default value                     | Required | Description                               |
| --------------------------- | --------------------------------- | -------- | ----------------------------------------- |
| `NSL_ACCOUNTS_API_ENDPOINT` | https://www.ensl.org/api/v1/users | y        | Endpoint from which to fetch NSL accounts |
| `NSL_PROFILE_BASE_URL`      | https://www.ensl.org/users        | y        | Base URL of ensl.org profiles             |

## Developing

Want to work on this application? Here's some steps to get you started.

### Install dependencies

In order to conveniently work on the application, you will need:

- Ruby version manager, eg pry, rvm, rbenv, ...
- Bundler
- Docker & docker-compose
- Install ruby dependencies (`bundle install`)

### Prepare environment

The easiest way to spawn the required environment (database, redis, ...) is via
the supplied `docker-compose` file. This will provide you with the required
environment to run a development server, as well as tests, on your machine.

Alternatively, you will need:

- PostgreSQL
- Redis

If you set these up yourself, you will have to adjust the config in the
following step accordingly.


### Run development server

- Copy .env.development.dist to .env.development
- Open configuration file, and adjust all settings marked as `CHANGEME`
- Spawn environment via `docker-compose up`
- Run application server: `bundle exec padrino s`
- Run worker process: `QUEUE=* bundle exec rake resque:work`
- Run scheduler process: `bundle exec rake resque:scheduler`
- Now the server should be accessible at http://localhost:3000


### Running tests

- Copy .env.test.dist to .env.test
- Open configuration file, and adjust all settings marked as `CHANGEME`
- Spawn environment via `docker-compose up` (if already done during
  development, no need to do it again)
- Run tests: `bundle exec rake rspec -fd -c spec/`

#### Running dockerized tests

Alternatively you can run tests within a Docker container - this has the
advantage of being fully contained, at the cost of some speed.

This is mainly interesting for CI solutions, but could also be used locally.

```
# Build container and run tests
docker-compose -f docker-compose.testing.yml up --build --abort-on-container-exit
```

