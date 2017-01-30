# Observatory

## Configuration

Configuration is done exclusively via environment variables. There are some
which need to be set for proper operation, but wherever possible, sane defaults
were used.

In the table below, 'Default value' defines the value which a setting is
initialized with, if you do not specify otherwise. 'Required' defines whether a
setting must be set - either explicitly or via its default value - for the
application to function properly.

Hence, required settings with no default value are the minimum set which you
must define manually.

### General

| Variable          | Default value | Required | Description                                                                                                                           |
| ----------------- | ------------- | -------- | -----------------------------------------------                                                                                       |
| `DEBUG`           |               | n        | If set, this application will dump potentially sensitive session information into the log.                                            |
| `SESSION_SECRET`  |               | y        | An alphanumeric string which is used to encrypt cookies. This config must be identical on all hosts, if you run a loadbalanced setup! |

### Unicorn

| Variable          | Default value | Required | Description                                                             |
| ----------------- | ------------- | -------- | ----------------------------------------------------------------------- |
| `UNICORN_LISTEN`  | 8080          | y        | Port which the application server will bind to.                         |
| `UNICORN_WORKERS` | 2             | y        | Number of worker processes. # of CPU cores + 1 is likely a good choice. |

### Timezone

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


#### Recommended setup for named-timezone-capable adapters

* `TIMEZONE_DATABASE` = UTC
* `TIMEZONE_APPLICATION` = `Your/Local/Timezone`
* Do not set `TZ`

#### Recommended setup for non-named-timezone-capable adapters

* `TIMEZONE_DATABASE` = utc
* `TIMEZONE_APPLICATION` = local
* `TZ` = `Your/Local/Timezone`

This works (in my tests) well, at the cost of modifying the container's
timezone.

### Redis

| Variable       | Default value | Required | Description              |
| -------------- | ------------- | -------- | ------------------------ |
| `REDIS_HOST`   | 127.0.0.1     | y        | Hostname of Redis server |
| `REDIS_PORT`   | 6379          | y        | Port of Redis server     |

### Database

| Variable      | Default value | Required | Description                                                                                |
| ------------- | ------------- | -------- | ------------------------------------------------------------------------------------------ |
| `DB_ADAPTER`  |               | y        | Database adapter which to use. Only valid option is `postgres`.                      |
| `DB_HOST`     |               | n        | Hostname of database server. Empty will use whatever the adpater wants - likely localhost. |
| `DB_DATABASE` |               | y        | Name of database which to use.                                                             |
| `DB_USER`     |               | n        | User which to authenticate as. Empty if no authentication needed.                          |
| `DB_PASS`     |               | n        | Password of user to authenticate as. Empty if no authentication needed.                    |

### Resque

| Variable                    | Default value | Required | Description                                                                     |
| --------------------------- | ------------- | -------- | ------------------------------------------------------------------------------- |
| `RESQUE_WEB_PATH`           |               | n        | URL where the Resque GUI will be made available. Empty to disable Resque GUI.   |
| `RESQUE_DURATIONS_RECORDED` | 1000          | y        | Number of past jobs to use for calculation of floating average in stats plugin. |

### Leaderboard

| Variable                             | Default value | Required | Description                                                         |
| ------------------------------------ | ------------- | -------- | ------------------------------------------------------------------- |
| `LEADERBOARD_PAGINATION_SIZE`        | 30            | y        | Number of per-page entries on leaderboard.                          |
| `LEADERBOARD_PAGINATION_LEADING`     | 5             | y        | Number of leading pages in pagination toolbar.                      |
| `LEADERBOARD_PAGINATION_SURROUNDING` | 3             | y        | Number of pages in pagination toolbar surrounding the current page. |
| `LEADERBOARD_PAGINATION_TRAILING`    | 5             | y        | Number of trailing pages in pagination toolbar.                     |

### Profile

| Variable                         | Default value | Required | Description                                                         |
| -------------------------------- | ------------- | -------- | --------------------------------------------------------------------|
| `PROFILE_PAGINATION_SIZE`        | 30            | y        | Number of per-page entries on profile.                              |
| `PROFILE_PAGINATION_LEADING`     | 5             | y        | Number of leading pages in pagination toolbar.                      |
| `PROFILE_PAGINATION_SURROUNDING` | 3             | y        | Number of pages in pagination toolbar surrounding the current page. |
| `PROFILE_PAGINATION_TRAILING`    | 5             | y        | Number of trailing pages in pagination toolbar.                     |

### Player Data

| Variable                      | Default value        | Required | Description                                                                                                                                  |
| ----------------------------- | -------------------- | -------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `PLAYER_DATA_BACKOFF_DELAY`   | 300                  | y        | A random number between 0 and this settings is chosen to determine the amount of seconds which a rate-limited player update will be delayed. |
| `PLAYER_DATA_INITIAL_DELAY`   | 60                   | y        | A random number between 0 and this settings is chosen to determine the amount of seconds which an automated player update will be delayed by initially. This serves to prevent all freshly-scheduled updates from trying to execute at once. |
| `PLAYER_DATA_CLEAR_UPDATE_SCHEDULED_AT_DELAY` | 7200 | y        | Number of seconds after which a scheduled player update is assumed to have failed silently, and new scheduling new updates is allowed. You should not need to tune this setting, this is only to prevent a bug from causing updates to cease. |


### Rate Limiting

| Variable                             | Default value | Required | Description                                                   |
| ------------------------------------ | ------------- | -------- | ------------------------------------------------------------- |
| `RATE_LIMITING_TOTAL_THRESHOLD`      | 2             | y        | Maximum number of API queries in set interval.                |
| `RATE_LIMITING_TOTAL_INTERVAL`       | 1             | y        | Interval duration in seconds.                                 |
| `RATE_LIMITING_USER_THRESHOLD`       | 2             | y        | Maximum number of user-initiated API queries in set interval. |
| `RATE_LIMITING_USER_INTERVAL`        | 1             | y        | Interval duration in seconds.                                 |
| `RATE_LIMITING_BACKGROUND_THRESHOLD` | 2             | y        | Maximum number of user-initiated API queries in set interval. |
| `RATE_LIMITING_BACKGROUND_INTERVAL`  | 1             | y        | Interval duration in seconds.                                 |

### Steam

| Variable                           | Default value | Required | Description                                                                                           |
| ---------------------------------- | ------------- | -------- | ----------------------------------------------------------------------------------------------------- |
| `STEAM_WEB_API_KEY`                |               | n        | Key for Steam Web API, used for name resolution. If undefined, name resolution will not be supported. |
