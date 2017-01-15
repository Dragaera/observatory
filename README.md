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

### Redis

| Variable | Default value | Required | Description |
| -------- | ------------- | -------- | ----------- |
| `REDIS_HOST`   | 127.0.0.1     | y        | Hostname of Redis server |
| `REDIS_PORT`   | 6379          | y        | Port of Redis server |

### Database

| Variable   | Default value | Required | Description |
| ---------- | ------------- | -------- | ----------- |
| `DB_ADAPTER`  | sqlite        | y        | Database adapter which to use. Valid options are `sqlite`, `postgres`, `mysql2` |
| `DB_HOST`     |               | n        | Hostname of database server. Empty for flatfile database. |
| `DB_DATABASE` |               | n        | Name of database which to use. Empty for flatfile database. |
| `DB_USER`     |               | n        | User which to authenticate as. Empty if no authentication needed. |
| `DB_PASS`     |               | n        | Password of user to authenticate as. Empty if no authentication needed. |

### Resque

| Variable   | Default value | Required | Description |
| ---------- | ------------- | -------- | ----------- |
| `RESQUE_WEB_PATH` |               | n        | URL where the Resque GUI will be made available. Empty to disable Resque GUI. |

### Leaderboard

| Variable          | Default value | Required | Description                                |
| ----------------- | ------------- | -------- | ------------------------------------------ |
| `LEADERBOARD_PAGINATION_SIZE` | 30            | y        | Number of per-page entries on leaderboard. |

### Player Data

| Variable          | Default value | Required | Description                                |
| ----------------- | ------------- | -------- | ------------------------------------------ |
| PLAYER_DATA_UPDATE_INTERVAL | 24  | y        | Interval for automated player updates in hours |


### Rate Limiting

| Variable                           | Default value | Required | Description                                |
| ---------------------------------- | ------------- | -------- | ------------------------------------------ |
| RATE_LIMITING_TOTAL_THRESHOLD      | 2             | y        | Maximum number of API queries in set interval. |
| RATE_LIMITING_TOTAL_INTERVAL       | 2             | y        | Interval duration in seconds. |
| RATE_LIMITING_USER_THRESHOLD       | 2             | y        | Maximum number of user-initiated API queries in set interval. |
| RATE_LIMITING_USER_INTERVAL        | 2             | y        | Interval duration in seconds. |
| RATE_LIMITING_BACKGROUND_THRESHOLD | 2             | y        | Maximum number of user-initiated API queries in set interval. |
| RATE_LIMITING_BACKGROUND_INTERVAL  | 2             | y        | Interval duration in seconds. |
