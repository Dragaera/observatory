# Change log

This document represents a high-level overview of changes made to this project.
It will not list every miniscule change, but will allow you to view - at a
glance - what to expact from upgrading to a new version.

## [unpublished]

### Added

### Changed

- Made update scheduling more resistant to unexpected failures.
- Internal refactoring of logging output.

### Fixed

- Automatic test suite.

### Security

### Deprecated

### Removed


## [0.7.1] - 2017-01-20

### Changed

- Updates dependencies.

### Fixed

- Calculation of 'Score per Minute' if both score and total time are 0.


## [0.7.0] - 2017-01-19

### Added

- 'Score per minute' value to player profiles and leaderboard.

### Fixed

- Stay on current pagee if sort column of leaderboard changed.


## [0.6.2] - 2017-01-19

### Fixed

- Fixed creation of stale user objects if the Hive query failed.


## [0.6.1] - 2017-01-19

### Added

- Placeholder player profile for players with no data.

### Fixed

- Removed players without player data from leaderboard.

### Removed

- PLAYER_DATA_UPDATE_INTERVAL: With custom update frequencies this setting has
  no value anymore.


## [0.6.0] - 2017-01-18

### Added

- Per-player update frequency which determines at which rate background updates
  get scheduled. Frequency is determined by player activity.

- Delay automatically scheduled player updates to prevent them from
  trying to execute all at once.

### Changed

- Refactored Player and PlayerDataPoint models. All Hive data is now stored in
  the later, while the former only contains the player's resolved account ID.

  Also adds a `relevant` field to data points, which states whether the data
  changed since its predecessor.


## [0.5.3] - 2017-01-16

### Added

- Prevent user from scheduling multiple updates for the same player.

### Fixed

- Prevent background updates from scheduling multiple updates for the same
  player.


## [0.5.2] - 2017-01-16

### Fixed

- Fixed `PLAYER_DATA_BACKOFF_DELAY` setting.


## [0.5.1] - 2017-01-15

### Added

- Backoff time for player updates in case of rate limiting is now configurable.

### Fixed

- Updated dependencies to fix handling of account IDs starting with 765.


## [0.5.0] - 2017-01-15

### Added

- New pagination to leaderboard which scales better with number of pages.

### Changed

- Randomize delay duration in case of rate limiting of background updates.


## [0.4.1] - 2017-01-14

### Added

- Docker entrypoints for Resque worker and scheduler.

### Fixed

- Ratelimit gem now respects redis connection settings.


## [0.4.0] - 2017-01-14

### Added

- Automated and on-demand background updates for player data.
- Rate-limiting for on-demand and background updates.

### Fixed

- Adagrad sum is now properly saved as a float rather than an integer.


## [0.3.2] - 2017-01-02

### Security

- Adds .dockerignore, preventing dev credentials from leaking into public
  containers.


## [0.3.1] - 2016-12-31

### Fixed

- Fixed docker container: Log to stdout, add missing DB adapters.


## [0.3.0] - 2016-12-31

### Added

- Persistent storage of Hive 2 user profiles and data.
- Basic paginated leaderboard.

### Fixed

- Properly format 0s-timespans.
- Updates HiveStalker gem to fix bug with resolving of Steam IDs.

### Removed

- Multi-person queries due to rate-limiting concerns.


## [0.2.1] - 2016-12-26

### Fixed

- Updates HiveStalker gem to fix bug with low account IDs.


## [0.2.0] - 2016-12-26

### Added

- Allows 'vanity'-URLs as input, in addition to various formats of Steam ID.


## [0.1.0] - 2016-12-25

### Added

- Basic interface to query data of one or multiple players from the Hive 2 HTTP
  API.
